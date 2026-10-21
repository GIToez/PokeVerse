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
#include "discordbridge.h"
#include "outfit.h"
#include "accountemail.h"

extern ConfigManager g_config;
extern Game g_game;

namespace
{
	const uint32_t MAX_ACCOUNTS_PER_IP = 3;
	const time_t ACCOUNTS_PER_IP_WINDOW = 3600;
	// last entry of the client's outfit color table
	const uint8_t MAX_OUTFIT_COLOR = 132;

	const uint32_t MAX_RECOVER_REQUESTS_PER_IP = 5;
	const time_t RECOVER_REQUESTS_WINDOW = 3600;

	// Accounts created and password resets asked for per client IP; dispatcher thread only.
	std::map<uint32_t, std::list<time_t> > createdAccounts;
	std::map<uint32_t, std::list<time_t> > recoverRequests;

	std::string passwordProblem(const std::string& account, const std::string& password)
	{
		if(password.length() < 8 || password.length() > 29)
			return "The password must be 8 to 29 characters long.";

		if(!isValidPassword(password))
			return "The password contains characters that are not allowed.";

		if(isCommonPassword(password))
			return "That password is too common, please choose another one.";

		if(asLowerCaseString(password) == account)
			return "The password must be different from the account name.";

		return "";
	}
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

	Request request;
	request.ip = getConnection()->getIP();
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

	request.action = msg.GetByte();
	request.account = msg.GetString();
	request.password = msg.GetString();
	switch(request.action)
	{
		case ACTION_CREATE_CHARACTER:
			request.text = msg.GetString();
			request.sex = msg.GetByte();
			if(version >= CLIENT_VERSION_SELECT_INFO)
			{
				request.outfit.lookType = msg.GetU16();
				request.outfit.lookHead = msg.GetByte();
				request.outfit.lookBody = msg.GetByte();
				request.outfit.lookLegs = msg.GetByte();
				request.outfit.lookFeet = msg.GetByte();
			}
			break;
		case ACTION_EMAIL_CHANGE_CONFIRM:
			request.text = msg.GetString();
			request.text2 = msg.GetString();
			break;
		case ACTION_CREATE_ACCOUNT:
		case ACTION_DELETE_CHARACTER:
		case ACTION_VERIFY_EMAIL:
		case ACTION_SET_EMAIL:
		case ACTION_RECOVER_RESET:
		case ACTION_CHANGE_PASSWORD:
		case ACTION_EMAIL_CHANGE_REQUEST:
			request.text = msg.GetString();
			break;
		default:
			break;
	}

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

	Dispatcher::getInstance().addTask(createTask(boost::bind(&ProtocolAccount::handleRequest, this, request)));
	return true;
}

