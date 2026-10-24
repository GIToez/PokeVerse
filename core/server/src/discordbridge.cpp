////////////////////////////////////////////////////////////////////////
// PokeVerse - local bridge for the PokeVerse-Discord companion bot
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

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <openssl/crypto.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/rand.h>

#include "discordbridge.h"
#include "configmanager.h"
#include "database.h"
#include "globalevent.h"
#include "tasks.h"

extern ConfigManager g_config;
extern GlobalEvents* g_globalEvents;

namespace
{
	const size_t MAX_LINE_LENGTH = 16 * 1024;
	const size_t MAX_DIRECT_QUEUE = 500;
	const size_t MAX_SESSION_PENDING = 16;
	const int64_t AUTH_TIMEOUT = 10 * 1000;
	const int64_t PING_INTERVAL = 15 * 1000;
	const int64_t IDLE_TIMEOUT = 45 * 1000;

	std::string toHex(const unsigned char* data, size_t length)
	{
		static const char digits[] = "0123456789abcdef";
		std::string out;
		out.reserve(length * 2);
		for(size_t i = 0; i < length; ++i)
		{
			out += digits[data[i] >> 4];
			out += digits[data[i] & 0x0F];
		}

		return out;
	}

	std::string messageType(const std::string& line)
	{
		try
		{
			std::istringstream stream(line);
			boost::property_tree::ptree tree;
			boost::property_tree::read_json(stream, tree);
			return tree.get<std::string>("type", "");
		}
		catch(std::exception&) {}
		return "";
	}

	std::string jsonField(const std::string& line, const std::string& name)
	{
		try
		{
			std::istringstream stream(line);
			boost::property_tree::ptree tree;
			boost::property_tree::read_json(stream, tree);
			return tree.get<std::string>(name, "");
		}
		catch(std::exception&) {}
		return "";
	}
}

std::string DiscordBridge::escapeJson(const std::string& text)
{
	static const char digits[] = "0123456789abcdef";
	std::string out;
	out.reserve(text.size() + 8);
	for(std::string::const_iterator it = text.begin(); it != text.end(); ++it)
	{
		unsigned char c = (unsigned char)*it;
		if(c == '"')
			out += "\\\"";
		else if(c == '\\')
			out += "\\\\";
		else if(c == '\n')
			out += "\\n";
		else if(c == '\r')
			out += "\\r";
		else if(c == '\t')
			out += "\\t";
		else if(c < 0x20 || c >= 0x7F)
		{
			out += "\\u00";
			out += digits[c >> 4];
			out += digits[c & 0x0F];
		}
		else
			out += (char)c;
	}

	return out;
}

