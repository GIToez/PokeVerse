# core/

Our working source code. Code starts as a copy from `references/` and is then
cleaned up, translated to English and maintained here.

| Folder | Contents | Origin |
| --- | --- | --- |
| `server/` | Game server (C++, The Forgotten Server 0.x based) and its `data/` scripts. | `references/Projeto/PSOUL/` |
| `client-legacy/` | Legacy client (C++, OTClient based) and its Lua modules/data. | `references/Projeto/Sources/Source client/` + `references/Projeto/Client/` |
| `client-redemption/` | New Redemption client. Starts after the legacy foundation is stable. | — |

Compiled output never goes here; it goes to `builds/`.
