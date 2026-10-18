# PokeVerse Redemption client

This folder is the OTClient Redemption engine
([opentibiabr/otclient](https://github.com/opentibiabr/otclient), commit `53c3878`) with the
PokeVerse changes on top. The first commit that added this folder is a byte-for-byte copy of
[references/otclient-redemption](../../references/otclient-redemption); every later commit is a
PokeVerse change, so `git diff <baseline>.. -- core/client-redemption` shows all of them.

`README.md` and the rest of the upstream documentation are kept as they are.
[docs/engine-changes.md](../../docs/engine-changes.md) lists every engine change and why;
[docs/phase3-redemption.md](../../docs/phase3-redemption.md) explains how the client is put together.