void ProtocolAccount::handleRequest(Request request)
{
	if(!getConnection())
		return;

	if(ConnectionManager::getInstance()->isDisabled(request.ip, protocolId))
	{
		reply(false, "Too many attempts from your IP address, please try again later.");
		return;
	}

	if(IOBan::getInstance()->isIpBanished(request.ip))
	{
		reply(false, "Your IP is banished!");
		return;
	}

	if(request.action == ACTION_SERVER_STATUS)
	{
		reply(true, std::to_string(g_game.getPlayersOnline()));
		return;
	}

	trimString(request.account);
	toLowerCaseString(request.account);
	bool success = false;
	std::string message;
	switch(request.action)
	{
		case ACTION_CREATE_ACCOUNT:
			message = createAccount(request, success);
			reply(success, message);
			return;
		case ACTION_RECOVER_REQUEST:
			message = recoverRequest(request, success);
			reply(success, message);
			return;
		case ACTION_RECOVER_RESET:
			message = recoverReset(request, success);
			reply(success, message);
			return;
		case ACTION_CREATE_CHARACTER:
		case ACTION_DELETE_CHARACTER:
		case ACTION_VERIFY_EMAIL:
		case ACTION_RESEND_CODE:
		case ACTION_SET_EMAIL:
		case ACTION_CHANGE_PASSWORD:
		case ACTION_EMAIL_CHANGE_REQUEST:
		case ACTION_EMAIL_CHANGE_CONFIRM:
		case ACTION_ACCOUNT_INFO:
			break;
		default:
			reply(false, "Unknown request.");
			return;
	}

	uint32_t accountId = 0;
	if(request.account.empty() || request.account == "1" || !IOLoginData::getInstance()->getAccountId(request.account, accountId))
	{
		ConnectionManager::getInstance()->addAttempt(request.ip, protocolId, false);
		reply(false, "Invalid account name.");
		return;
	}

	Account acc = IOLoginData::getInstance()->loadAccount(accountId);
	uint32_t lockedSeconds = 0;
	PasswordCheck_t check = IOLoginData::getInstance()->checkPassword(accountId, request.password, acc.password, lockedSeconds, request.ip);
	if(check != PASSWORD_OK)
	{
		ConnectionManager::getInstance()->addAttempt(request.ip, protocolId, false);
		reply(false, check == PASSWORD_LOCKED ? IOLoginData::lockedMessage(lockedSeconds) : "Invalid password.");
		return;
	}

	ConnectionManager::getInstance()->addAttempt(request.ip, protocolId, true);
	Ban ban;
	ban.value = accountId;
	ban.type = BAN_ACCOUNT;
	if(IOBan::getInstance()->getData(ban) && !IOLoginData::getInstance()->hasFlag(accountId, PlayerFlag_CannotBeBanned))
	{
		reply(false, "Your account is banished.");
		return;
	}

	if(request.action == ACTION_CREATE_CHARACTER)
	{
		const uint32_t maxCharacters = std::max<int32_t>(1, g_config.getNumber(ConfigManager::MAX_CHARACTERS_PER_ACCOUNT));
		if(acc.charList.size() >= maxCharacters)
		{
			std::ostringstream ss;
			ss << "Your account already has " << maxCharacters << " characters, the maximum.";
			reply(false, ss.str());
			return;
		}
	}

	message = handleAccountRequest(request, accountId, success);
	reply(success, message);
}

std::string ProtocolAccount::handleAccountRequest(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	switch(request.action)
	{
		case ACTION_CREATE_CHARACTER:
		{
			std::string block = AccountEmail::loginBlock(accountId);
			if(!block.empty())
				return block;

			return createCharacter(accountId, request.text, request.sex, request.outfit, success);
		}
		case ACTION_DELETE_CHARACTER:
			return deleteCharacter(accountId, request.text, success);
		case ACTION_VERIFY_EMAIL:
			return verifyEmail(request, accountId, success);
		case ACTION_RESEND_CODE:
			return resendCode(request, accountId, success);
		case ACTION_SET_EMAIL:
			return setEmail(request, accountId, success);
		case ACTION_CHANGE_PASSWORD:
			return changePassword(request, accountId, success);
		case ACTION_EMAIL_CHANGE_REQUEST:
			return emailChangeRequest(request, accountId, success);
		case ACTION_EMAIL_CHANGE_CONFIRM:
			return emailChangeConfirm(request, accountId, success);
		case ACTION_ACCOUNT_INFO:
			return accountInfo(accountId, success);
		default:
			break;
	}

	return "Unknown request.";
}