void DiscordBridge::start()
{
	if(m_running)
		return;

	if(!g_config.getBool(ConfigManager::DISCORD_BRIDGE_ENABLED))
	{
		std::cout << ">> Discord bridge disabled (discordBridgeEnabled = false)." << std::endl;
		return;
	}

	m_secret = g_config.getString(ConfigManager::DISCORD_BRIDGE_SECRET);
	if(m_secret.size() < 16)
	{
		std::cout << "[Warning - DiscordBridge] discordBridgeSecret must be at least 16 characters; the Discord bridge stays disabled." << std::endl;
		return;
	}

	std::string host = g_config.getString(ConfigManager::DISCORD_BRIDGE_HOST);
	int32_t port = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_PORT);
	if(port <= 0 || port > 0xFFFF)
	{
		std::cout << "[Warning - DiscordBridge] Invalid discordBridgePort; the Discord bridge stays disabled." << std::endl;
		return;
	}

	boost::system::error_code error;
	boost::asio::ip::address address = boost::asio::ip::make_address(host, error);
	if(error)
	{
		std::cout << "[Warning - DiscordBridge] discordBridgeHost must be an IP address (" << host << "); the Discord bridge stays disabled." << std::endl;
		return;
	}

	if(!address.is_loopback() && !g_config.getBool(ConfigManager::DISCORD_BRIDGE_ALLOW_REMOTE))
	{
		std::cout << "[Warning - DiscordBridge] discordBridgeHost " << host << " is not a loopback address and"
			" discordBridgeAllowRemote is false; the Discord bridge stays disabled." << std::endl;
		return;
	}

	int32_t lifetime = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_LINK_CODE_LIFETIME);
	m_linkCodeLifetime = lifetime > 0 ? lifetime : 600;

	int32_t queueSize = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_QUEUE_SIZE);
	m_maxQueue = queueSize > 0 ? queueSize : 2000;

	boost::asio::ip::tcp::endpoint endpoint(address, (uint16_t)port);
	m_acceptor.open(endpoint.protocol(), error);
	if(!error)
		m_acceptor.set_option(boost::asio::ip::tcp::acceptor::reuse_address(true), error);
	if(!error)
		m_acceptor.bind(endpoint, error);
	if(!error)
		m_acceptor.listen(4, error);
	if(error)
	{
		std::cout << "[Error - DiscordBridge] Cannot listen on " << host << ":" << port << " (" << error.message()
			<< "); the Discord bridge stays disabled. The game server keeps running." << std::endl;
		boost::system::error_code ignored;
		m_acceptor.close(ignored);
		return;
	}

	std::ostringstream bootId;
	bootId << time(NULL);
	m_bootId = bootId.str();

	m_enabled = m_running = true;
	accept();
	m_thread = boost::thread(boost::bind(&DiscordBridge::networkThread, this));
	std::cout << ">> Discord bridge listening on " << host << ":" << port << " (queue " << m_maxQueue << " events)." << std::endl;
}

void DiscordBridge::networkThread()
{
	while(m_running)
	{
		try
		{
			m_io.run();
			break;
		}
		catch(std::exception& e)
		{
			std::cout << "[Error - DiscordBridge] " << e.what() << std::endl;
		}
	}
}

bool DiscordBridge::hasPendingOutput()
{
	boost::mutex::scoped_lock lock(m_lock);
	return !m_events.empty() || !m_direct.empty();
}

void DiscordBridge::stop()
{
	if(!m_running)
		return;

	// Give a connected bot a short chance to receive the final shutdown events.
	for(int32_t i = 0; i < 40 && m_connected && hasPendingOutput(); ++i)
	{
		boost::asio::post(m_io, boost::bind(&DiscordBridge::flush, this));
		boost::this_thread::sleep(boost::posix_time::milliseconds(50));
	}

	if(m_connected)
		boost::this_thread::sleep(boost::posix_time::milliseconds(200));

	m_running = false;
	m_enabled = false;
	boost::asio::post(m_io, [this]()
	{
		boost::system::error_code ignored;
		m_acceptor.close(ignored);
		if(m_active)
			m_active->close();
	});

	m_work.reset();
	m_io.stop();
	if(m_thread.joinable())
		m_thread.join();

	m_connected = false;
	std::cout << ">> Discord bridge stopped." << std::endl;
}

DiscordBridgeStats DiscordBridge::getStats()
{
	boost::mutex::scoped_lock lock(m_lock);
	DiscordBridgeStats stats = m_stats;
	stats.queued = m_events.size();
	return stats;
}

bool DiscordBridge::emitEvent(const std::string& payload)
{
	if(!m_enabled || payload.size() < 2 || payload.size() > MAX_LINE_LENGTH
		|| payload[0] != '{' || payload[payload.size() - 1] != '}')
		return false;

	{
		boost::mutex::scoped_lock lock(m_lock);
		std::ostringstream envelope;
		envelope << "{\"type\":\"event\",\"id\":\"" << m_bootId << "-" << ++m_sequence
			<< "\",\"time\":" << time(NULL) << ",\"event\":" << payload << "}";
		m_events.push_back(envelope.str());
		while(m_events.size() > m_maxQueue)
		{
			m_events.pop_front();
			++m_stats.dropped;
		}
	}

	boost::asio::post(m_io, boost::bind(&DiscordBridge::flush, this));
	return true;
}

