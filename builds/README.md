# builds/

Compiled, runnable packages. Everything here is produced from `core/`.

- `dev/` — Windows local development environment (localhost only).
- `live/` — Release packages for players and the production server.

## Packages per workflow

| Workflow | Today | After Phase 3 |
| --- | --- | --- |
| **Windows dev package** (every push and PR) | Dev package: server, database, legacy client (localhost) | Same package with both the legacy and the Redemption client for Windows |
| **Windows dev package** | Live legacy client for Windows | Unchanged |
| **Live server** | Linux live server | Unchanged |
| Live client packages | - | Legacy: Windows, Linux. Redemption: Windows, Linux, Android, web |

Live client folders are listed in [`live/README.md`](live/README.md).
