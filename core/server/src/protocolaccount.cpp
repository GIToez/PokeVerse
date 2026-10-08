////////////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////
#include "otpch.h"
#include "resources.h"

#include "protocolaccount.h"
#include "tools.h"
#include "rsa.h"

#include "iologindata.h"
#include "ioban.h"
#include "database.h"

#include "outputmessage.h"
#include "connection.h"
#include "tasks.h"

#include "configmanager.h"
#include "game.h"

extern ConfigManager g_config;
extern Game g_game;

namespace
{
	const uint32_t MAX_CHARACTERS_PER_ACCOUNT = 10;
	const uint32_t MAX_ACCOUNTS_PER_IP = 3;
	const time_t ACCOUNTS_PER_IP_WINDOW = 3600;

	// Accounts created per client IP; dispatcher thread only.
	std::map<uint32_t, std::list<time_t> > createdAccounts;
}

void ProtocolAccount::reply(bool success, const std::string& message)
{
	if(OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false))
	{
		TRACK_MESSAGE(output);
		output->AddByte(success ? 0x0B : 0x0A);
		output->AddString(message);
		OutputMessagePool::getInstance()->send(output);
	}

	getConnection()->close();
}

bool ProtocolAccount::parseFirstPacket(NetworkMessage& msg)
{
	if(g_game.getGameState() == GAME_STATE_SHUTDOWN)
	{
		getConnection()->close();
		return false;
	}

	uint32_t clientIp = getConnection()->getIP();
	msg.SkipBytes(2); // operating system
	uint16_t version = msg.GetU16();
	if(!RSA_decrypt(msg))
	{
		getConnection()->close();
		return false;
	}

	uint32_t key[4] = {msg.GetU32(), msg.GetU32(), msg.GetU32(), msg.GetU32()};
	enableXTEAEncryption();
	setXTEAKey(key);

	uint8_t action = msg.GetByte();
	std::string account = msg.GetString(), password = msg.GetString(), name;
	uint8_t sex = 0;
	if(action == ACTION_CREATE_CHARACTER)
	{
		name = msg.GetString();
		sex = msg.GetByte();
	}
	else if(action == ACTION_DELETE_CHARACTER)
		name = msg.GetString();

	if(version < CLIENT_VERSION_MIN || version > CLIENT_VERSION_MAX)
	{
		reply(false, CLIENT_VERSION_STRING);
		return false;
	}

	if(g_game.getGameState() < GAME_STATE_NORMAL)
	{
		reply(false, "Server is just starting up, please wait.");
		return false;
	}

	Dispatcher::getInstance().addTask(createTask(boost::bind(&ProtocolAccount::handleRequest, this,
		clientIp, action, account, password, name, sex)));
	return true;
}

void ProtocolAccount::handleRequest(uint32_t clientIp, uint8_t action, std::string account, std::string password,
	std::string name, uint8_t sex)
{
	if(!getConnection())
		return;

	if(ConnectionManager::getInstance()->isDisabled(clientIp, protocolId))
	{
		reply(false, "Too many attempts from your IP address, please try again later.");
		return;
	}

	if(IOBan::getInstance()->isIpBanished(clientIp))
	{
		reply(false, "Your IP is banished!");
		return;
	}

	trimString(account);
	toLowerCaseString(account);
	bool success = false;
	if(action == ACTION_CREATE_ACCOUNT)
	{
		std::string message = createAccount(clientIp, account, password, success);
		reply(success, message);
		return;
	}

	if(action != ACTION_CREATE_CHARACTER && action != ACTION_DELETE_CHARACTER)
	{
		reply(false, "Unknown request.");
		return;
	}

	uint32_t accountId = 0;
	if(account.empty() || account == "1" || !IOLoginData::getInstance()->getAccountId(account, accountId))
	{
		ConnectionManager::getInstance()->addAttempt(clientIp, protocolId, false);
		reply(false, "Invalid account name.");
		return;
	}

	Account acc = IOLoginData::getInstance()->loadAccount(accountId);
	if(!encryptTest(password, acc.password))
	{
		ConnectionManager::getInstance()->addAttempt(clientIp, protocolId, false);
		reply(false, "Invalid password.");
		return;
	}

	ConnectionManager::getInstance()->addAttempt(clientIp, protocolId, true);
	Ban ban;
	ban.value = accountId;
	ban.type = BAN_ACCOUNT;
	if(IOBan::getInstance()->getData(ban) && !IOLoginData::getInstance()->hasFlag(accountId, PlayerFlag_CannotBeBanned))
	{
		reply(false, "Your account is banished.");
		return;
	}

	if(action == ACTION_CREATE_CHARACTER)
	{
		if(acc.charList.size() >= MAX_CHARACTERS_PER_ACCOUNT)
		{
			std::ostringstream ss;
			ss << "Your account already has " << MAX_CHARACTERS_PER_ACCOUNT << " characters, the maximum.";
			reply(false, ss.str());
			return;
		}

		std::string message = createCharacter(accountId, name, sex, success);
		reply(success, message);
	}
	else
	{
		std::string message = deleteCharacter(accountId, name, success);
		reply(success, message);
	}
}