bool DiscordBridge::sendMessage(const std::string& message)
{
	if(!m_enabled || !m_connected || message.empty() || message.size() > MAX_LINE_LENGTH)
		return false;

	{
		boost::mutex::scoped_lock lock(m_lock);
		if(m_direct.size() >= MAX_DIRECT_QUEUE)
		{
			++m_stats.dropped;
			return false;
		}

		m_direct.push_back(message);
	}

	boost::asio::post(m_io, boost::bind(&DiscordBridge::flush, this));
	return true;
}

StringVec DiscordBridge::takeIncoming(uint32_t max)
{
	StringVec messages;
	boost::mutex::scoped_lock lock(m_lock);
	while(!m_incoming.empty() && messages.size() < max)
	{
		messages.push_back(m_incoming.front());
		m_incoming.pop_front();
		++m_taken;
	}

	return messages;
}

void DiscordBridge::flush()
{
	if(!m_active || !m_active->isAuthenticated() || !m_active->isOpen())
		return;

	while(m_active->pending() < MAX_SESSION_PENDING)
	{
		std::string message;
		{
			boost::mutex::scoped_lock lock(m_lock);
			if(!m_direct.empty())
			{
				message = m_direct.front();
				m_direct.pop_front();
			}
			else if(!m_events.empty())
			{
				message = m_events.front();
				m_events.pop_front();
			}
			else
				break;

			++m_stats.sent;
		}

		m_active->send(message);
	}
}

void DiscordBridge::accept()
{
	DiscordBridgeSession_ptr session(new DiscordBridgeSession(this));
	m_acceptor.async_accept(session->getSocket(),
		boost::bind(&DiscordBridge::handleAccept, this, session, boost::asio::placeholders::error));
}

void DiscordBridge::handleAccept(DiscordBridgeSession_ptr session, const boost::system::error_code& error)
{
	if(!m_running || !m_acceptor.is_open())
		return;

	if(!error)
		session->start();

	accept();
}

bool DiscordBridge::verifyAuth(const std::string& nonce, const std::string& hexMac) const
{
	unsigned char digest[EVP_MAX_MD_SIZE];
	unsigned int length = 0;
	if(!HMAC(EVP_sha256(), m_secret.data(), (int)m_secret.size(), (const unsigned char*)nonce.data(),
		nonce.size(), digest, &length))
		return false;

	std::string expected = toHex(digest, length);
	return hexMac.size() == expected.size() && CRYPTO_memcmp(hexMac.data(), expected.data(), expected.size()) == 0;
}

void DiscordBridge::onAuthenticated(DiscordBridgeSession_ptr session)
{
	if(m_active && m_active != session)
		m_active->close();

	m_active = session;
	m_connected = true;
	size_t queued = 0;
	{
		boost::mutex::scoped_lock lock(m_lock);
		++m_stats.connections;
		queued = m_events.size();
	}

	std::ostringstream welcome;
	welcome << "{\"type\":\"welcome\",\"protocol\":" << DISCORD_BRIDGE_PROTOCOL_VERSION << ",\"bootId\":\"" << m_bootId
		<< "\",\"serverName\":\"" << escapeJson(g_config.getString(ConfigManager::SERVER_NAME)) << "\",\"queued\":" << queued
		<< ",\"features\":[";
	bool first = true;
	if(g_config.getBool(ConfigManager::DISCORD_BRIDGE_PLAYER_SESSIONS))
	{
		welcome << "\"playerSessions\"";
		first = false;
	}
	if(g_config.getBool(ConfigManager::DISCORD_BRIDGE_ACCOUNT_LINKING))
	{
		welcome << (first ? "" : ",") << "\"accountLinking\"";
		first = false;
		if(g_config.getBool(ConfigManager::DISCORD_BRIDGE_BOOSTER_REWARDS))
			welcome << ",\"boosterRewards\"";
	}
	if(g_config.getBool(ConfigManager::DISCORD_BRIDGE_BOOST_PERKS))
	{
		welcome << (first ? "" : ",") << "\"boostPerks\"";
		first = false;
	}
	// every broadcast as an "announcement" event, and the calendar.range request
	welcome << (first ? "" : ",") << "\"announcements\",\"calendar\"";

	welcome << "]}";
	session->send(welcome.str());
	std::cout << "> Discord bot connected to the bridge (" << queued << " queued events)." << std::endl;
	flush();
}

