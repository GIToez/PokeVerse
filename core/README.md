# core/

Our working source code. Code starts as a copy from `references/` and is then
cleaned up, translated to English and maintained here.

| Folder | Contents | Origin |
| --- | --- | --- |
| `server/` | Game server (C++, The Forgotten Server 0.x based) and its `data/` scripts. | `references/Projeto/PSOUL/` |
| `client-legacy/` | The PokeVerse `data/` and `modules/` of the old client, which the Redemption client is assembled from. The old client program itself is gone. | `references/Projeto/Client/` |
| `client-redemption/` | The game client (OTClient Redemption engine) for Windows, Linux and Android. | — |

Compiled output never goes here; it goes to `builds/`.
