#!/usr/bin/env python3
"""The PokeVerse login key: a 1024-bit RSA key with e = 65537 (the clients' key size).

  openssl genrsa -out pokeverse-rsa.pem 1024        # a new key (rotating it needs a client update)
  rsa-key.py modulus < pokeverse-rsa.pem            # public modulus, decimal (POKEVERSE_RSA in the client)
  rsa-key.py server-key < pokeverse-rsa.pem         # p, q and d, one per line (the server's rsaKeyFile)
  rsa-key.py modulus --key-file rsa.key             # modulus of a server key file

The private key is the GitHub secret POKEVERSE_RSA_PRIVATE_KEY; it must never be committed.
"""
import argparse
import re
import subprocess
import sys


def from_pem(pem):
    out = subprocess.run(["openssl", "rsa", "-noout", "-text"], input=pem, capture_output=True)
    if out.returncode != 0:
        sys.exit("not an RSA private key (paste the whole file, -----BEGIN to -----END)")
    text = out.stdout.decode()
    fields = {}
    for name, body in re.findall(r"^(\w+):\s*\n((?:\s+[0-9a-f:]+\n)+)", text, re.M):
        fields[name] = int(re.sub(r"[\s:]", "", body), 16)
    exponent = re.search(r"publicExponent: (\d+)", text)
    if not exponent or int(exponent.group(1)) != 65537:
        sys.exit("the public exponent must be 65537")
    return fields["prime1"], fields["prime2"], fields["privateExponent"]


def from_key_file(path):
    with open(path) as f:
        p, q, d = (int(line) for line in f.read().split()[:3])
    return p, q, d


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("output", choices=["modulus", "server-key"])
    ap.add_argument("--key-file", help="read a server key file (p, q, d) instead of a PEM on stdin")
    args = ap.parse_args()
    p, q, d = from_key_file(args.key_file) if args.key_file else from_pem(sys.stdin.buffer.read())
    n = p * q
    if n.bit_length() != 1024:
        sys.exit("the key must be 1024 bits (openssl genrsa -out pokeverse-rsa.pem 1024)")
    if pow(pow(12345, 65537, n), d, n) != 12345:
        sys.exit("the key is damaged (p, q and d do not belong together)")
    print(n if args.output == "modulus" else "%d\n%d\n%d" % (p, q, d))


if __name__ == "__main__":
    main()