std::string ProtocolAccount::createAccount(uint32_t clientIp, const std::string& account, const std::string& password, bool& success)
{
	success = false;
	if(account.length() < 3 || account.length() > 25)
		return "The account name must be 3 to 25 characters long.";

	if(!isValidAccountName(account))
		return "The account name may only contain letters and numbers.";

	if(password.length() < 6 || password.length() > 29)
		return "The password must be 6 to 29 characters long.";

	if(!isValidPassword(password))
		return "The password contains characters that are not allowed.";

	if(asLowerCaseString(password) == account)
		return "The password must be different from the account name.";

	if(IOLoginData::getInstance()->accountNameExists(account))
		return "An account with that name already exists.";

	time_t now = time(NULL);
	std::list<time_t>& created = createdAccounts[clientIp];
	while(!created.empty() && now - created.front() > ACCOUNTS_PER_IP_WINDOW)
		created.pop_front();

	if(created.size() >= MAX_ACCOUNTS_PER_IP)
		return "Too many accounts were created from your IP address, please try again later.";

	if(!IOLoginData::getInstance()->createAccount(account, password))
		return "The account could not be created, please try again.";

	created.push_back(now);
	success = true;
	return "Your account has been created. You can now log in and create your first character.";
}

std::string ProtocolAccount::createCharacter(uint32_t accountId, std::string name, uint8_t sex, bool& success)
{
	success = false;
	trimString(name);
	if(name.length() < 4 || name.length() > 20)
		return "The character name must be 4 to 20 characters long.";

	if(!isValidName(name))
		return "The character name must start with a capital letter and may only contain letters, single spaces, ' and -.";

	std::string lowerName = asLowerCaseString(name);
	if(lowerName.substr(0, 4) == "god " || lowerName.substr(0, 3) == "cm " || lowerName.substr(0, 3) == "gm "
		|| lowerName == "account manager")
		return "That name is reserved, please choose another one.";

	if(IOLoginData::getInstance()->playerExists(name, true, false))
		return "A character with that name already exists.";

	if(sex > 1)
		return "Please choose female or male.";

	Database* db = Database::getInstance();
	DBQuery query;
	query << "CALL `pokeverse_add_character`(" << accountId << ", " << db->escapeString(name) << ", " << (uint32_t)sex << ")";
	if(!db->executeQuery(query.str()))
		return "The character could not be created, please try again.";

	success = true;
	return "Your character " + name + " has been created. Log in to start the tutorial.";
}

std::string ProtocolAccount::deleteCharacter(uint32_t accountId, const std::string& name, bool& success)
{
	success = false;
	switch(IOLoginData::getInstance()->deleteCharacter(accountId, name))
	{
		case DELETE_SUCCESS:
			success = true;
			return "The character " + name + " has been deleted.";
		case DELETE_ONLINE:
			return "You cannot delete a character that is online.";
		case DELETE_HOUSE:
			return "You cannot delete a character that owns a house.";
		case DELETE_LEADER:
			return "You cannot delete a character that leads a guild.";
		default:
			break;
	}

	return "The character could not be deleted.";
}
