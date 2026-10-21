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
#include "otpch.h"
#include "rsa.h"

#include <fstream>

RSA::RSA()
{
	m_keySet = false;
	mpz_init2(m_p, 1024);
	mpz_init2(m_q, 1024);
	mpz_init2(m_d, 1024);
	mpz_init2(m_u, 1024);
	mpz_init2(m_dp, 1024);
	mpz_init2(m_dq, 1024);
	mpz_init2(m_mod, 1024);
}

RSA::~RSA()
{
	mpz_clear(m_p);
	mpz_clear(m_q);
	mpz_clear(m_d);
	mpz_clear(m_u);
	mpz_clear(m_dp);
	mpz_clear(m_dq);
	mpz_clear(m_mod);
}

bool RSA::setKey(const std::string& file)
{
	// p, q and d in decimal, one per line
	std::ifstream in(file.c_str());
	std::string p, q, d;
	if(!std::getline(in, p) || !std::getline(in, q) || !std::getline(in, d))
		return false;

	mpz_t check;
	mpz_init(check);
	bool valid = !mpz_set_str(check, p.c_str(), 10) && !mpz_set_str(check, q.c_str(), 10)
		&& !mpz_set_str(check, d.c_str(), 10);
	mpz_clear(check);
	if(!valid)
		return false;

	setKey(p.c_str(), q.c_str(), d.c_str());
	if(getKeySize() != 128)
		return false;

	// the clients encrypt with e = 65537: a block must come back unchanged
	char block[128];
	memset(block, 0, sizeof(block));
	for(int32_t i = 1; i < 128; ++i)
		block[i] = (char)(i * 37 + 11);

	mpz_t m, e, c;
	mpz_init(m);
	mpz_init_set_ui(e, 65537);
	mpz_init(c);
	mpz_import(m, 128, 1, 1, 0, 0, block);
	mpz_powm(c, m, e, m_mod);

	char encrypted[128];
	size_t count = (mpz_sizeinbase(c, 2) + 7) / 8;
	memset(encrypted, 0, 128 - count);
	mpz_export(&encrypted[128 - count], NULL, 1, 1, 0, 0, c);
	mpz_clear(m);
	mpz_clear(e);
	mpz_clear(c);

	decrypt(encrypted, 128);
	return !memcmp(encrypted, block, 128);
}

void RSA::setKey(const char* p, const char* q, const char* d)
{
	boost::recursive_mutex::scoped_lock lockClass(rsaLock);

	mpz_set_str(m_p, p, 10);
	mpz_set_str(m_q, q, 10);
	mpz_set_str(m_d, d, 10);

	mpz_t pm1,qm1;
	mpz_init2(pm1, 520);
	mpz_init2(qm1, 520);

	mpz_sub_ui(pm1, m_p, 1);
	mpz_sub_ui(qm1, m_q, 1);
	mpz_invert(m_u, m_p, m_q);
	mpz_mod(m_dp, m_d, pm1);
	mpz_mod(m_dq, m_d, qm1);

	mpz_mul(m_mod, m_p, m_q);

	mpz_clear(pm1);
	mpz_clear(qm1);
}

void RSA::decrypt(char* msg, int32_t size)
{
	boost::recursive_mutex::scoped_lock lockClass(rsaLock);

	mpz_t c,v1,v2,u2,tmp;
	mpz_init2(c, 1024);
	mpz_init2(v1, 1024);
	mpz_init2(v2, 1024);
	mpz_init2(u2, 1024);
	mpz_init2(tmp, 1024);

	mpz_import(c, 128, 1, 1, 0, 0, msg);

	mpz_mod(tmp, c, m_p);
	mpz_powm(v1, tmp, m_dp, m_p);
	mpz_mod(tmp, c, m_q);
	mpz_powm(v2, tmp, m_dq, m_q);
	mpz_sub(u2, v2, v1);
	mpz_mul(tmp, u2, m_u);
	mpz_mod(u2, tmp, m_q);
	if(mpz_cmp_si(u2, 0) < 0)
	{
		mpz_add(tmp, u2, m_q);
		mpz_set(u2, tmp);
	}
	mpz_mul(tmp, u2, m_p);
	mpz_set_ui(c, 0);
	mpz_add(c, v1, tmp);

	size_t count = (mpz_sizeinbase(c, 2) + 7)/8;
	memset(msg, 0, 128 - count);
	mpz_export(&msg[128 - count], NULL, 1, 1, 0, 0, c);

	mpz_clear(c);
	mpz_clear(v1);
	mpz_clear(v2);
	mpz_clear(u2);
	mpz_clear(tmp);
}

int32_t RSA::getKeySize()
{
	return (mpz_sizeinbase(m_mod, 2) + 7) / 8;
}

void RSA::getPublicKey(char* buffer)
{
	size_t count = (mpz_sizeinbase(m_mod, 2) + 7) / 8;
	memset(buffer, 0, 128 - count);
	mpz_export(&buffer[128 - count], NULL, 1, 1, 0, 0, m_mod);
}
