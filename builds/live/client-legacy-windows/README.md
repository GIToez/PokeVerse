# builds/live/client-legacy-windows/

Windows live client: the legacy client pointed at the live server instead of 127.0.0.1.
Built by the **Windows dev package** workflow as the `PokeVerse-Windows-Live` artifact
(only when the repository variable `OVH_HOST` or `LIVE_SERVER_HOST` is set), with
`scripts/package-windows-live-client.sh`. See [`docs/live-server.md`](../../../docs/live-server.md).
