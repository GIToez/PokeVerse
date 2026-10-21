# Client updates (Redemption client)

Players install the Redemption client once. Every time it starts, it checks GitHub for a
newer version and downloads only the files that changed, then restarts if needed.
Nothing runs on our own servers for this, and there is no PHP.

- **GitHub Pages** hosts the update manifests (`updater/windows.json`, `updater/linux.json`,
  `updater/android.json`)
  and every file under 95 MB (`updater/files/<release>/...`). Pages does not accept files
  over 100 MB.
- **GitHub Releases** host the larger files (the 308 MB `data.spr`, and the executable if it
  is too big) plus the first-install downloads, `PokeVerse-Setup.exe`, `PokeVerse-Windows.zip`,
  `PokeVerse-Linux.tar.gz` and `PokeVerse-Android.apk`.
- The workflow is `.github/workflows/client-release.yml` (Actions → **Client release**).

Both live in the public repository
[GIToez/PokeVerse-Clients](https://github.com/GIToez/PokeVerse-Clients), so this repository
can be private: its Pages site is on the `gh-pages` branch, and the updater URL in the
clients is `https://gitoez.github.io/PokeVerse-Clients/updater/`.

Only the live packages have the updater turned on. Development builds (`builds/dev/`) and
the test builds never update.

## One-time setup

1. The repository secret `PV_REPOS_TOKEN`: a fine-grained token with **Contents: Read and
   write** on `GIToez/PokeVerse-Clients` (the same token the Discord bot deploy uses). Every
   run checks that it can push there; publishing stops before it starts if it cannot.
2. In PokeVerse-Clients, after the first publish has created the `gh-pages` branch:
   **Settings → Pages → Build and deployment → Source: Deploy from a branch**, branch
   `gh-pages`, folder `/ (root)`. That first publish waits up to 15 minutes for the site;
   if Pages is not on by then it fails. Turn Pages on and use **Re-run failed jobs**.
   The site's custom domain (`pokeverse.quest`) is published with it as a `CNAME` file, so
   every publish keeps it; set the repository variable `PAGES_DOMAIN` if the domain changes.
3. Optional: set the repository variable `LIVE_SERVER_HOST` (Settings → Secrets and
   variables → Actions → Variables) if the live server address changes. Without it the
   workflow uses the current OVH address.
4. Android signing key (done October 2026; keep the keystore safe: Android only installs a
   new APK over an old one when both are signed with the same key). It was created with
   `keytool -genkeypair -v -keystore pokeverse.keystore -alias pokeverse -keyalg RSA -keysize 4096 -validity 10000`,
   then add these repository secrets: `ANDROID_KEYSTORE_BASE64` (`base64 -w0 pokeverse.keystore`),
   `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`pokeverse`) and `ANDROID_KEY_PASSWORD`.
   Without them the APK would be signed with a throwaway debug key, and players would have
   to uninstall before installing the next APK. Only make a new key if the keystore is lost.

## Publishing an update

1. Merge the changes into `main`.
2. Actions → **Client release** → **Run workflow** on `main`, tick **Publish**, run.
3. The workflow builds Windows, Linux and Android and creates the release
   `client-<run number>` in PokeVerse-Clients. It then pushes the new site to its
   `gh-pages` branch and waits until it is served.
   Players get the update the next time they start the client.

Pull requests that touch the client run the same build and packaging without publishing, so a broken
package shows up before anyone publishes it. They also check that the manifests
point at the PokeVerse-Clients site and releases, and that `PV_REPOS_TOKEN` can push to PokeVerse-Clients.

Players who install for the first time use the links on
`https://gitoez.github.io/PokeVerse-Clients/`, which always point at the latest release.

## How the client decides what to download

The client lists its own files with a CRC32 checksum and compares them with the manifest
for its platform. Files that are missing or different are downloaded four at a time,
checked, and written to disk every 25 files, biggest first. The window shows "File X of N",
the megabytes left (from the manifest's `sizes`), the speed and the current file.

An interrupted update (closed, crashed, lost connection) keeps the files already written,
so the next start only downloads what is still missing. The executable and the files the
updater itself runs on (`init.lua`, `corelib`, `updater`, the styles and locales) come
last and are written together, so an interrupted update always starts again with the old,
working updater. If an `init.lua`, `corelib`, `updater` or `.otmod` file changed, or the
executable, the client restarts; otherwise it reloads its modules.

Clients from before this change use the old updater (one file at a time, everything written
at the end). They ignore `sizes`, download the new updater with the rest, and restart into it.

If GitHub cannot be reached, the client shows an error and starts normally after **Ok**.
A file that fails (a download error or a wrong checksum) is tried again after 1, 2, 4, 8 and
16 seconds before the update stops with "Can't download file".

### Why each release has its own files folder

The Pages cache keeps every URL for 10 minutes and ignores query strings. When all releases
used the same `updater/files/<path>` URLs, a file that changed (the map pictures change
thousands of files at once) could come back from the cache in its old version for up to 10
minutes after a publish, fail its checksum, and stop the update ("Invalid checksum of:
/data/images/pokepedia/..."). Reinstalling worked because the downloads come from the
release, not the cache. Now each release is in `updater/files/<release tag>/`, a URL that never
had other content, and the manifest's `url` points there; clients already build every file
URL from it, so old clients need no change. The publish keeps the previous release's folder
one more release, for clients that still get the old manifest from the cache. Two releases
of files are about 600 MB, under the 1 GB Pages size limit.

## Windows installer

`PokeVerse-Setup.exe` (NSIS, `core/client-redemption/packaging/windows/PokeVerse.nsi`) is only
another way to unpack the zip; the website offers the zip below it as a backup. It installs
the same files, and nothing else updates them afterwards except the updater:

- It installs to `%LOCALAPPDATA%\Programs\PokeVerse` without administrator rights. Another folder
  can be picked, but it always ends in `PokeVerse`, and Program Files and Windows are refused:
  the updater could not write there.
- It adds a Start menu shortcut and, if the box is ticked, a desktop shortcut, plus an entry in
  Installed apps. The entry has no version, because the updater changes the files.
- Uninstalling removes the game folder and the shortcuts. It asks before deleting the settings
  in `%APPDATA%\PokeVerse` (No by default, and always No with `/S`).
- Running an older installer over a newer game is harmless: the next start downloads what differs.
- The release job builds it on Linux (`apt install nsis`); `scripts/art/installer_art.py` draws
  its side picture.
- It is not code-signed, so Windows SmartScreen shows "unknown publisher", the same as for the exe.

## Platform notes

- **Windows and Linux:** the executable updates itself under the same name, so shortcuts
  keep working. The running file is renamed to `PokeVerse.exe.old` (`PokeVerse.old` on Linux),
  the new one is written in its place, and the old copy is deleted on a later start.
- **Settings on Windows** (options, hotkeys, the remembered account, the log) are in
  `%APPDATA%\PokeVerse\`. Earlier engines nested them as `%APPDATA%\pokeverse\pokeverse\pokeverse\`;
  the first start of the new engine moves them up and removes the empty folders.
  Remembered passwords keep working, because their key still uses the old folder's name. Rolling back to an
  older engine would start with default settings, since it looks in the old folder. Linux keeps
  `~/.local/share/pokeverse/.pokeverse/`.
- **Linux:** players start the game with `PokeVerse.sh` (or by double-clicking
  `PokeVerse.desktop` in the game folder). The launcher changes to the game folder, starts
  `./PokeVerse`, and keeps a "PokeVerse" entry with the icon in the app menu
  (`~/.local/share/applications/pokeverse.desktop`) pointing at that folder;
  `sh PokeVerse.sh --remove-menu-entry` removes it. Installs from before the rename keep
  their engine as `./otclient` (the updater replaces it under its own name), and the
  launcher starts that instead. Files from the updater are not executable, so both
  shortcuts run the launcher with `sh`. Desktop entries cannot use relative paths, so
  `PokeVerse.desktop` finds the game folder from its own location (`%k`, which KDE
  passes but GNOME's GLib does not), then from the app menu entry, then by looking for
  `PokeVerse/PokeVerse.sh` up to four folders deep in the home folder. GNOME may ask the
  player to right-click it and pick "Allow Launching" the first time. The source files
  are in `core/client-redemption/packaging/linux/`.
- **Android:** the APK carries the client files as `data.zip` and unpacks them on first
  start; after that the updater keeps them current like on the other platforms. Android
  apps cannot restart themselves, so after an update the client asks the player to reopen
  it. The engine cannot update itself on Android: engine changes need the new APK, which
  installs over the old one. On its first start a new APK unpacks its own files again
  (it remembers which `data.zip` it unpacked in `game_data.apk`), so the new Lua and
  updater run straight away and only download what changed since the APK was built.
  Settings live outside `game_data` and are kept. The APK is built for 64-bit ARM
  phones (`arm64-v8a`), which covers current Android devices.
- **Android in the background:** while updating or logged in, leaving the app starts a
  foreground service with a notification ("PokeVerse is updating in the background" with
  a progress bar, or "PokeVerse is still connected"), so Android does not freeze the game.
  Coming back to the app removes it. Android 13 and newer ask once for permission to show
  notifications. This needs the APK from this change; older APKs behave as before.

## Rolling back

Revert the change on `main` and publish again. Clients compare checksums, not version
numbers, so they download the reverted files like any other update.

## Building the APK locally

```bash
export ANDROID_HOME=<Android SDK with ndk;29.0.13599879 and cmake;3.22.1> VCPKG_ROOT=<vcpkg checkout>
scripts/build-android-client.sh --host <server> build/android/PokeVerse.apk
```

The first build compiles the Android libraries through vcpkg, which takes a while.

## Testing locally

```bash
scripts/assemble-redemption-client.sh --updater http://127.0.0.1:8099/ /tmp/upd/v1 core/client-redemption/otclient
python3 scripts/make-updater-manifest.py --package <newer package> --os linux --site /tmp/upd/site \
  --files-url http://127.0.0.1:8099/files --version test --release-dir /tmp/upd/site/release \
  --release-url http://127.0.0.1:8099/release --binary otclient
```

Serve `/tmp/upd/site` over HTTP/1.1 (the client's HTTP library does not accept HTTP/1.0
replies, which Python's default `http.server` sends), then start `/tmp/upd/v1/otclient`.