std::string ProtocolAccount::createAccount(const Request& request, bool& success)
{
	success = false;
	const std::string& account = request.account;
	if(account.length() < 3 || account.length() > 25)
		return "The account name must be 3 to 25 characters long.";

	if(!isValidAccountName(account))
		return "The account name may only contain letters and numbers.";

	std::string problem = passwordProblem(account, request.password);
	if(!problem.empty())
		return problem;

	std::string email = asLowerCaseString(request.text);
	trimString(email);
	bool required = g_config.getBool(ConfigManager::EMAIL_REQUIRED);
	if(email.empty() && required)
		return "Please enter your email. If there is no email field, update the game first.";

	if(!email.empty())
	{
		if(!AccountEmail::isValidEmail(email))
			return "Please enter a valid email address (at most 50 characters).";

		if(AccountEmail::isEmailTaken(email, 0))
			return "That email is already used by another account.";
	}

	if(IOLoginData::getInstance()->accountNameExists(account))
		return "An account with that name already exists.";

	time_t now = time(NULL);
	std::list<time_t>& created = createdAccounts[request.ip];
	while(!created.empty() && now - created.front() > ACCOUNTS_PER_IP_WINDOW)
		created.pop_front();

	if(created.size() >= MAX_ACCOUNTS_PER_IP)
		return "Too many accounts were created from your IP address, please try again later.";

	uint32_t accountId = (uint32_t)IOLoginData::getInstance()->createAccount(account, request.password);
	if(!accountId)
		return "The account could not be created, please try again.";

	Database* db = Database::getInstance();
	DBQuery query;
	query << "UPDATE `accounts` SET `email` = " << db->escapeString(email) << ", `created_at` = " << now << ", `signup_pending` = "
		<< (required ? 1 : 0) << " WHERE `id` = " << accountId;
	db->executeQuery(query.str());

	created.push_back(now);
	success = true;
	AccountEmail::log(accountId, request.ip, "created");
	if(email.empty())
		return "Your account has been created. You can now log in and create your first character.";

	AccountEmail::State state;
	AccountEmail::loadState(accountId, state);
	AccountEmail::sendCode(state, AccountEmail::CODE_VERIFY, email, email);
	return AccountEmail::VERIFY_MARKER + "Your account has been created. Enter the 6-digit code we sent to " + email
		+ (required ? " to start playing." : " to verify your email.");
}

std::string ProtocolAccount::recoverRequest(const Request& request, bool& success)
{
	success = false;
	time_t now = time(NULL);
	std::list<time_t>& requests = recoverRequests[request.ip];
	while(!requests.empty() && now - requests.front() > RECOVER_REQUESTS_WINDOW)
		requests.pop_front();

	if(requests.size() >= MAX_RECOVER_REQUESTS_PER_IP)
		return "Too many requests from your IP address, please try again later.";

	if(request.account.empty())
		return "Enter your account name or your email.";

	requests.push_back(now);
	uint32_t accountId = 0;
	if(request.account.find('@') != std::string::npos)
	{
		Database* db = Database::getInstance();
		DBQuery query;
		query << "SELECT `id` FROM `accounts` WHERE `email` = " << db->escapeString(request.account) << " AND `email_verified` = 1 LIMIT 1";
		if(DBResult* result = db->storeQuery(query.str()))
		{
			accountId = result->getDataInt("id");
			result->free();
		}
	}
	else
		IOLoginData::getInstance()->getAccountId(request.account, accountId);

	// the same answer whether or not the account exists
	AccountEmail::State state;
	if(accountId > 1 && AccountEmail::loadState(accountId, state) && state.verified && !state.email.empty()
		&& AccountEmail::sendCode(state, AccountEmail::CODE_RESET, state.email, "").empty())
		AccountEmail::log(accountId, request.ip, "reset_requested");

	success = true;
	return "If that account has a verified email, we sent a code to it. It is valid for 15 minutes.";
}

