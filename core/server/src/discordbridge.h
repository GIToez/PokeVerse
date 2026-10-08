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

#ifndef __DISCORDBRIDGE__
#define __DISCORDBRIDGE__
#include "otsystem.h"
#include "tools.h"

#include <deque>
#include <boost/enable_shared_from_this.hpp>

// Newline-delimited JSON over TCP, authenticated with HMAC-SHA256 over a
// per-connection nonce. The network runs on its own thread and io_context:
// game code only appends to bounded in-memory queues and never waits for the bot.
// Protocol and message contracts: docs/discord-bridge.md.

#define DISCORD_BRIDGE_PROTOCOL_VERSION 1

class DiscordBridgeSession;
typedef boost::shared_ptr<DiscordBridgeSession> DiscordBridgeSession_ptr;

struct DiscordBridgeStats
{
	DiscordBridgeStats(): queued(0), sent(0), dropped(0), received(0), rejected(0), connections(0) {}

	uint64_t queued, sent, dropped, received, rejected, connections;
};

class DiscordBridge
{
	public:
		virtual ~DiscordBridge() {}
		static DiscordBridge* getInstance()
		{
			static DiscordBridge instance;
			return &instance;
		}

		void start();
		void stop();

		bool isEnabled() const {return m_enabled;}
		bool isConnected() const {return m_connected;}
		const std::string& getBootId() const {return m_bootId;}
		DiscordBridgeStats getStats();

		// Any thread. Wraps the JSON object in an event envelope with a unique id and
		// queues it; queued events survive bot reconnects (oldest dropped when full).
		bool emitEvent(const std::string& payload);
		// Any thread. Sends a raw JSON message only if a bot is connected right now.
		bool sendMessage(const std::string& message);
		// Dispatcher thread. Removes and returns up to max received messages.
		StringVec takeIncoming(uint32_t max);

		// Escapes a Latin-1 game string for a JSON string literal (bytes >= 0x80 become \u00XX).
		static std::string escapeJson(const std::string& text);

		// Network thread only.
		boost::asio::io_context& getIoContext() {return m_io;}
		bool verifyAuth(const std::string& nonce, const std::string& hexMac) const;
		void onAuthenticated(DiscordBridgeSession_ptr session);
		void onSessionClosed(DiscordBridgeSession_ptr session);
		void onIncoming(const std::string& line);
		void flush();

	private:
		DiscordBridge(): m_enabled(false), m_connected(false), m_running(false), m_dispatchPending(false),
			m_maxQueue(2000), m_maxIncoming(500), m_sequence(0),
			m_acceptor(m_io), m_work(boost::asio::make_work_guard(m_io)) {}

		void networkThread();
		void accept();
		void handleAccept(DiscordBridgeSession_ptr session, const boost::system::error_code& error);
		void dispatchIncoming();
		bool hasPendingOutput();

		volatile bool m_enabled, m_connected, m_running;
		bool m_dispatchPending;
		uint32_t m_maxQueue, m_maxIncoming;
		uint64_t m_sequence;
		std::string m_secret, m_bootId;

		boost::mutex m_lock;
		std::deque<std::string> m_events, m_direct, m_incoming;
		DiscordBridgeStats m_stats;

		boost::asio::io_context m_io;
		boost::asio::ip::tcp::acceptor m_acceptor;
		boost::asio::executor_work_guard<boost::asio::io_context::executor_type> m_work;
		boost::thread m_thread;
		DiscordBridgeSession_ptr m_active;
};

class DiscordBridgeSession : public boost::enable_shared_from_this<DiscordBridgeSession>
{
	public:
		DiscordBridgeSession(DiscordBridge* bridge);
		virtual ~DiscordBridgeSession() {}

		boost::asio::ip::tcp::socket& getSocket() {return m_socket;}
		void start();
		void close();
		bool isOpen() const {return !m_closed;}
		bool isAuthenticated() const {return m_authenticated;}

		// Messages are written one at a time in order; pending() counts unwritten ones.
		void send(const std::string& message);
		size_t pending() const {return m_outgoing.size();}

	private:
		void read();
		void handleRead(const boost::system::error_code& error, std::size_t bytes);
		void handleLine(const std::string& line);
		void handleWrite(const boost::system::error_code& error);
		void writeNext();
		void onTimer(const boost::system::error_code& error);

		DiscordBridge* m_bridge;
		boost::asio::ip::tcp::socket m_socket;
		boost::asio::steady_timer m_timer;
		boost::asio::streambuf m_buffer;
		std::string m_nonce;
		bool m_authenticated, m_closed, m_writing;
		int64_t m_connectedAt, m_lastReceived, m_lastPing;
		std::deque<std::string> m_outgoing;
};
#endif
