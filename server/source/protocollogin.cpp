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
#include <iomanip>

#include "protocollogin.h"
#include "tools.h"
#include "rsa.h"

#include "iologindata.h"
#include "ioban.h"

#if defined(WINDOWS) && !defined(__CONSOLE__)
#include "gui.h"
#endif
#include "outputmessage.h"
#include "connection.h"

#include "configmanager.h"
#include "game.h"

#include "polls.h"

extern ConfigManager g_config;
extern Game g_game;

extern IpList serverIps;

#ifdef __ENABLE_SERVER_DIAGNOSTIC__
uint32_t ProtocolLogin::protocolLoginCount = 0;
#endif

void ProtocolLogin::deleteProtocolTask()
{
#ifdef __DEBUG_NET_DETAIL__
	std::cout << "Deleting ProtocolLogin" << std::endl;
#endif
	Protocol::deleteProtocolTask();
}

void ProtocolLogin::disconnectClient(uint8_t error, const char* message)
{
	OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false);
	if(output)
	{
		TRACK_MESSAGE(output);
		output->AddByte(error);
		output->AddString(message);
		OutputMessagePool::getInstance()->send(output);
	}

	getConnection()->close();
}

bool ProtocolLogin::parseFirstPacket(NetworkMessage& msg)
{
	if(
#if defined(WINDOWS) && !defined(__CONSOLE__)
		!GUI::getInstance()->m_connections ||
#endif
		g_game.getGameState() == GAME_STATE_SHUTDOWN)
	{
		getConnection()->close();
		return false;
	}

	uint32_t clientIp = getConnection()->getIP();
	uint16_t operatingSystem = msg.GetU16();/*msg.SkipBytes(2);*/
	uint16_t version = msg.GetU16();
	
	int16_t lang = -1;
    if ((operatingSystem >= CLIENTOS_OTCLIENT_WINDOWS && operatingSystem <= CLIENTOS_OTCLIENT_MAC) && version >= 293) {
        lang = msg.GetByte();
    }

	msg.SkipBytes(12);
	if(!RSA_decrypt(msg))
	{
		std::cout << "[Warning - Protocol::RSA_decrypt] IP: " << convertIPAddress(clientIp) << std::endl;
        getConnection()->close();
		return false;
	}

	uint32_t key[4] = {msg.GetU32(), msg.GetU32(), msg.GetU32(), msg.GetU32()};
	enableXTEAEncryption();
	setXTEAKey(key);

	if(version == 0xFC)
	{
		std::string name = msg.GetString(), password = msg.GetString(), characterName = msg.GetString();
		uint8_t pokemon = msg.GetByte();
		uint8_t sexo = msg.GetByte();
		uint8_t town = msg.GetByte();
		uint8_t world = msg.GetByte();
		std::string email = msg.GetString();
		if(name.empty() || password.empty())
		{
		    disconnectClient(0x0A, "Invalid account name.");
		    return false;
        }
		  
        if(IOLoginData::getInstance()->accountNameExists(name))
        {
            disconnectClient(0x0A, "Account name existing.");
            return false;
        }
		
		std::string managerString = characterName;
		trimString(managerString);
		if(managerString.length() < 4)
		{
			disconnectClient(0x0A, "Your name you want is too short, please select a longer name.");
			return false;
        }
		else if(managerString.length() > 20)
		{
			disconnectClient(0x0A, "The name you want is too long, please select a shorter name.");
			return false;
        }
		else if(!isValidName(managerString))
		{
			disconnectClient(0x0A, "That name seems to contain invalid symbols, please choose another name.");
			return false;
        }
		else if(IOLoginData::getInstance()->playerExists(managerString, true))
		{
			disconnectClient(0x0A, "A player with that name already exists, please choose another name.");
			return false;
        }
		else
		{
			std::string tmp = asLowerCaseString(managerString);
			if(tmp.substr(0, 4) == "god " && tmp.substr(0, 3) == "cm " && tmp.substr(0, 3) == "gm ")
			{
				disconnectClient(0x0A, "Your character is not a staff member, please tell me another name!");
			    return false;
            }
		}
        
        if(characterName.empty() || IOLoginData::getInstance()->playerExists(characterName))
        {
            disconnectClient(0x0A, "Character name existing.");
            return false;
        }
		
		xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "CreateAcc.xml").c_str());
		if(!doc)
		{
			//std::cout << "[Warning - Game::loadExperienceStages] Cannot load stages file." << std::endl;
			//std::cout << getLastXMLError() << std::endl;
			disconnectClient(0x0A, "Erro CreateAcc.xml report ao adm.");
			return false;
		}

		xmlNodePtr q, p, root = xmlDocGetRootElement(doc);
		if(xmlStrcmp(root->name, (const xmlChar*)"CreateAcc"))
		{
			//std::cout << "[Error - Game::loadExperienceStages] Malformed stages file" << std::endl;
			xmlFreeDoc(doc);
			disconnectClient(0x0A, "Erro town report ao adm.");
			return false;
		}
		int32_t intValue;
		std::string strValue;
		q = root->children;
		std::map<int32_t, int32_t> townXml;
		std::map<int32_t, int32_t> worldXml;
		while(q)
		{
			if(!xmlStrcmp(q->name, (const xmlChar*)"towns"))
			{
				p = q->children;
				while(p)
				{
					if(!xmlStrcmp(p->name, (const xmlChar*)"town"))
					{
						int32_t id;
						if(readXMLInteger(p, "otcId", intValue))
							id = intValue;

                    	if(id)
                   		{
					 	    if(readXMLInteger(p, "townId", intValue))
							    townXml[id] = intValue;
                   		}
					}

					p = p->next;
				}
			}
			if(!xmlStrcmp(q->name, (const xmlChar*)"worlds"))
			{
				p = q->children;
				while(p)
				{
					if(!xmlStrcmp(p->name, (const xmlChar*)"world"))
					{
						int32_t id;
						if(readXMLInteger(p, "otcId", intValue))
							id = intValue;

                    	if(id)
                   		{
					 	    if(readXMLInteger(p, "worldId", intValue))
							    worldXml[id] = intValue;
                   		}
					}

					p = p->next;
				}
			}
			q = q->next;
		}
		xmlFreeDoc(doc);
		
		if(!townXml[town])
			town = 1;
		else
			town = townXml[town];
		
		if(!worldXml[world])
			world = 0;
		else
			world = worldXml[world];
            
        IOLoginData::getInstance()->createAccount(name, password, email); 
        uint32_t id = 1;
	    if(IOLoginData::getInstance()->getAccountId(name, id))
	        IOLoginData::getInstance()->createCharacter(id, characterName, pokemon, sexo, town, world); 
	        
        disconnectClient(0x0A, "Create account sucess.");
			
		return false;
	}else if(version == 0xFD)
	{
        std::string name = msg.GetString(), characterName = msg.GetString();
		uint8_t pokemon = msg.GetByte();
		uint8_t sexo = msg.GetByte();
		uint8_t town = msg.GetByte();
		uint8_t world = msg.GetByte();
        uint32_t id = 1;
	    if(IOLoginData::getInstance()->getAccountId(name, id))
	    {
			std::string managerString = characterName;
			trimString(managerString);
			if(managerString.length() < 4)
			{
				disconnectClient(0x0A, "Your name you want is too short, please select a longer name.");
				return false;
            }
			else if(managerString.length() > 20)
			{
				disconnectClient(0x0A, "The name you want is too long, please select a shorter name.");
				return false;
            }
			else if(!isValidName(managerString))
			{
				disconnectClient(0x0A, "That name seems to contain invalid symbols, please choose another name.");
				return false;
            }
			else if(IOLoginData::getInstance()->playerExists(managerString, true))
			{
				disconnectClient(0x0A, "A player with that name already exists, please choose another name.");
				return false;
            }
			else
			{
				std::string tmp = asLowerCaseString(managerString);
				if(tmp.substr(0, 4) == "god " && tmp.substr(0, 3) == "cm " && tmp.substr(0, 3) == "gm ")
				{
					disconnectClient(0x0A, "Your character is not a staff member, please tell me another name!");
				    return false;
                }
			}
			
	        if(IOLoginData::getInstance()->createCharacter(id, characterName, pokemon, sexo, town, world))
	            disconnectClient(0x0A, "Create character Sucess.");
            else
                disconnectClient(0x0A, "Create character Fail.");
        }
	        	
		return false;
    }

	std::string name = msg.GetString(), password = msg.GetString();
	if(name.empty())
	{
		if(!g_config.getBool(ConfigManager::ACCOUNT_MANAGER))
		{
			disconnectClient(0x0A, "Invalid account name.");
			return false;
		}

		name = "1";
		password = "1";
	}

	if(version < CLIENT_VERSION_MIN || version > CLIENT_VERSION_MAX)
	{
		disconnectClient(0x0A, CLIENT_VERSION_STRING);
		return false;
	}

	if(g_game.getGameState() < GAME_STATE_NORMAL)
	{
		disconnectClient(0x0A, "Server is just starting up, please wait.");
		return false;
	}

	if(g_game.getGameState() == GAME_STATE_MAINTAIN)
	{
		disconnectClient(0x0A, "Server is under maintenance, please re-connect in a while.");
		return false;
	}

	if(ConnectionManager::getInstance()->isDisabled(clientIp, protocolId))
	{
		disconnectClient(0x0A, "Too many connections attempts from your IP address, please try again later.");
		return false;
	}

	if(IOBan::getInstance()->isIpBanished(clientIp))
	{
		disconnectClient(0x0A, "Your IP is banished!");
		return false;
	}

	uint32_t id = 1;
	if(!IOLoginData::getInstance()->getAccountId(name, id))
	{
		ConnectionManager::getInstance()->addAttempt(clientIp, protocolId, false);
		disconnectClient(0x0A, "Invalid account name.");
		return false;
	}

	Account account = IOLoginData::getInstance()->loadAccount(id);
	if(!encryptTest(password, account.password))
	{
		ConnectionManager::getInstance()->addAttempt(clientIp, protocolId, false);
		disconnectClient(0x0A, "Invalid password.");
		return false;
	}
	
	if (lang != -1 && lang != account.language) {
	    account.language = (LocalizationLang_t)lang;
	    IOLoginData::getInstance()->setAccountLanguage(account.number, (LocalizationLang_t)lang);
    }
	
	if (operatingSystem != account.client) {
	    account.client = operatingSystem;
	    IOLoginData::getInstance()->setAccountClient(account.number, operatingSystem);
    }

	Ban ban;
	ban.value = account.number;

	ban.type = BAN_ACCOUNT;
	if(IOBan::getInstance()->getData(ban) && !IOLoginData::getInstance()->hasFlag(account.number, PlayerFlag_CannotBeBanned))
	{
		bool deletion = ban.expires < 0;
		std::string name_ = "Automatic ";
		if(!ban.adminId)
			name_ += (deletion ? "deletion" : "banishment");
		else
			IOLoginData::getInstance()->getNameByGuid(ban.adminId, name_, true);

		char buffer[500 + ban.comment.length()];
		sprintf(buffer, "Your account has been %s at:\n%s by: %s,\nfor the following reason:\n%s.\nThe action taken was:\n%s.\nThe comment given was:\n%s.\nYour %s%s.",
			(deletion ? "deleted" : "banished"), formatDateShort(ban.added).c_str(), name_.c_str(),
			getReason(ban.reason).c_str(), getAction(ban.action, false).c_str(), ban.comment.c_str(),
			(deletion ? "account won't be undeleted" : "banishment will be lifted at:\n"),
			(deletion ? "." : formatDateShort(ban.expires, true).c_str()));

		disconnectClient(0x0A, buffer);
		return false;
	}

	//Remove premium days
	IOLoginData::getInstance()->removePremium(account);
	if(!g_config.getBool(ConfigManager::ACCOUNT_MANAGER) && !account.charList.size())
	{
		disconnectClient(0x0A, std::string("This account does not contain any character yet.\nCreate a new character on the "
			+ g_config.getString(ConfigManager::SERVER_NAME) + " website at " + g_config.getString(ConfigManager::URL) + ".").c_str());
		return false;
	}

	ConnectionManager::getInstance()->addAttempt(clientIp, protocolId, true);
	if(OutputMessage_ptr output = OutputMessagePool::getInstance()->getOutputMessage(this, false))
	{
		TRACK_MESSAGE(output);
		output->AddByte(0x14);

		char motd[1300];
		sprintf(motd, "%d\n%s", g_game.getMotdId(), g_config.getString(ConfigManager::MOTD).c_str());
		output->AddString(motd);

		uint32_t serverIp = serverIps[0].first;
		for(IpList::iterator it = serverIps.begin(); it != serverIps.end(); ++it)
		{
			if((it->first & it->second) != (clientIp & it->second))
				continue;

			serverIp = it->first;
			break;
		}

		//Add char list
		output->AddByte(0x64);
		if(g_config.getBool(ConfigManager::ACCOUNT_MANAGER) && id != 1)
		{
			output->AddByte(account.charList.size() + 1);
			output->AddString("Account Manager");
			output->AddString(g_config.getString(ConfigManager::SERVER_NAME));
			output->AddU32(serverIp);
			output->AddU16(g_config.getNumber(ConfigManager::GAME_PORT));
		}
		else
			output->AddByte((uint8_t)account.charList.size());

		for(Characters::iterator it = account.charList.begin(); it != account.charList.end(); it++)
		{
			#ifndef __LOGIN_SERVER__
			output->AddString((*it));
			if(g_config.getBool(ConfigManager::ON_OR_OFF_CHARLIST))
			{
				if(g_game.getPlayerByName((*it)))
					output->AddString("Online");
				else
					output->AddString("Offline");
			}
			else
				output->AddString(g_config.getString(ConfigManager::SERVER_NAME));

			output->AddU32(serverIp);
			output->AddU16(g_config.getNumber(ConfigManager::GAME_PORT));
			#else
			if(version < it->second->getVersionMin() || version > it->second->getVersionMax())
				continue;
			output->AddString(it->first);
			output->AddString(it->second->getName());
			output->AddU32(it->second->getAddress());
			output->AddU16(it->second->getPort());
			#endif

			if (operatingSystem >= CLIENTOS_OTCLIENT_WINDOWS && operatingSystem <= CLIENTOS_OTCLIENT_MAC) {
                #ifndef __LOGIN_SERVER__
                output->AddU16(IOLoginData::getInstance()->getPlayerLevel((*it)));
                output->AddByte(IOLoginData::getInstance()->getPlayerVocation((*it)));
                Outfit_t outfit = IOLoginData::getInstance()->getPlayerOutfit((*it));
                PokemonInfoList pokemonInfoList = IOLoginData::getInstance()->getPlayerPokemonTeam(*it);
                #else
                output->AddU16(IOLoginData::getInstance()->getPlayerLevel(it->first));
                output->AddByte(IOLoginData::getInstance()->getPlayerVocation((it->first)));
                Outfit_t outfit = IOLoginData::getInstance()->getPlayerOutfit(it->first);
                PokemonInfoList pokemonInfoList = IOLoginData::getInstance()->getPlayerPokemonTeam(it->first);
                #endif
                output->AddU16(outfit.lookType);
                output->AddByte(outfit.lookHead);
                output->AddByte(outfit.lookBody);
			    output->AddByte(outfit.lookLegs);
			    output->AddByte(outfit.lookFeet);
			    output->AddByte(outfit.lookAddons);
			    
			    output->AddByte(pokemonInfoList.size());
			    for(PokemonInfoList::const_iterator pInfoIt = pokemonInfoList.begin(); pInfoIt != pokemonInfoList.end(); ++pInfoIt) {
                    output->AddU16(pInfoIt->first);
                    output->AddString(pInfoIt->second);
                }
            }
		}

		//Add premium days
		if(g_config.getBool(ConfigManager::FREE_PREMIUM))
			output->AddU16(65535); //client displays free premium
		else
			output->AddU16(account.premiumDays);
			
		if (operatingSystem >= CLIENTOS_OTCLIENT_WINDOWS && operatingSystem <= CLIENTOS_OTCLIENT_MAC) {
            output->AddByte(Polls::getInstance()->getAvailablePollForAccount(account.number) ? true : false);
        }

		OutputMessagePool::getInstance()->send(output);
	}

	getConnection()->close();
	return true;
}
