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
		<< "\",\"serverName\":\"" << escapeJson(g_config.getString(ConfigManager::SERVER_NAME)) << "\",\"queued\":" << queued << "}";
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
	{
		boost::mutex::scoped_lock lock(m_lock);
		m_dispatchPending = false;
		before = m_incoming.size();
	}

	if(g_globalEvents)
		g_globalEvents->execute(GLOBAL_EVENT_DISCORD_BRIDGE);

	bool schedule = false;
	{
		boost::mutex::scoped_lock lock(m_lock);
		if(before > 0 && m_incoming.size() >= before)
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