std::string ProtocolAccount::recoverReset(const Request& request, bool& success)
{
	success = false;
	const std::string wrong = "That code is not right or has expired. Ask for a new one.";
	std::string problem = passwordProblem(request.account, request.password);
	if(!problem.empty())
		return problem;

	uint32_t accountId = 0;
	if(request.account.empty() || request.account == "1" || !IOLoginData::getInstance()->getAccountId(request.account, accountId))
	{
		ConnectionManager::getInstance()->addAttempt(request.ip, protocolId, false);
		return wrong;
	}

	std::string unused;
	AccountEmail::CodeCheck_t check = AccountEmail::checkCode(accountId, AccountEmail::CODE_RESET, request.text, unused);
	if(check != AccountEmail::CODE_OK)
	{
		ConnectionManager::getInstance()->addAttempt(request.ip, protocolId, false);
		return check == AccountEmail::CODE_MISSING ? wrong : AccountEmail::codeMessage(check);
	}

	if(!IOLoginData::getInstance()->setPassword(accountId, request.password))
		return "The password could not be changed, please try again.";

	Database* db = Database::getInstance();
	DBQuery query;
	query << "UPDATE `accounts` SET `login_failures` = 0, `login_locked_until` = 0 WHERE `id` = " << accountId;
	db->executeQuery(query.str());
	AccountEmail::removeCode(accountId, AccountEmail::CODE_RESET);
	AccountEmail::log(accountId, request.ip, "password_reset");

	AccountEmail::State state;
	if(AccountEmail::loadState(accountId, state) && state.verified)
		AccountEmail::notify(state.email, "Your PokeVerse password was reset", "The password of the PokeVerse account \"" + state.name
			+ "\" was reset with a code sent to this email.\nIf this wasn't you, reset it again with Forgot password and tell us on Discord.\n");

	success = true;
	return "Your password has been changed. You can log in now.";
}

std::string ProtocolAccount::verifyEmail(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	AccountEmail::State state;
	if(!AccountEmail::loadState(accountId, state))
		return "Your account could not be loaded, please try again.";

	if(state.verified)
		return "Your email is already verified.";

	std::string email;
	AccountEmail::CodeCheck_t check = AccountEmail::checkCode(accountId, AccountEmail::CODE_VERIFY, request.text, email);
	if(check != AccountEmail::CODE_OK)
		return AccountEmail::codeMessage(check);

	if(AccountEmail::isEmailTaken(email, accountId))
	{
		AccountEmail::removeCode(accountId, AccountEmail::CODE_VERIFY);
		return AccountEmail::ADD_MARKER + "That email is now used by another account. Please add a different one.";
	}

	Database* db = Database::getInstance();
	DBQuery query;
	query << "UPDATE `accounts` SET `email` = " << db->escapeString(email) << ", `email_verified` = 1, `signup_pending` = 0 WHERE `id` = " << accountId;
	if(!db->executeQuery(query.str()))
		return "Your email could not be saved, please try again.";

	AccountEmail::removeCode(accountId, AccountEmail::CODE_VERIFY);
	AccountEmail::log(accountId, request.ip, "email_verified");
	success = true;
	if(state.pending)
		return "Your email is verified and your account is ready. Have fun!";

	return "Your email is verified. Thank you!";
}

std::string ProtocolAccount::setEmail(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	AccountEmail::State state;
	if(!AccountEmail::loadState(accountId, state))
		return "Your account could not be loaded, please try again.";

	if(state.verified)
		return "Your account already has a verified email. Use Change email in the Account window.";

	std::string email = asLowerCaseString(request.text);
	trimString(email);
	if(!AccountEmail::isValidEmail(email))
		return "Please enter a valid email address (at most 50 characters).";

	if(AccountEmail::isEmailTaken(email, accountId))
		return "That email is already used by another account.";

	std::string error = AccountEmail::sendCode(state, AccountEmail::CODE_VERIFY, email, email);
	if(!error.empty())
		return error;

	Database* db = Database::getInstance();
	DBQuery query;
	query << "UPDATE `accounts` SET `email` = " << db->escapeString(email) << " WHERE `id` = " << accountId;
	db->executeQuery(query.str());
	AccountEmail::log(accountId, request.ip, "email_added", email);

	success = true;
	return AccountEmail::VERIFY_MARKER + "We sent a 6-digit code to " + email + ".";
}

