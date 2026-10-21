////////////////////////////////////////////////////////////////////////
// PokeVerse
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
////////////////////////////////////////////////////////////////////////

#ifndef __ACCOUNT_EMAIL__
#define __ACCOUNT_EMAIL__
#include "otsystem.h"

// Account emails: the 6-digit codes, the login gate for accounts without a verified email,
// the security log and the hourly cleanup. Tables in schemas/pokeverse-extensions.sql.
//
// Messages that start with a marker tell the client which window to open:
// "#verify-email#" (enter the code sent to the email), "#add-email#" (the account needs an
// email) and "#change-email#" (enter the codes sent to the old and the new email).
namespace AccountEmail
{
	enum Purpose_t
	{
		CODE_VERIFY = 1,
		CODE_RESET = 2,
		CODE_EMAIL_CHANGE = 3
	};

	enum CodeCheck_t
	{
		CODE_OK,
		CODE_WRONG,
		CODE_MISSING,
		CODE_EXPIRED,
		CODE_TOO_MANY
	};

	struct State
	{
		State(): accountId(0), verified(false), pending(false), deadline(0), discord(false) {}

		uint32_t accountId;
		std::string name, email, pendingEmail, recoveryKey;
		bool verified, pending;
		int64_t deadline;
		bool discord;
	};

	const std::string VERIFY_MARKER = "#verify-email#";
	const std::string ADD_MARKER = "#add-email#";
	const std::string CHANGE_MARKER = "#change-email#";

	bool isValidEmail(const std::string& email);
	// another account has it verified, is signing up with it, or is changing to it
	bool isEmailTaken(const std::string& email, uint32_t accountId);
	bool loadState(uint32_t accountId, State& state);

	// Empty when the account may play; otherwise the refusal, with a marker.
	std::string loginBlock(uint32_t accountId);
	int32_t graceDaysLeft(const State& state);

	// Sends a new code for purpose to sendTo; email is what the code applies (CODE_VERIFY,
	// CODE_EMAIL_CHANGE). Empty on success, otherwise why not.
	std::string sendCode(const State& state, Purpose_t purpose, const std::string& sendTo, const std::string& email);
	CodeCheck_t checkCode(uint32_t accountId, Purpose_t purpose, std::string code, std::string& email);
	std::string codeMessage(CodeCheck_t check);
	void removeCode(uint32_t accountId, Purpose_t purpose);

	void notify(const std::string& email, const std::string& subject, const std::string& body);
	void log(uint32_t accountId, uint32_t ip, const std::string& event, const std::string& detail = "");

	void scheduleCleanup();
	void cleanup();
}
#endif
