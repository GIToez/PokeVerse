////////////////////////////////////////////////////////////////////////
// PokeVerse
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
////////////////////////////////////////////////////////////////////////
#include "otpch.h"
#include "mailer.h"

#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/version.hpp>
#include <openssl/rand.h>

#include "configmanager.h"
#include "tools.h"

extern ConfigManager g_config;

namespace
{
	const size_t MAX_QUEUE = 500;
	const int32_t ATTEMPTS = 3;
	const int32_t RETRY_SECONDS = 20;
	const int32_t STEP_TIMEOUT_SECONDS = 30;

	typedef boost::asio::ssl::stream<boost::asio::ip::tcp::socket> SslStream;

	std::string base64(const std::string& data)
	{
		static const char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		std::string out;
		uint32_t value = 0;
		int32_t bits = -6;
		for(size_t i = 0; i < data.size(); ++i)
		{
			value = (value << 8) + (uint8_t)data[i];
			bits += 8;
			while(bits >= 0)
			{
				out += table[(value >> bits) & 0x3F];
				bits -= 6;
			}
		}

		if(bits > -6)
			out += table[((value << 8) >> (bits + 8)) & 0x3F];

		while(out.size() % 4)
			out += '=';

		return out;
	}

	// One SMTP conversation. Every network step runs on its own io_context with a deadline,
	// so a mail server that stops answering cannot hold the mailer thread.
	class SmtpSession
	{
		public:
			SmtpSession(boost::asio::ssl::context& context): m_stream(m_io, context), m_tls(false) {}

			void connect(const std::string& host, uint16_t port)
			{
				boost::asio::ip::tcp::resolver resolver(m_io);
				boost::asio::ip::tcp::resolver::results_type endpoints;
				wait([&](auto done) {
					resolver.async_resolve(host, std::to_string(port),
						[&endpoints, done](const boost::system::error_code& ec, boost::asio::ip::tcp::resolver::results_type results)
						{
							endpoints = results;
							done(ec);
						});
				});

				wait([&](auto done) {
					boost::asio::async_connect(m_stream.next_layer(), endpoints,
						[done](const boost::system::error_code& ec, const boost::asio::ip::tcp::endpoint&) {done(ec);});
				});
			}

			void startTls(const std::string& host)
			{
				SSL_set_tlsext_host_name(m_stream.native_handle(), host.c_str());
#if BOOST_VERSION >= 107300
				m_stream.set_verify_callback(boost::asio::ssl::host_name_verification(host));
#else
				m_stream.set_verify_callback(boost::asio::ssl::rfc2818_verification(host));
#endif
				wait([&](auto done) {
					m_stream.async_handshake(boost::asio::ssl::stream_base::client,
						[done](const boost::system::error_code& ec) {done(ec);});
				});
				m_tls = true;
			}

			// Reads one reply (all its lines) and returns its code; line holds the last line.
			int32_t reply(std::string& line)
			{
				for(;;)
				{
					size_t length = 0;
					wait([&](auto done) {
						auto handler = [&length, done](const boost::system::error_code& ec, size_t bytes)
						{
							length = bytes;
							done(ec);
						};
						if(m_tls)
							boost::asio::async_read_until(m_stream, m_buffer, "\r\n", handler);
						else
							boost::asio::async_read_until(m_stream.next_layer(), m_buffer, "\r\n", handler);
					});

					line.assign(boost::asio::buffers_begin(m_buffer.data()), boost::asio::buffers_begin(m_buffer.data()) + length);
					m_buffer.consume(length);
					trim_right(line, "\r\n");
					if(line.size() < 3)
						return 0;

					if(line.size() == 3 || line[3] != '-')
						return atoi(line.substr(0, 3).c_str());
				}
			}

			void write(const std::string& data)
			{
				wait([&](auto done) {
					auto handler = [done](const boost::system::error_code& ec, size_t) {done(ec);};
					if(m_tls)
						boost::asio::async_write(m_stream, boost::asio::buffer(data), handler);
					else
						boost::asio::async_write(m_stream.next_layer(), boost::asio::buffer(data), handler);
				});
			}

