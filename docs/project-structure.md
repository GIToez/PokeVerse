# Project structure

```
PokeVerse/
├── references/                 Original projects, read-only
│   └── Projeto/                Original PSoul project (see references/README.md)
├── core/                       Our primary source code
│   ├── server/
│   ├── client-legacy/
│   └── client-redemption/
├── builds/                     Compiled, runnable packages
│   ├── dev/                    Windows local development (localhost only)
│   │   ├── server-windows/
│   │   ├── client-legacy-windows/
│   │   ├── client-redemption-windows/
│   │   ├── database/
│   │   └── Setup Database.bat, Start Server and Client.bat, ...
│   └── live/                   Release packages
│       ├── server-linux/
│       ├── client-legacy-windows/
│       ├── client-legacy-linux/
│       ├── client-redemption-windows/
│       ├── client-redemption-linux/
│       ├── client-redemption-android/
│       └── client-redemption-web/
├── docs/                       English documentation
└── scripts/                    Build and setup automation
```

## Rules

1. **`references/` is read-only.** Copy what you need into `core/`; never edit originals.
   `scripts/verify-references.sh` checks they are unchanged.
2. **Source and builds stay separate.** Source lives in `core/`, compiled output in `builds/`.
3. **English first.** Backend identifiers, commands, file and folder names, comments,
   configuration keys and docs are written in English. Player-facing translations
   (for example `pt_br.loc` and client `locales/`) are preserved, not overwritten.
4. **Compatibility first.** Database schemas and client-server protocols must keep
   working when renaming or translating.
5. **Development is localhost only.** Nothing in `builds/dev/` exposes public services.

## Large files

Files over 100 MB (`*.spr`, `*.otbm`, `*.sdf`) are stored with Git LFS
(see `.gitattributes`). Install Git LFS before cloning.
