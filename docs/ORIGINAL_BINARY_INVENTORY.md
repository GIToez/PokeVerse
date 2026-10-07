# Original Binary Inventory

The precompiled files shipped in the PokeJornadas archive. They are kept **locally only** under `original/binaries/` (ignored by Git) for forensic reference, and are never run or used as proof that PokeVerse works. Every executable used for testing is built from `client/source/` and `server/source/` (see [BUILD_BASELINE.md](BUILD_BASELINE.md)). To restore them, run `tools/import/fetch-pokejornadas.sh`; their hashes are also in `original/MANIFEST.sha256.tsv`.

`original/binaries/<component>/` mirrors the original location: `client/` = `Cliente/Cliente/`, `server/` = `Servidor/Servidor/`, `server-source/` = `Source Server/Source Server/`, `updater-hash/` = `Atualizando Cliente/Atualizando Cliente/`.

| File | Size | SHA-256 | Purpose | Required | Rebuildable | Recommendation |
|---|---|---|---|---|---|---|
| `client/otclient.exe` | 5,570,048 | `fae5a4c14287a26c7c293c3bece26dd5243235b1902a788d1930efce25cab21d` | Original Windows client (x86, MinGW gcc 4.8.1) | No (replaced by the source build) | Yes, from `client/source/` | Reference only |
| `client/lua5.1.dll` | 118,784 | `383b60148a880eca72801b3109769bea3d1bbbcc0fc9f114ed105387dfb0f66a` | Lua 5.1 runtime | No (system Lua/LuaJIT) | Yes (upstream) | Reference only |
| `client/libEGL.dll` | 60,416 | `df88ec3a3b84c63b5efc63f12ec6e2b75afd8370d8cd97e6af262d2146260ed5` | ANGLE EGL (OpenGL ES on Direct3D) | No on Linux | Yes (upstream ANGLE) | Reference only |
| `client/libGLESv2.dll` | 679,936 | `9f9f3dc8c88500ef726e849f890fd9049638e83c4993046e012a89c7fa611d37` | ANGLE OpenGL ES 2 | No on Linux | Yes (upstream ANGLE) | Reference only |
| `client/d3dx9_43.dll` | 1,998,168 | `0b28546be22c71834501f7d7185ede5d79742457331c7ee09efc14490dd64f5f` | DirectX 9 helper used by ANGLE | No on Linux | No (Microsoft redistributable) | Reference only |
| `client/irrKlang.dll` | 679,936 | `a31dc4e1d8b92da6b0689122159437d27b2f93be283529b736e4d7dc672d8b22` | irrKlang audio (proprietary) | No (not imported by `otclient.exe`) | No | Discard |
| `client/ikpMP3.dll` | 163,840 | `e8e36d4cbe7554cbd7035bec0a22ee5d5aff1b33fbfe3530da710a4fefc889b8` | irrKlang MP3 plugin | No | No | Discard |
| `client/ikpFlac.dll` | 159,744 | `0d7c984038ff018eb74b5a56d369085f69f72a4b16a4680e0675e0f9b3da05b9` | irrKlang FLAC plugin | No | No | Discard |
| `client/ex.dll` | 17,408 | `abdffdf8e51847b6b8fd54993d5439bc5976da9f39742e84ba43fbb1493f883a` | lua-ex (process spawning from Lua) | No (never loaded) | Yes (upstream) | Discard (unsafe capability) |
| `client/libtest.a` | 1,410 | `d7e53a3ffd23aaad8776a14442a22e3a61b76f6e307081a68f82d898fee282a1` | Build leftover | No | — | Discard |
| `client/libtest.def` | 29 | `f16f0524587f4e4c4d407bf1e35465dc12a57deb6e23b426dbe4a2cacead0dd4` | Build leftover | No | — | Discard |
| `server/PS.exe` | 7,359,488 | `38eca75ebf97d87776707e273e46159ac725ea9513ce203dac7f64d84583a1f9` | Original Windows server (x86, Dev-C++/MinGW) | No (replaced by the source build) | Yes, from `server/source/` | Reference only |
| `server-source/dev-cpp/PS.exe` | 7,359,488 | `38eca75ebf97d87776707e273e46159ac725ea9513ce203dac7f64d84583a1f9` | Same file as `server/PS.exe` | No | Yes | Reference only |
| `server/lua5.1.dll` | 118,784 | `383b60148a880eca72801b3109769bea3d1bbbcc0fc9f114ed105387dfb0f66a` | Lua 5.1 runtime | No | Yes (upstream) | Reference only |
| `server/libmysql.dll` | 2,076,672 | `e25b2103ae94077f2b06b6b27dd4684700e5a4aa2ff9028800ffe4cb6be6797e` | MySQL client library | No (system libmariadb) | Upstream | Reference only |
| `server/mysql.dll` | 86,016 | `836c35889d9e637c2e32fb400b7d811e05789a2117b41727d45e7dc5efca5927` | LuaSQL MySQL driver | No | Yes (upstream) | Reference only |
| `server/sqlite3.dll` | 380,928 | `2e814b8463379e4d5fc6c36ccb73124a8a7419e5f2c572bfa0df06948887f805` | SQLite | No (system library) | Yes (upstream) | Reference only |
| `server/libxml2.dll` | 967,168 | `afda893ad12614d60b4625982319cf03eec5daae3073e44cf65373cf6650bcb6` | libxml2 | No (system library) | Yes (upstream) | Reference only |
| `server/libxml2-2.dll` | 1,373,127 | `005295a42ed75537d8f46840d85e0d69895e93282ffc9de970d0067c96762dc3` | libxml2 (second copy) | No | Yes (upstream) | Reference only |
| `server/iconv.dll` | 892,928 | `aa9ec502e20b927d236e19036b40a5da5ddd4ae030553a6608f821becd646efb` | libiconv | No | Yes (upstream) | Reference only |
| `server/libiconv-2.dll` | 822,507 | `3b9f08c1d2f58534c2ce11a05db6712792c0326cf4dfcddd4a497878a1ab2d98` | libiconv (second copy) | No | Yes (upstream) | Reference only |
| `server/zlib1.dll` | 43,008 | `5e1fb7a41b35a04b479d17a51f0c82972d61397107a08007a12c8bf2c61e4a7d` | zlib | No | Yes (upstream) | Reference only |
| `server/libeay32.dll` | 1,178,624 | `b2f7887ae0bd418724eb32d3449197551a0895f2c764a933a7bd984f187eab78` | OpenSSL 0.9.8/1.0 libcrypto (end of life) | No (system OpenSSL 3) | Yes (upstream) | Reference only |
| `server/iidking-v2.01.exe` | 143,360 | `d1313dee88ad50d3adf87707002c7cd96abe3edfe91601ccab54795ba3cf085b` | PE import-table patcher (DLL injection tool) | No | No | Discard. **Never run.** |
| `server/Large Address Aware.exe` | 41,984 | `7c8f166f1b0ce555480791e20687f63b86f2682818633a97ccbd31b45fd0514a` | .NET tool that sets the PE large-address flag | No | No | Discard |
| `updater-hash/Tools/Release/Hash.exe` | 301,126 | `ce6ac7a0ce976dc6c4055086da3aefd40d9ae4042b300163961df7c9c07ce15f` | Generates the updater's MD5 `hash.xml` | No (legacy updater is disabled) | No (no source) | Reference only; rewrite if the updater returns |
| `server-source/*.o` (21) and `server-source/dev-cpp/obj/*.o` (87), `dev-cpp/obj/TheForgottenServer_private.res` (1) | 30,177,730 total | per file in `original/MANIFEST.sha256.tsv` | MinGW compiler output from the original build | No | Yes (the source build replaces them) | Discard (build output) |