			// Sends one command; throws unless the reply code is the expected one.
			void command(const std::string& text, int32_t expected, const std::string& shown = "")
			{
				write(text + "\r\n");
				expect(expected, shown.empty() ? text.substr(0, text.find(' ')) : shown);
			}

			void expect(int32_t expected, const std::string& step)
			{
				std::string line;
				if(reply(line) != expected)
					throw std::runtime_error(step + ": " + line);
			}

		private:
			template<typename Start>
			void wait(Start start)
			{
				boost::system::error_code result = boost::asio::error::would_block;
				start([&result](const boost::system::error_code& ec) {result = ec;});
				m_io.restart();
				m_io.run_for(std::chrono::seconds(STEP_TIMEOUT_SECONDS));
				if(result == boost::asio::error::would_block)
				{
					boost::system::error_code ignored;
					m_stream.next_layer().close(ignored);
					m_io.restart();
					m_io.run_for(std::chrono::seconds(1));
					throw std::runtime_error("the mail server did not answer in time");
				}

				if(result)
					throw boost::system::system_error(result);
			}

			boost::asio::io_context m_io;
			SslStream m_stream;
			boost::asio::streambuf m_buffer;
			bool m_tls;
	};

	std::string messageDate()
	{
		time_t now = time(NULL);
		char buffer[64];
		strftime(buffer, sizeof(buffer), "%a, %d %b %Y %H:%M:%S +0000", gmtime(&now));
		return buffer;
	}

	std::string messageId(const std::string& from)
	{
		unsigned char bytes[8];
		RAND_bytes(bytes, sizeof(bytes));
		std::ostringstream ss;
		ss << "<" << time(NULL) << ".";
		for(size_t i = 0; i < sizeof(bytes); ++i)
			ss << std::hex << std::setw(2) << std::setfill('0') << (int)bytes[i];

		size_t at = from.find('@');
		ss << (at == std::string::npos ? "@pokeverse.quest" : from.substr(at)) << ">";
		return ss.str();
	}

	// Lines starting with a dot are doubled (RFC 5321 4.5.2) and every line ends in CRLF.
	std::string messageBody(const std::string& body)
	{
		std::string out;
		StringVec lines = explodeString(body, "\n");
		for(StringVec::const_iterator it = lines.begin(); it != lines.end(); ++it)
		{
			std::string line = *it;
			trim_right(line, "\r");
			if(!line.empty() && line[0] == '.')
				out += '.';

			out += line + "\r\n";
		}

		return out;
	}
}

void Mailer::start()
{
	boost::unique_lock<boost::mutex> lock(m_lock);
	if(m_running)
		return;

	m_running = true;
	m_thread = boost::thread(boost::bind(&Mailer::run, this));
	if(g_config.getString(ConfigManager::SMTP_HOST).empty())
		std::cout << "> No smtpHost: account emails are printed here instead of sent" << std::endl;
	else
		std::cout << "> Account emails go through " << g_config.getString(ConfigManager::SMTP_HOST) << ":"
			<< g_config.getNumber(ConfigManager::SMTP_PORT) << std::endl;
}

void Mailer::stop()
{
	{
		boost::unique_lock<boost::mutex> lock(m_lock);
		if(!m_running)
			return;

		m_running = false;
	}

	m_signal.notify_all();
	if(m_thread.joinable())
		m_thread.join();
}

void Mailer::send(const std::string& to, const std::string& subject, const std::string& body)
{
	{
		boost::unique_lock<boost::mutex> lock(m_lock);
		if(m_queue.size() >= MAX_QUEUE)
		{
			std::cout << "[Warning - Mailer] Too many emails waiting, dropped: " << subject.substr(0, subject.find(':')) << std::endl;
			return;
		}

		Mail mail;
		mail.to = to;
		mail.subject = subject;
		mail.body = body;
		m_queue.push_back(mail);
	}

	m_signal.notify_one();
}

