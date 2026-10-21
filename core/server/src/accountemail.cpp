////////////////////////////////////////////////////////////////////////
// PokeVerse
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
////////////////////////////////////////////////////////////////////////
#include "otpch.h"
#include "accountemail.h"

#include <openssl/rand.h>

#include "configmanager.h"
#include "database.h"
#include "mailer.h"
#include "scheduler.h"
#include "tools.h"

extern ConfigManager g_config;

namespace
{
	const int64_t CODE_LIFETIME = 15 * 60;
	const int32_t CODE_TRIES = 5;
	const int64_t CODE_COOLDOWN = 60;
	const int32_t CODES_PER_DAY = 10;
	const int64_t SIGNUP_LIFETIME = 24 * 3600;
	const int64_t LOG_LIFETIME = 180 * 86400;
	const uint32_t CLEANUP_INTERVAL = 3600 * 1000;
	const char* SIGNATURE = "\nPokeVerse\nhttps://pokeverse.quest\n";

	std::string codeHash(uint32_t accountId, AccountEmail::Purpose_t purpose, const std::string& code)
	{
		std::ostringstream ss;
		ss << accountId << ":" << (int32_t)purpose << ":" << code;
		return transformToSHA256(ss.str(), false);
	}

	std::string newCode()
	{
		uint32_t value = 0;
		if(RAND_bytes((unsigned char*)&value, sizeof(value)) != 1)
			value = (uint32_t)random_range(0, 999999);

		char buffer[8];
		sprintf(buffer, "%06u", value % 1000000);
		return buffer;
	}

	bool isEmailLocalCharacter(char c)
	{
		return isLowercaseLetter(c) || isNumber(c) || c == '.' || c == '_' || c == '%' || c == '+' || c == '-';
	}

	bool isDomainLabel(const std::string& label)
	{
		if(label.empty() || label.size() > 63 || label[0] == '-' || label[label.size() - 1] == '-')
			return false;

		for(size_t i = 0; i < label.size(); ++i)
		{
			if(!isLowercaseLetter(label[i]) && !isNumber(label[i]) && label[i] != '-')
				return false;
		}

		return true;
	}
}

namespace AccountEmail
{
	// Lower case, at most 50 characters (it shares the 128-byte login block with the account
	// name and password), name@domain.tld.
	bool isValidEmail(const std::string& email)
	{
		if(email.size() < 6 || email.size() > 50)
			return false;

		size_t at = email.find('@');
		if(at == std::string::npos || at == 0 || email.find('@', at + 1) != std::string::npos)
			return false;

		std::string local = email.substr(0, at), domain = email.substr(at + 1);
		if(local[0] == '.' || local[local.size() - 1] == '.' || local.find("..") != std::string::npos)
			return false;

		for(size_t i = 0; i < local.size(); ++i)
		{
			if(!isEmailLocalCharacter(local[i]))
				return false;
		}

		StringVec labels = explodeString(domain, ".");
		if(labels.size() < 2 || labels.back().size() < 2 || isNumbers(labels.back()))
			return false;

		for(StringVec::const_iterator it = labels.begin(); it != labels.end(); ++it)
		{
			if(!isDomainLabel(*it))
				return false;
		}

		return true;
	}

	bool isEmailTaken(const std::string& email, uint32_t accountId)
	{
		Database* db = Database::getInstance();
		DBQuery query;
		query << "SELECT `id` FROM `accounts` WHERE `email` = " << db->escapeString(email) << " AND `id` <> " << accountId
			<< " AND (`email_verified` = 1 OR `signup_pending` = 1) LIMIT 1";
		DBResult* result;
		if((result = db->storeQuery(query.str())))
		{
			result->free();
			return true;
		}

		query.str("");
		query << "SELECT `account_id` FROM `account_codes` WHERE `email` = " << db->escapeString(email) << " AND `account_id` <> "
			<< accountId << " AND `purpose` = " << CODE_EMAIL_CHANGE << " AND `expires_at` > " << time(NULL) << " LIMIT 1";
		if((result = db->storeQuery(query.str())))
		{
			result->free();
			return true;
		}

		return false;
	}

