# builds/live/client-legacy-windows/

Windows live client: the legacy client pointed at the live server instead of 127.0.0.1.
Built by the **Windows dev package** workflow as the `PokeVerse-Windows-Live` artifact
(server address: variable `LIVE_SERVER_HOST` or `OVH_HOST`, default `40.160.145.24`), with
`scripts/package-windows-live-client.sh`. See [`docs/live-server.md`](../../../docs/live-server.md).