std::string ProtocolAccount::resendCode(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	AccountEmail::State state;
	if(!AccountEmail::loadState(accountId, state))
		return "Your account could not be loaded, please try again.";

	if(state.verified)
		return "Your email is already verified.";

	std::string email = state.pendingEmail.empty() ? state.email : state.pendingEmail;
	if(email.empty())
		return AccountEmail::ADD_MARKER + "Your account has no email yet. Please add one.";

	std::string error = AccountEmail::sendCode(state, AccountEmail::CODE_VERIFY, email, email);
	if(!error.empty())
		return error;

	success = true;
	return AccountEmail::VERIFY_MARKER + "We sent a new code to " + email + ".";
}

std::string ProtocolAccount::changePassword(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	std::string problem = passwordProblem(request.account, request.text);
	if(!problem.empty())
		return problem;

	if(request.text == request.password)
		return "The new password must be different from the current one.";

	if(!IOLoginData::getInstance()->setPassword(accountId, request.text))
		return "The password could not be changed, please try again.";

	AccountEmail::log(accountId, request.ip, "password_changed");
	AccountEmail::State state;
	if(AccountEmail::loadState(accountId, state) && state.verified)
		AccountEmail::notify(state.email, "Your PokeVerse password was changed", "The password of the PokeVerse account \"" + state.name
			+ "\" was changed in the game.\nIf this wasn't you, set a new one with Forgot password on the login screen.\n");

	success = true;
	return "Your password has been changed.";
}

std::string ProtocolAccount::emailChangeRequest(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	AccountEmail::State state;
	if(!AccountEmail::loadState(accountId, state))
		return "Your account could not be loaded, please try again.";

	if(!state.verified)
		return AccountEmail::ADD_MARKER + "Your account has no verified email yet. Please add one.";

	std::string email = asLowerCaseString(request.text);
	trimString(email);
	if(!AccountEmail::isValidEmail(email))
		return "Please enter a valid email address (at most 50 characters).";

	if(email == state.email)
		return "That is already your email.";

	if(AccountEmail::isEmailTaken(email, accountId))
		return "That email is already used by another account.";

	std::string error = AccountEmail::sendCode(state, AccountEmail::CODE_EMAIL_CHANGE, state.email, email);
	if(error.empty())
		error = AccountEmail::sendCode(state, AccountEmail::CODE_VERIFY, email, email);

	if(!error.empty())
		return error;

	AccountEmail::log(accountId, request.ip, "email_change_requested", email);
	success = true;
	return AccountEmail::CHANGE_MARKER + "We sent a code to your current email " + state.email + " and one to " + email
		+ ". Enter both to finish.";
}

std::string ProtocolAccount::emailChangeConfirm(const Request& request, uint32_t accountId, bool& success)
{
	success = false;
	AccountEmail::State state;
	if(!AccountEmail::loadState(accountId, state))
		return "Your account could not be loaded, please try again.";

	if(!state.verified)
		return AccountEmail::ADD_MARKER + "Your account has no verified email yet. Please add one.";

	std::string email, verifiedEmail;
	AccountEmail::CodeCheck_t check = AccountEmail::checkCode(accountId, AccountEmail::CODE_EMAIL_CHANGE, request.text, email);
	if(check != AccountEmail::CODE_OK)
		return "Code from your current email: " + AccountEmail::codeMessage(check);

	check = AccountEmail::checkCode(accountId, AccountEmail::CODE_VERIFY, request.text2, verifiedEmail);
	if(check != AccountEmail::CODE_OK)
		return "Code from the new email: " + AccountEmail::codeMessage(check);

	if(verifiedEmail != email)
	{
		AccountEmail::removeCode(accountId, AccountEmail::CODE_EMAIL_CHANGE);
		AccountEmail::removeCode(accountId, AccountEmail::CODE_VERIFY);
		return "Those codes are for different emails. Please start again.";
	}

	AccountEmail::removeCode(accountId, AccountEmail::CODE_EMAIL_CHANGE);
	AccountEmail::removeCode(accountId, AccountEmail::CODE_VERIFY);
	if(AccountEmail::isEmailTaken(email, accountId))
		return "That email is now used by another account.";

	Database* db = Database::getInstance();
	DBQuery query;
	query << "UPDATE `accounts` SET `email` = " << db->escapeString(email) << ", `email_verified` = 1 WHERE `id` = " << accountId;
	if(!db->executeQuery(query.str()))
		return "Your email could not be saved, please try again.";

	AccountEmail::log(accountId, request.ip, "email_changed", state.email + " to " + email);
	AccountEmail::notify(state.email, "Your PokeVerse email was changed", "The email of the PokeVerse account \"" + state.name
		+ "\" was changed to " + email + ".\nIf this wasn't you, tell us on Discord right away.\n");

	success = true;
	return "Your email is now " + email + ".";
}