void Mailer::run()
{
	for(;;)
	{
		Mail mail;
		{
			boost::unique_lock<boost::mutex> lock(m_lock);
			while(m_running && m_queue.empty())
				m_signal.wait(lock);

			// emails still waiting at shutdown are sent first
			if(m_queue.empty())
				return;

			mail = m_queue.front();
			m_queue.pop_front();
		}

		if(g_config.getString(ConfigManager::SMTP_HOST).empty())
		{
			std::cout << "> Email to " << mail.to << ": " << mail.subject << std::endl << mail.body << std::endl;
			continue;
		}

		// the codes are in the subjects; the log keeps the part before them
		const std::string shown = mail.subject.substr(0, mail.subject.find(':'));
		std::string error;
		for(int32_t attempt = 1; attempt <= ATTEMPTS; ++attempt)
		{
			if(deliver(mail, error))
			{
				std::cout << "> Email sent: " << shown << std::endl;
				break;
			}

			std::cout << "[Warning - Mailer] Could not send \"" << shown << "\" (attempt " << attempt << " of "
				<< ATTEMPTS << "): " << error << std::endl;
			if(attempt < ATTEMPTS)
			{
				boost::unique_lock<boost::mutex> lock(m_lock);
				m_signal.timed_wait(lock, boost::posix_time::seconds(RETRY_SECONDS), [this]() {return !m_running;});
			}
		}
	}
}

bool Mailer::deliver(const Mail& mail, std::string& error)
{
	const std::string host = g_config.getString(ConfigManager::SMTP_HOST), user = g_config.getString(ConfigManager::SMTP_USER),
		password = g_config.getString(ConfigManager::SMTP_PASSWORD), caFile = g_config.getString(ConfigManager::SMTP_CA_FILE);
	std::string from = g_config.getString(ConfigManager::SMTP_FROM);
	if(from.empty())
		from = user;

	try
	{
		boost::asio::ssl::context context(boost::asio::ssl::context::tls_client);
		context.set_options(boost::asio::ssl::context::default_workarounds | boost::asio::ssl::context::no_sslv2
			| boost::asio::ssl::context::no_sslv3 | boost::asio::ssl::context::no_tlsv1 | boost::asio::ssl::context::no_tlsv1_1);
		context.set_verify_mode(boost::asio::ssl::verify_peer);
		if(!caFile.empty())
			context.load_verify_file(caFile);
		else
			context.set_default_verify_paths();

		SmtpSession smtp(context);
		smtp.connect(host, (uint16_t)g_config.getNumber(ConfigManager::SMTP_PORT));
		smtp.expect(220, "greeting");
		smtp.command("EHLO pokeverse", 250);
		if(g_config.getBool(ConfigManager::SMTP_STARTTLS))
		{
			smtp.command("STARTTLS", 220);
			smtp.startTls(host);
			smtp.command("EHLO pokeverse", 250);
		}

		if(!user.empty())
			smtp.command("AUTH PLAIN " + base64(std::string(1, '\0') + user + std::string(1, '\0') + password), 235, "AUTH");

		smtp.command("MAIL FROM:<" + from + ">", 250, "MAIL FROM");
		smtp.command("RCPT TO:<" + mail.to + ">", 250, "RCPT TO");
		smtp.command("DATA", 354);

		std::ostringstream message;
		message << "From: " << g_config.getString(ConfigManager::SMTP_FROM_NAME) << " <" << from << ">\r\n"
			<< "To: <" << mail.to << ">\r\n"
			<< "Subject: " << mail.subject << "\r\n"
			<< "Date: " << messageDate() << "\r\n"
			<< "Message-ID: " << messageId(from) << "\r\n"
			<< "MIME-Version: 1.0\r\n"
			<< "Content-Type: text/plain; charset=utf-8\r\n"
			<< "Content-Transfer-Encoding: 8bit\r\n"
			<< "\r\n"
			<< messageBody(mail.body)
			<< ".\r\n";
		smtp.write(message.str());
		smtp.expect(250, "message");
		try
		{
			smtp.command("QUIT", 221);
		}
		catch(std::exception&) {}
		return true;
	}
	catch(std::exception& e)
	{
		error = e.what();
	}

	return false;
}
