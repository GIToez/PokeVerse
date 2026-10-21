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

#ifndef __PROTOCOL_ACCOUNT__
#define __PROTOCOL_ACCOUNT__
#include "protocol.h"
#include "enums.h"

class NetworkMessage;

// Account service on the login port, used by the client's "Create Account", "New Character",
// "Delete Character", "Forgot password" and Account windows.
//
// First message (after the protocol id 0x0B): U16 operating system, U16 client version,
// then one RSA block: U8 0, 4 x U32 XTEA key, U8 action, String account, String password,
// then by action:
//   ACTION_CREATE_ACCOUNT: String email (empty from clients before emails)
//   ACTION_CREATE_CHARACTER: String name, U8 sex, U16 look type, 4 x U8 colors
//   ACTION_DELETE_CHARACTER: String name
//   ACTION_VERIFY_EMAIL: String code
//   ACTION_SET_EMAIL: String email (accounts without a verified email)
//   ACTION_RECOVER_REQUEST: account is the account name or the email, password empty
//   ACTION_RECOVER_RESET: password is the new password, then String code
//   ACTION_CHANGE_PASSWORD: String new password
//   ACTION_EMAIL_CHANGE_REQUEST: String new email
//   ACTION_EMAIL_CHANGE_CONFIRM: String code sent to the old email, String code sent to the new one
// ACTION_SERVER_STATUS needs no account; it is answered with the number of players online.
// ACTION_ACCOUNT_INFO is answered with "key=value" lines (accountemail.h has the markers
// other answers may start with).
// Reply (XTEA): U8 0x0A error or 0x0B success, String message. The connection is then closed.
class ProtocolAccount : public Protocol
{
	public:
		enum Action_t
		{
			ACTION_CREATE_ACCOUNT = 1,
			ACTION_CREATE_CHARACTER = 2,
			ACTION_DELETE_CHARACTER = 3,
			ACTION_SERVER_STATUS = 4,
			ACTION_VERIFY_EMAIL = 5,
			ACTION_RESEND_CODE = 6,
			ACTION_SET_EMAIL = 7,
			ACTION_RECOVER_REQUEST = 8,
			ACTION_RECOVER_RESET = 9,
			ACTION_CHANGE_PASSWORD = 10,
			ACTION_EMAIL_CHANGE_REQUEST = 11,
			ACTION_EMAIL_CHANGE_CONFIRM = 12,
			ACTION_ACCOUNT_INFO = 13
		};

		virtual void onRecvFirstMessage(NetworkMessage& msg) {parseFirstPacket(msg);}

		ProtocolAccount(Connection_ptr connection) : Protocol(connection) {enableChecksum();}
		virtual ~ProtocolAccount() {}

		enum {protocolId = 0x0B};
		enum {isSingleSocket = false};
		enum {hasChecksum = true};
		static const char* protocolName() {return "account protocol";}

	protected:
		struct Request
		{
			Request(): ip(0), action(0), sex(0) {}

			uint32_t ip;
			uint8_t action, sex;
			std::string account, password, text, text2;
			Outfit_t outfit;
		};

		void reply(bool success, const std::string& message);
		bool parseFirstPacket(NetworkMessage& msg);
		void handleRequest(Request request);
		std::string handleAccountRequest(const Request& request, uint32_t accountId, bool& success);

		std::string createAccount(const Request& request, bool& success);
		std::string createCharacter(uint32_t accountId, std::string name, uint8_t sex, const Outfit_t& outfit, bool& success);
		std::string deleteCharacter(uint32_t accountId, const std::string& name, bool& success);

		std::string recoverRequest(const Request& request, bool& success);
		std::string recoverReset(const Request& request, bool& success);
		std::string verifyEmail(const Request& request, uint32_t accountId, bool& success);
		std::string setEmail(const Request& request, uint32_t accountId, bool& success);
		std::string resendCode(const Request& request, uint32_t accountId, bool& success);
		std::string changePassword(const Request& request, uint32_t accountId, bool& success);
		std::string emailChangeRequest(const Request& request, uint32_t accountId, bool& success);
		std::string emailChangeConfirm(const Request& request, uint32_t accountId, bool& success);
		std::string accountInfo(uint32_t accountId, bool& success);
};
#endif