std::string ProtocolAccount::accountInfo(uint32_t accountId, bool& success)
{
	success = false;
	AccountEmail::State state;
	if(!AccountEmail::loadState(accountId, state))
		return "Your account could not be loaded, please try again.";

	std::ostringstream ss;
	ss << "email=" << state.email << "\n"
		<< "verified=" << (state.verified ? 1 : 0) << "\n"
		<< "pending=" << state.pendingEmail << "\n"
		<< "signup=" << (state.pending ? 1 : 0) << "\n"
		<< "daysLeft=" << AccountEmail::graceDaysLeft(state) << "\n"
		<< "required=" << (g_config.getBool(ConfigManager::EMAIL_REQUIRED) ? 1 : 0) << "\n"
		<< "recovery=" << (!state.recoveryKey.empty() && state.recoveryKey != "0" ? 1 : 0) << "\n"
		<< "discord=" << (state.discord ? 1 : 0);
	success = true;
	return ss.str();
}

std::string ProtocolAccount::createCharacter(uint32_t accountId, std::string name, uint8_t sex, const Outfit_t& outfit, bool& success)
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

	if(outfit.lookType)
	{
		bool starter = false;
		OutfitList starters = Outfits::getInstance()->getStarterOutfits(sex);
		for(OutfitList::const_iterator it = starters.begin(); it != starters.end() && !starter; ++it)
			starter = it->lookType == outfit.lookType;

		if(!starter)
			return "That outfit is not available for new characters.";

		if(outfit.lookHead > MAX_OUTFIT_COLOR || outfit.lookBody > MAX_OUTFIT_COLOR
			|| outfit.lookLegs > MAX_OUTFIT_COLOR || outfit.lookFeet > MAX_OUTFIT_COLOR)
			return "Please choose valid outfit colors.";
	}

	Database* db = Database::getInstance();
	DBQuery query;
	query << "CALL `pokeverse_add_character`(" << accountId << ", " << db->escapeString(name) << ", " << (uint32_t)sex << ")";
	if(!db->executeQuery(query.str()))
		return "The character could not be created, please try again.";

	if(outfit.lookType)
	{
		query.str("");
		query << "UPDATE `players` SET `looktype` = " << outfit.lookType << ", `lookhead` = " << (uint32_t)outfit.lookHead
			<< ", `lookbody` = " << (uint32_t)outfit.lookBody << ", `looklegs` = " << (uint32_t)outfit.lookLegs
			<< ", `lookfeet` = " << (uint32_t)outfit.lookFeet << " WHERE `account_id` = " << accountId
			<< " AND `name` " << db->getStringComparison() << db->escapeString(name) << " AND `deleted` = 0";
		db->executeQuery(query.str());
	}

	success = true;
	DiscordBridge::getInstance()->onAccountCharactersChanged(accountId, "created", name);
	return "Your character " + name + " has been created. Log in to start the tutorial.";
}

std::string ProtocolAccount::deleteCharacter(uint32_t accountId, const std::string& name, bool& success)
{
	success = false;
	switch(IOLoginData::getInstance()->deleteCharacter(accountId, name))
	{
		case DELETE_SUCCESS:
			success = true;
			DiscordBridge::getInstance()->onAccountCharactersChanged(accountId, "deleted", name);
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
