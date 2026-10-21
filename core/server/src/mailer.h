////////////////////////////////////////////////////////////////////////
// PokeVerse
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
////////////////////////////////////////////////////////////////////////

#ifndef __MAILER__
#define __MAILER__
#include "otsystem.h"

#include <deque>
#include <boost/thread.hpp>

// Sends the account emails (verification and password codes, change notices) over SMTP from
// its own thread, so the dispatcher never waits for the mail server. smtpStartTls upgrades
// the connection before logging in (Gmail: smtp.gmail.com, port 587). Without smtpHost the
// emails are printed to the console instead, for local servers.
class Mailer
{
	public:
		static Mailer* getInstance()
		{
			static Mailer instance;
			return &instance;
		}

		void start();
		void stop();
		void send(const std::string& to, const std::string& subject, const std::string& body);

	private:
		struct Mail
		{
			std::string to, subject, body;
		};

		Mailer(): m_running(false) {}
		void run();
		bool deliver(const Mail& mail, std::string& error);

		boost::thread m_thread;
		boost::mutex m_lock;
		boost::condition_variable m_signal;
		std::deque<Mail> m_queue;
		bool m_running;
};
#endif