	bool loadState(uint32_t accountId, State& state)
	{
		Database* db = Database::getInstance();
		DBQuery query;
		query << "SELECT `name`, `email`, `key`, `email_verified`, `signup_pending`, `email_deadline` FROM `accounts` WHERE `id` = "
			<< accountId << " LIMIT 1";
		DBResult* result;
		if(!(result = db->storeQuery(query.str())))
			return false;

		state.accountId = accountId;
		state.name = result->getDataString("name");
		state.email = result->getDataString("email");
		state.recoveryKey = result->getDataString("key");
		state.verified = result->getDataInt("email_verified") != 0;
		state.pending = result->getDataInt("signup_pending") != 0;
		state.deadline = result->getDataLong("email_deadline");
		result->free();

		query.str("");
		query << "SELECT `email` FROM `account_codes` WHERE `account_id` = " << accountId << " AND `purpose` = " << CODE_VERIFY
			<< " AND `expires_at` > " << time(NULL) << " LIMIT 1";
		if((result = db->storeQuery(query.str())))
		{
			state.pendingEmail = result->getDataString("email");
			result->free();
		}

		query.str("");
		query << "SELECT `account_id` FROM `discord_account_links` WHERE `account_id` = " << accountId << " LIMIT 1";
		if((result = db->storeQuery(query.str())))
		{
			state.discord = true;
			result->free();
		}

		return true;
	}

	int32_t graceDaysLeft(const State& state)
	{
		if(state.verified || state.pending || !state.deadline)
			return -1;

		int64_t left = state.deadline - time(NULL);
		return left > 0 ? (int32_t)((left + 86399) / 86400) : 0;
	}

	std::string loginBlock(uint32_t accountId)
	{
		if(!g_config.getBool(ConfigManager::EMAIL_REQUIRED) || accountId <= 1)
			return "";

		State state;
		if(!loadState(accountId, state) || state.verified)
			return "";

		if(state.pending)
			return VERIFY_MARKER + "Enter the code we sent to " + state.email + " to finish creating your account.";

		int64_t now = time(NULL);
		if(!state.deadline)
		{
			Database* db = Database::getInstance();
			DBQuery query;
			query << "UPDATE `accounts` SET `email_deadline` = " << now + std::max<int32_t>(0, g_config.getNumber(ConfigManager::EMAIL_GRACE_DAYS)) * 86400
				<< " WHERE `id` = " << accountId << " AND `email_deadline` = 0";
			db->executeQuery(query.str());
			return "";
		}

		if(now < state.deadline)
			return "";

		return ADD_MARKER + "Your account needs an email before you can play. Add one and enter the code we send to it.";
	}

	std::string sendCode(const State& state, Purpose_t purpose, const std::string& sendTo, const std::string& email)
	{
		Database* db = Database::getInstance();
		int64_t now = time(NULL);
		DBQuery query;
		query << "SELECT `created_at`, `email` FROM `account_codes` WHERE `account_id` = " << state.accountId << " AND `purpose` = "
			<< purpose << " LIMIT 1";
		DBResult* result;
		if((result = db->storeQuery(query.str())))
		{
			int64_t created = result->getDataLong("created_at");
			std::string previous = result->getDataString("email");
			result->free();
			// a mistyped email can be corrected at once; the daily limit still applies
			if(now - created < CODE_COOLDOWN && previous == email)
				return "Please wait a minute before asking for another code.";
		}

		query.str("");
		query << "SELECT COUNT(*) AS `count` FROM `account_security_log` WHERE `account_id` = " << state.accountId
			<< " AND `event` = 'code_sent' AND `time` > " << now - 86400;
		if((result = db->storeQuery(query.str())))
		{
			int32_t count = result->getDataInt("count");
			result->free();
			if(count >= CODES_PER_DAY)
				return "Too many codes were sent for this account today, please try again tomorrow.";
		}

		std::string code = newCode();
		query.str("");
		query << "REPLACE INTO `account_codes` (`account_id`, `purpose`, `code_hash`, `email`, `created_at`, `expires_at`, `tries`) VALUES ("
			<< state.accountId << ", " << purpose << ", " << db->escapeString(codeHash(state.accountId, purpose, code)) << ", "
			<< db->escapeString(email) << ", " << now << ", " << now + CODE_LIFETIME << ", 0)";
		if(!db->executeQuery(query.str()))
			return "The code could not be sent, please try again.";

		std::ostringstream body;
		std::string subject;
		body << "Hello,\n\n";
		switch(purpose)
		{
			case CODE_VERIFY:
				subject = "Your PokeVerse email code: " + code;
				body << "Your code to verify this email for the PokeVerse account \"" << state.name << "\" is:\n\n";
				break;
			case CODE_RESET:
				subject = "Your PokeVerse password reset code: " + code;
				body << "Someone asked to reset the password of the PokeVerse account \"" << state.name << "\".\n"
					<< "Your code is:\n\n";
				break;
			case CODE_EMAIL_CHANGE:
				subject = "Your PokeVerse email change code: " + code;
				body << "Someone asked to change the email of the PokeVerse account \"" << state.name << "\" to " << email << ".\n"
					<< "Your code is:\n\n";
				break;
		}

		body << "    " << code << "\n\n" << "It is valid for 15 minutes. If you did not ask for it, ignore this email";
		if(purpose != CODE_VERIFY)
			body << " and change your password in the game";

		body << ".\n" << SIGNATURE;
		Mailer::getInstance()->send(sendTo, subject, body.str());

		std::ostringstream detail;
		detail << "purpose " << (int32_t)purpose;
		log(state.accountId, 0, "code_sent", detail.str());
		return "";
	}