void DiscordBridge::onSessionClosed(DiscordBridgeSession_ptr session)
{
	if(m_active != session)
		return;

	m_active.reset();
	m_connected = false;
	std::cout << "> Discord bot disconnected from the bridge." << std::endl;
}

void DiscordBridge::onIncoming(const std::string& line)
{
	bool schedule = false;
	{
		boost::mutex::scoped_lock lock(m_lock);
		if(m_incoming.size() >= m_maxIncoming)
		{
			++m_stats.rejected;
			return;
		}

		m_incoming.push_back(line);
		++m_stats.received;
		if(!m_dispatchPending)
			schedule = m_dispatchPending = true;
	}

	if(schedule)
		Dispatcher::getInstance().addTask(createTask(boost::bind(&DiscordBridge::dispatchIncoming, this)));
}

void DiscordBridge::dispatchIncoming()
{
	size_t before = 0;
	uint64_t taken = 0;
	{
		boost::mutex::scoped_lock lock(m_lock);
		m_dispatchPending = false;
		before = m_incoming.size();
		taken = m_taken;
	}

	if(g_globalEvents)
		g_globalEvents->execute(GLOBAL_EVENT_DISCORD_BRIDGE);

	bool schedule = false;
	{
		boost::mutex::scoped_lock lock(m_lock);
		// Messages that arrive while the globalevent runs are not a sign that it took none.
		if(before > 0 && m_taken == taken)
		{
			// Nothing consumed: no onDiscordBridge globalevent is registered (or it failed).
			m_stats.rejected += m_incoming.size();
			m_incoming.clear();
			std::cout << "[Warning - DiscordBridge] Incoming messages were not handled; is the discordbridge globalevent registered?" << std::endl;
		}
		else if(!m_incoming.empty() && !m_dispatchPending)
			schedule = m_dispatchPending = true;
	}

	if(schedule)
		Dispatcher::getInstance().addTask(createTask(boost::bind(&DiscordBridge::dispatchIncoming, this)));
}

DiscordBridgeSession::DiscordBridgeSession(DiscordBridge* bridge):
	m_bridge(bridge), m_socket(bridge->getIoContext()), m_timer(bridge->getIoContext()),
	m_buffer(MAX_LINE_LENGTH + 1), m_authenticated(false), m_closed(false), m_writing(false),
	m_connectedAt(0), m_lastReceived(0), m_lastPing(0) {}

void DiscordBridgeSession::start()
{
	m_connectedAt = m_lastReceived = m_lastPing = OTSYS_TIME();

	unsigned char random[32];
	if(RAND_bytes(random, sizeof(random)) != 1)
	{
		close();
		return;
	}

	m_nonce = toHex(random, sizeof(random));
	std::ostringstream hello;
	hello << "{\"type\":\"hello\",\"protocol\":" << DISCORD_BRIDGE_PROTOCOL_VERSION << ",\"nonce\":\"" << m_nonce << "\"}";
	send(hello.str());

	read();
	m_timer.expires_after(boost::asio::chrono::seconds(5));
	m_timer.async_wait(boost::bind(&DiscordBridgeSession::onTimer, shared_from_this(), boost::asio::placeholders::error));
}

