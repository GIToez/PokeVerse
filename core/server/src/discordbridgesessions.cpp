////////////////////////////////////////////////////////////////////////
// PokeVerse - player sessions for the Discord bridge (admin activity log)
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
// Kept apart from discordbridge.cpp: the game's RSA class clashes with OpenSSL's RSA typedef.
#include "otpch.h"

#include "discordbridge.h"
#include "configmanager.h"
#include "game.h"
#include "player.h"
#include "database.h"

extern ConfigManager g_config;
extern Game g_game;

namespace
{
	const char* clientOsName(OperatingSystem_t os)
	{
		switch(os)
		{
			case CLIENTOS_LINUX: return "linux";
			case CLIENTOS_WINDOWS: return "windows";
			case CLIENTOS_FLASH: return "flash";
			case CLIENTOS_OTCLIENT_WINDOWS: return "otclient-windows";
			case CLIENTOS_OTCLIENT_LINUX: return "otclient-linux";
			case CLIENTOS_OTCLIENT_MAC: return "otclient-mac";
			default: return "unknown";
		}
	}

	bool knownLogoutReason(const std::string& reason)
	{
		return reason == "logout" || reason == "connection_lost" || reason == "timeout" || reason == "kick"
			|| reason == "death" || reason == "shutdown" || reason == "server_closed";
	}

}

void DiscordBridge::onPlayerLogin(Player* player)
{
	if(!m_enabled || !player || !g_config.getBool(ConfigManager::DISCORD_BRIDGE_PLAYER_SESSIONS))
		return;

	PlayerSession session;
	std::ostringstream id;
	id << m_bootId << "-s" << ++m_sessionSequence;
	session.id = id.str();
	session.loginTime = time(NULL);
	m_playerSessions[player->getGUID()] = session;

	std::ostringstream event;
	event << "{\"kind\":\"player_login\",\"scope\":\"admin\",\"sessionId\":\"" << session.id
		<< "\",\"character\":\"" << escapeJson(player->getName()) << "\",\"level\":" << player->getLevel()
		<< ",\"accountId\":" << player->getAccount() << ",\"loginTime\":" << session.loginTime;
	if(g_config.getBool(ConfigManager::DISCORD_BRIDGE_SESSION_IPS))
		event << ",\"ip\":\"" << convertIPAddress(player->getIP()) << "\"";

	event << ",\"clientOs\":\"" << clientOsName(player->getOperatingSystem()) << "\",\"clientVersion\":"
		<< player->getClientVersion() << ",\"playersOnline\":" << g_game.getPlayersOnline() << "}";
	emitEvent(event.str());
}

void DiscordBridge::setLogoutReason(Player* player, const std::string& reason)
{
	if(!player || !knownLogoutReason(reason))
		return;

	std::map<uint32_t, PlayerSession>::iterator it = m_playerSessions.find(player->getGUID());
	if(it != m_playerSessions.end() && it->second.reason.empty())
		it->second.reason = reason;
}

void DiscordBridge::onPlayerRemoved(Player* player)
{
	if(!player)
		return;

	std::map<uint32_t, PlayerSession>::iterator it = m_playerSessions.find(player->getGUID());
	if(it == m_playerSessions.end())
		return;

	PlayerSession session = it->second;
	m_playerSessions.erase(it);

	time_t now = time(NULL);
	std::ostringstream event;
	event << "{\"kind\":\"player_logout\",\"scope\":\"admin\",\"sessionId\":\"" << session.id
		<< "\",\"character\":\"" << escapeJson(player->getName()) << "\",\"level\":" << player->getLevel()
		<< ",\"accountId\":" << player->getAccount() << ",\"loginTime\":" << session.loginTime
		<< ",\"logoutTime\":" << now << ",\"duration\":" << (now >= session.loginTime ? now - session.loginTime : 0);
	if(!session.reason.empty())
		event << ",\"reason\":\"" << session.reason << "\"";

	event << ",\"playersOnline\":" << g_game.getPlayersOnline() << "}";
	emitEvent(event.str());
}

std::string DiscordBridge::getSessionId(uint32_t playerGuid) const
{
	std::map<uint32_t, PlayerSession>::const_iterator it = m_playerSessions.find(playerGuid);
	return it != m_playerSessions.end() ? it->second.id : "";
}

void DiscordBridge::onAccountCharactersChanged(uint32_t accountId, const std::string& change, const std::string& name)
{
	if(!m_enabled || !accountId || !g_config.getBool(ConfigManager::DISCORD_BRIDGE_ACCOUNT_LINKING))
		return;

	Database* db = Database::getInstance();
	DBQuery query;
	query << "SELECT `discord_user_id` FROM `discord_account_links` WHERE `account_id` = " << accountId << " LIMIT 1";
	DBResult* result;
	if(!(result = db->storeQuery(query.str())))
		return;

	std::string discordUserId = result->getDataString("discord_user_id");
	result->free();

	std::ostringstream event;
	event << "{\"kind\":\"account_characters\",\"scope\":\"account\",\"discordUserId\":\"" << escapeJson(discordUserId)
		<< "\",\"change\":\"" << change << "\",\"character\":\"" << escapeJson(name) << "\"}";
	emitEvent(event.str());
}