	CodeCheck_t checkCode(uint32_t accountId, Purpose_t purpose, std::string code, std::string& email)
	{
		trimString(code);
		Database* db = Database::getInstance();
		DBQuery query;
		query << "SELECT `code_hash`, `email`, `expires_at`, `tries` FROM `account_codes` WHERE `account_id` = " << accountId
			<< " AND `purpose` = " << purpose << " LIMIT 1";
		DBResult* result;
		if(!(result = db->storeQuery(query.str())))
			return CODE_MISSING;

		std::string hash = result->getDataString("code_hash");
		email = result->getDataString("email");
		int64_t expires = result->getDataLong("expires_at");
		int32_t tries = result->getDataInt("tries");
		result->free();
		if(expires <= time(NULL))
		{
			removeCode(accountId, purpose);
			return CODE_EXPIRED;
		}

		if(tries >= CODE_TRIES)
		{
			removeCode(accountId, purpose);
			return CODE_TOO_MANY;
		}

		if(code.size() == 6 && isNumbers(code) && codeHash(accountId, purpose, code) == hash)
			return CODE_OK;

		query.str("");
		if(tries + 1 >= CODE_TRIES)
		{
			removeCode(accountId, purpose);
			return CODE_TOO_MANY;
		}

		query << "UPDATE `account_codes` SET `tries` = `tries` + 1 WHERE `account_id` = " << accountId << " AND `purpose` = " << purpose;
		db->executeQuery(query.str());
		return CODE_WRONG;
	}

	std::string codeMessage(CodeCheck_t check)
	{
		switch(check)
		{
			case CODE_WRONG:
				return "That code is not right, please check it and try again.";
			case CODE_EXPIRED:
				return "That code has expired. Ask for a new one.";
			case CODE_TOO_MANY:
				return "Too many wrong codes. Ask for a new one.";
			case CODE_MISSING:
				return "There is no code waiting. Ask for a new one.";
			default:
				break;
		}

		return "";
	}

	void removeCode(uint32_t accountId, Purpose_t purpose)
	{
		Database* db = Database::getInstance();
		DBQuery query;
		query << "DELETE FROM `account_codes` WHERE `account_id` = " << accountId << " AND `purpose` = " << purpose;
		db->executeQuery(query.str());
	}

	void notify(const std::string& email, const std::string& subject, const std::string& body)
	{
		if(email.empty())
			return;

		Mailer::getInstance()->send(email, subject, "Hello,\n\n" + body + "\n" + SIGNATURE);
	}

	void log(uint32_t accountId, uint32_t ip, const std::string& event, const std::string& detail)
	{
		if(!accountId)
			return;

		Database* db = Database::getInstance();
		DBQuery query;
		query << "INSERT INTO `account_security_log` (`account_id`, `time`, `ip`, `event`, `detail`) VALUES (" << accountId << ", "
			<< time(NULL) << ", " << ntohl(ip) << ", " << db->escapeString(event) << ", " << db->escapeString(detail.substr(0, 255)) << ")";
		db->executeQuery(query.str());
	}

	void scheduleCleanup()
	{
		Scheduler::getInstance().addEvent(createSchedulerTask(CLEANUP_INTERVAL, boost::bind(&AccountEmail::cleanup)));
	}

	// Hourly: signups never verified, expired codes and old log lines.
	void cleanup()
	{
		Database* db = Database::getInstance();
		int64_t now = time(NULL);
		DBQuery query;
		query << "DELETE FROM `accounts` WHERE `signup_pending` = 1 AND `email_verified` = 0 AND `created_at` > 0 AND `created_at` < "
			<< now - SIGNUP_LIFETIME << " AND `id` NOT IN (SELECT `account_id` FROM `players`)";
		db->executeQuery(query.str());

		query.str("");
		query << "DELETE FROM `account_codes` WHERE `expires_at` < " << now - CODE_LIFETIME;
		db->executeQuery(query.str());

		query.str("");
		query << "DELETE FROM `account_security_log` WHERE `time` < " << now - LOG_LIFETIME;
		db->executeQuery(query.str());

		scheduleCleanup();
	}
}