void DiscordBridgeSession::close()
{
	if(m_closed)
		return;

	m_closed = true;
	boost::system::error_code ignored;
	m_timer.cancel();
	m_socket.shutdown(boost::asio::ip::tcp::socket::shutdown_both, ignored);
	m_socket.close(ignored);
	m_bridge->onSessionClosed(shared_from_this());
}

void DiscordBridgeSession::send(const std::string& message)
{
	if(m_closed)
		return;

	m_outgoing.push_back(message + "\n");
	if(!m_writing)
		writeNext();
}

void DiscordBridgeSession::writeNext()
{
	if(m_closed || m_outgoing.empty())
		return;

	m_writing = true;
	boost::asio::async_write(m_socket, boost::asio::buffer(m_outgoing.front()),
		boost::bind(&DiscordBridgeSession::handleWrite, shared_from_this(), boost::asio::placeholders::error));
}

void DiscordBridgeSession::handleWrite(const boost::system::error_code& error)
{
	m_writing = false;
	if(!m_outgoing.empty())
		m_outgoing.pop_front();

	if(error)
	{
		close();
		return;
	}

	if(!m_outgoing.empty())
		writeNext();
	else if(m_authenticated)
		m_bridge->flush();
}

void DiscordBridgeSession::read()
{
	boost::asio::async_read_until(m_socket, m_buffer, '\n',
		boost::bind(&DiscordBridgeSession::handleRead, shared_from_this(),
			boost::asio::placeholders::error, boost::asio::placeholders::bytes_transferred));
}

void DiscordBridgeSession::handleRead(const boost::system::error_code& error, std::size_t bytes)
{
	if(m_closed)
		return;

	if(error)
	{
		// Also reached when a line exceeds MAX_LINE_LENGTH (streambuf full).
		close();
		return;
	}

	std::string line(boost::asio::buffers_begin(m_buffer.data()), boost::asio::buffers_begin(m_buffer.data()) + bytes);
	m_buffer.consume(bytes);
	while(!line.empty() && (line[line.size() - 1] == '\n' || line[line.size() - 1] == '\r'))
		line.erase(line.size() - 1);

	m_lastReceived = OTSYS_TIME();
	if(!line.empty())
		handleLine(line);

	if(!m_closed)
		read();
}

void DiscordBridgeSession::handleLine(const std::string& line)
{
	std::string type = messageType(line);
	if(!m_authenticated)
	{
		if(type == "auth" && m_bridge->verifyAuth(m_nonce, jsonField(line, "hmac")))
		{
			m_authenticated = true;
			m_bridge->onAuthenticated(shared_from_this());
			return;
		}

		std::cout << "[Warning - DiscordBridge] Rejected a bridge connection: authentication failed." << std::endl;
		send("{\"type\":\"error\",\"code\":\"auth_failed\",\"message\":\"Authentication failed.\"}");
		boost::asio::post(m_bridge->getIoContext(), boost::bind(&DiscordBridgeSession::close, shared_from_this()));
		return;
	}

	if(type == "ping")
		send("{\"type\":\"pong\"}");
	else if(type == "pong")
		return;
	else if(type.empty())
		send("{\"type\":\"error\",\"code\":\"invalid_json\",\"message\":\"Messages must be JSON objects with a type.\"}");
	else
		m_bridge->onIncoming(line);
}

void DiscordBridgeSession::onTimer(const boost::system::error_code& error)
{
	if(error || m_closed)
		return;

	int64_t now = OTSYS_TIME();
	if(!m_authenticated && now - m_connectedAt > AUTH_TIMEOUT)
	{
		close();
		return;
	}

	if(m_authenticated && now - m_lastReceived > IDLE_TIMEOUT)
	{
		std::cout << "[Warning - DiscordBridge] Bot connection timed out." << std::endl;
		close();
		return;
	}

	if(m_authenticated && now - m_lastPing >= PING_INTERVAL)
	{
		m_lastPing = now;
		send("{\"type\":\"ping\"}");
	}

	m_timer.expires_after(boost::asio::chrono::seconds(5));
	m_timer.async_wait(boost::bind(&DiscordBridgeSession::onTimer, shared_from_this(), boost::asio::placeholders::error));
}

