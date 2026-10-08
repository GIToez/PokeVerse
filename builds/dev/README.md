# builds/dev/

Ready-to-run Windows development environment. All services bind to 127.0.0.1 only.

The package is built by GitHub Actions (workflow **Windows dev package**) and downloaded
as the `PokeVerse-Windows-Dev` artifact; extract it here or anywhere else. It is not
committed to git. See [`docs/windows-dev-package.md`](../../docs/windows-dev-package.md).

| Item | Purpose |
| --- | --- |
| `server-windows/` | Compiled server (`pokeverse-server.exe`), DLLs, `data/`, `config.lua`. |
| `client-legacy-windows/` | Compiled legacy client (`pokeverse-client.exe`), DLLs, `data/`, `modules/`. |
| `client-redemption-windows/` | Redemption client (later phase). |
| `database/` | Portable MariaDB (`mariadb/`), setup SQL (`sql/`), and the database itself (`data/`). |
| `Setup Database.bat` | Creates or updates the local database. |
| `Start Server and Client.bat` | Starts database, server and client. |
| `Start Server.bat` / `Start Client.bat` | Start them separately. |
| `Create Account.bat` | Creates an account with one character. |
| `Stop Database.bat` | Stops the database. |
