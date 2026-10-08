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

class NetworkMessage;

// Account service on the login port, used by the client's "Create Account",
// "New Character" and "Delete Character" windows.
//
// First message (after the protocol id 0x0B): U16 operating system, U16 client version,
// then one RSA block: U8 0, 4 x U32 XTEA key, U8 action, String account, String password,
// and for ACTION_CREATE_CHARACTER: String name, U8 sex; for ACTION_DELETE_CHARACTER: String name.
// Reply (XTEA): U8 0x0A error or 0x0B success, String message. The connection is then closed.
class ProtocolAccount : public Protocol
{
	public:
		enum Action_t
		{
			ACTION_CREATE_ACCOUNT = 1,
			ACTION_CREATE_CHARACTER = 2,
			ACTION_DELETE_CHARACTER = 3
		};

		virtual void onRecvFirstMessage(NetworkMessage& msg) {parseFirstPacket(msg);}

		ProtocolAccount(Connection_ptr connection) : Protocol(connection) {enableChecksum();}
		virtual ~ProtocolAccount() {}

		enum {protocolId = 0x0B};
		enum {isSingleSocket = false};
		enum {hasChecksum = true};
		static const char* protocolName() {return "account protocol";}

	protected:
		void reply(bool success, const std::string& message);
		bool parseFirstPacket(NetworkMessage& msg);
		void handleRequest(uint32_t clientIp, uint8_t action, std::string account, std::string password,
			std::string name, uint8_t sex);

		std::string createAccount(uint32_t clientIp, const std::string& account, const std::string& password, bool& success);
		std::string createCharacter(uint32_t accountId, std::string name, uint8_t sex, bool& success);
		std::string deleteCharacter(uint32_t accountId, const std::string& name, bool& success);
};
#endif