namespace
{
	const time_t LINK_CODE_MIN_INTERVAL = 30;
	const size_t LINK_CODE_MAX_PER_HOUR = 5;
	const uint32_t REDEEM_MAX_FAILURES_PER_USER = 5;
	const time_t REDEEM_USER_WINDOW = 15 * 60;
	const uint32_t REDEEM_MAX_FAILURES_GLOBAL = 50;
	const time_t REDEEM_GLOBAL_WINDOW = 10 * 60;
	// Crockford base32: no I, L, O or U, so codes are easy to read and type.
	const char LINK_CODE_ALPHABET[] = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
	const size_t LINK_CODE_LENGTH = 8;

	std::string sha256Hex(const std::string& text)
	{
		unsigned char digest[EVP_MAX_MD_SIZE];
		unsigned int length = 0;
		if(EVP_Digest(text.data(), text.size(), digest, &length, EVP_sha256(), NULL) != 1)
			return "";

		return toHex(digest, length);
	}

	// Uppercase, without separators; O/I/L typed by mistake count as 0/1/1.
	std::string normalizeLinkCode(const std::string& code)
	{
		std::string out;
		for(size_t i = 0; i < code.size() && out.size() <= LINK_CODE_LENGTH; ++i)
		{
			char c = (char)toupper((unsigned char)code[i]);
			if(c == '-' || c == ' ')
				continue;
			if(c == 'O')
				c = '0';
			else if(c == 'I' || c == 'L')
				c = '1';
			if(!strchr(LINK_CODE_ALPHABET, c) || c == '\0')
				return "";
			out += c;
		}

		return out.size() == LINK_CODE_LENGTH ? out : "";
	}

	bool attemptsExceeded(DiscordBridge::Attempts& attempts, time_t now, time_t window, uint32_t max)
	{
		if(now - attempts.windowStart >= window)
		{
			attempts.count = 0;
			attempts.windowStart = now;
		}

		return attempts.count >= max;
	}
}

void DiscordBridge::pruneLinkCodes(time_t now)
{
	for(std::map<std::string, LinkCode>::iterator it = m_linkCodes.begin(); it != m_linkCodes.end();)
	{
		// Expired codes are kept for one more lifetime so redeeming them reports "expired".
		if(it->second.expires + m_linkCodeLifetime <= now)
			m_linkCodes.erase(it++);
		else
			++it;
	}

	for(std::map<uint32_t, std::deque<time_t> >::iterator it = m_codeRequests.begin(); it != m_codeRequests.end();)
	{
		while(!it->second.empty() && now - it->second.front() >= 3600)
			it->second.pop_front();

		if(it->second.empty())
			m_codeRequests.erase(it++);
		else
			++it;
	}

	for(std::map<std::string, Attempts>::iterator it = m_redeemFailures.begin(); it != m_redeemFailures.end();)
	{
		if(now - it->second.windowStart >= REDEEM_USER_WINDOW)
			m_redeemFailures.erase(it++);
		else
			++it;
	}
}

