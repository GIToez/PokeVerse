# OTClient Redemption Baseline

PokeVerse Phase 3 adopts OTClient Redemption as its new client engine. I recorded the upstream source below before changing anything in it.

| Item | Value |
|---|---|
| Upstream URL | https://github.com/opentibiabr/otclient.git |
| Branch | `main` |
| Upstream commit | `396f0b396741bdd4469f27cf9376103930712cff` |
| Upstream commit subject | "ci: fix github actions builds (#1839)" |
| Upstream commit date | 2026-10-01 14:07:22 -0300 |
| Import date | 2026-10-07 |
| Import method | `git subtree add --prefix client-redemption https://github.com/opentibiabr/otclient.git 396f0b3 --squash` |
| PokeVerse import commits | `d3de0ed69` (squashed upstream content) and `96f1e0f32` (subtree merge) |
| Files | 3,584 (62 MB). I compared every one against the upstream checkout at that commit, and they all match. |
| License | MIT (`client-redemption/LICENSE`); upstream `AUTHORS` kept |
| Upstream vcpkg baseline | `builtin-baseline` `9e593bb18ea69cc5095e012465dcd675a822ed0d` (`vcpkg.json`) |

## Rules for this directory

- `client-redemption/` keeps the upstream directory structure.
- Every PokeVerse change to it is a separate commit on top of `96f1e0f32`. That makes the upstream delta `git diff 96f1e0f32 -- client-redemption/`.
- To update from upstream: `git subtree pull --prefix client-redemption https://github.com/opentibiabr/otclient.git <ref> --squash`. Then record the new SHA here.
- Build output never goes inside `client-redemption/`. See `BUILD_REDEMPTION.md`.

## Why a subtree and not a submodule

A subtree keeps the clone self-contained: CI and a fresh checkout build without network access to a second repository. It also lets PokeVerse patches live in normal commits. The upstream SHA is recorded above and in the squash commit message.