std::string DiscordBridge::createLinkCode(uint32_t accountId, std::string& error)
{
	time_t now = time(NULL);
	pruneLinkCodes(now);
	if(!g_config.getBool(ConfigManager::DISCORD_BRIDGE_ACCOUNT_LINKING))
	{
		error = "disabled";
		return "";
	}

	if(!accountId)
	{
		error = "invalid_account";
		return "";
	}

	std::deque<time_t>& requests = m_codeRequests[accountId];
	if((!requests.empty() && now - requests.back() < LINK_CODE_MIN_INTERVAL) || requests.size() >= LINK_CODE_MAX_PER_HOUR)
	{
		error = "rate_limited";
		return "";
	}

	unsigned char random[LINK_CODE_LENGTH * 5 / 8];
	if(RAND_bytes(random, sizeof(random)) != 1)
	{
		error = "internal";
		return "";
	}

	std::string code;
	uint64_t bits = 0;
	for(size_t i = 0; i < sizeof(random); ++i)
		bits = (bits << 8) | random[i];

	for(size_t i = 0; i < LINK_CODE_LENGTH; ++i)
		code += LINK_CODE_ALPHABET[(bits >> (5 * (LINK_CODE_LENGTH - 1 - i))) & 0x1F];

	revokeLinkCodes(accountId);
	LinkCode entry;
	entry.accountId = accountId;
	entry.expires = now + m_linkCodeLifetime;
	m_linkCodes[sha256Hex(code)] = entry;
	requests.push_back(now);
	OPENSSL_cleanse(random, sizeof(random));
	return code.substr(0, 4) + "-" + code.substr(4);
}

uint32_t DiscordBridge::consumeLinkCode(const std::string& code, const std::string& discordUserId, std::string& error)
{
	time_t now = time(NULL);
	pruneLinkCodes(now);
	if(!g_config.getBool(ConfigManager::DISCORD_BRIDGE_ACCOUNT_LINKING))
	{
		error = "disabled";
		return 0;
	}

	Attempts& userFailures = m_redeemFailures[discordUserId];
	if(attemptsExceeded(userFailures, now, REDEEM_USER_WINDOW, REDEEM_MAX_FAILURES_PER_USER)
		|| attemptsExceeded(m_globalRedeemFailures, now, REDEEM_GLOBAL_WINDOW, REDEEM_MAX_FAILURES_GLOBAL))
	{
		error = "locked";
		return 0;
	}

	std::string normalized = normalizeLinkCode(code);
	std::map<std::string, LinkCode>::iterator it = normalized.empty() ? m_linkCodes.end() : m_linkCodes.find(sha256Hex(normalized));
	if(it == m_linkCodes.end())
	{
		++userFailures.count;
		++m_globalRedeemFailures.count;
		error = "invalid_code";
		return 0;
	}

	uint32_t accountId = it->second.accountId;
	bool expired = it->second.expires <= now;
	m_linkCodes.erase(it);
	if(expired)
	{
		error = "expired";
		return 0;
	}

	m_redeemFailures.erase(discordUserId);
	return accountId;
}

DiscordBoosterReward DiscordBridge::boosterRewardFor(int32_t week, int32_t serverBoosts)
{
	DiscordBoosterReward reward;
	reward.week = week;
	reward.serverBoosts = std::max(0, serverBoosts);
	reward.weekly = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_WEEKLY);
	int32_t every = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_LOYALTY_EVERY);
	if(every > 0 && week % every == 0)
	{
		reward.loyalty = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_LOYALTY);
		// The bot reports the boost count; the config caps what it can be worth.
		int32_t communityEvery = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_COMMUNITY_EVERY);
		if(communityEvery > 0)
			reward.community = std::min(g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_COMMUNITY_MAX),
				reward.serverBoosts / communityEvery);
	}

	every = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_YEARLY_EVERY);
	if(every > 0 && week % every == 0)
		reward.yearly = g_config.getNumber(ConfigManager::DISCORD_BRIDGE_BOOSTER_YEARLY);

	reward.total = reward.weekly + reward.loyalty + reward.community + reward.yearly;
	return reward;
}

namespace
{
	bool loadBoosterRow(Database* db, const std::string& key, DiscordBoosterReward& reward)
	{
		DBQuery query;
		query << "SELECT `week`, IFNULL(`weekly`, 0) AS `weekly`, IFNULL(`loyalty`, 0) AS `loyalty`, IFNULL(`yearly`, 0) AS `yearly`, "
			<< "IFNULL(`community`, 0) AS `community`, IFNULL(`server_boosts`, 0) AS `server_boosts`, "
			<< "IFNULL(`total`, 0) AS `total` FROM `discord_booster_rewards` WHERE " << key << " LIMIT 1";
		DBResult* result = db->storeQuery(query.str());
		if(!result)
			return false;

		reward.week = result->getDataInt("week");
		reward.weekly = result->getDataInt("weekly");
		reward.loyalty = result->getDataInt("loyalty");
		reward.yearly = result->getDataInt("yearly");
		reward.community = result->getDataInt("community");
		reward.serverBoosts = result->getDataInt("server_boosts");
		reward.total = result->getDataInt("total");
		result->free();
		return true;
	}

	int64_t lastRowCount(Database* db)
	{
		DBResult* result = db->storeQuery("SELECT ROW_COUNT() AS `count`");
		if(!result)
			return -1;

		int64_t count = result->getDataLong("count");
		result->free();
		return count;
	}
}

std::string DiscordBridge::depositBoosterWeek(const std::string& discordUserId, uint32_t accountId, uint64_t boostSince,
	int32_t week, int32_t serverBoosts, DiscordBoosterReward& reward, std::string& error)
{
	if(!g_config.getBool(ConfigManager::DISCORD_BRIDGE_BOOSTER_REWARDS) || !g_config.getBool(ConfigManager::DISCORD_BRIDGE_ACCOUNT_LINKING))
	{
		error = "disabled";
		return "";
	}

	Database* db = Database::getInstance();
	DBQuery query;
	std::ostringstream key;
	key << "`discord_user_id` = " << db->escapeString(discordUserId) << " AND `boost_since` = " << boostSince
		<< " AND `week` = " << week;

	reward = boosterRewardFor(week, serverBoosts);
	{
		DBTransaction trans(db);
		if(!trans.begin())
		{
			error = "internal";
			return "";
		}

		// IGNORE turns a duplicate key (a concurrent or repeated request) into zero inserted
		// rows instead of an error, so the existing ledger row is returned below.
		query << "INSERT IGNORE INTO `discord_booster_rewards` (`discord_user_id`, `account_id`, `boost_since`, `week`, "
			<< "`weekly`, `loyalty`, `yearly`, `community`, `server_boosts`, `total`, `created_at`) VALUES ("
			<< db->escapeString(discordUserId) << ", " << accountId << ", " << boostSince << ", " << week << ", "
			<< reward.weekly << ", " << reward.loyalty << ", " << reward.yearly << ", " << reward.community << ", "
			<< reward.serverBoosts << ", " << reward.total << ", " << time(NULL) << ")";
		if(!db->executeQuery(query.str()))
		{
			std::cout << "[Error - DiscordBridge::depositBoosterWeek] Could not record a booster reward." << std::endl;
			error = "internal";
			return "";
		}

		int64_t inserted = lastRowCount(db);
		if(inserted == 1)
		{
			if(reward.total > 0)
			{
				query.str("");
				query << "UPDATE `accounts` SET `soulcoins` = `soulcoins` + " << reward.total << " WHERE `id` = " << accountId;
				if(!db->executeQuery(query.str()) || lastRowCount(db) != 1)
				{
					std::cout << "[Error - DiscordBridge::depositBoosterWeek] Could not deposit a booster reward on account "
						<< accountId << "; the ledger row was rolled back." << std::endl;
					error = "internal";
					return "";
				}
			}

			if(!trans.commit())
			{
				error = "internal";
				return "";
			}

			return "deposited";
		}
	}

	if(loadBoosterRow(db, key.str(), reward))
		return "duplicate";

	std::cout << "[Error - DiscordBridge::depositBoosterWeek] Could not record a booster reward for account "
		<< accountId << "." << std::endl;
	error = "internal";
	return "";
}

void DiscordBridge::revokeLinkCodes(uint32_t accountId)
{
	for(std::map<std::string, LinkCode>::iterator it = m_linkCodes.begin(); it != m_linkCodes.end();)
	{
		if(it->second.accountId == accountId)
			m_linkCodes.erase(it++);
		else
			++it;
	}
}
