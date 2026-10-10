# Client updates (Redemption client)

Players install the Redemption client once. Every time it starts, it checks GitHub for a
newer version and downloads only the files that changed, then restarts if needed.
Nothing runs on our own servers for this, and there is no PHP.

- **GitHub Pages** hosts the update manifests (`updater/windows.json`, `updater/linux.json`,
  `updater/android.json`)
  and every file under 95 MB (`updater/files/...`). Pages does not accept files over 100 MB.
- **GitHub Releases** host the larger files (the 308 MB `data.spr`, and the executable if it
  is too big) plus the first-install downloads, `PokeVerse-Windows.zip`,
  `PokeVerse-Linux.tar.gz` and `PokeVerse-Android.apk`.
- The workflow is `.github/workflows/client-release.yml` (Actions → **Client release**).

Only the live packages have the updater turned on. Development builds (`builds/dev/`) and
the test builds never update.

## One-time setup

1. In the repository on GitHub: **Settings → Pages → Build and deployment → Source:
   GitHub Actions**.
2. Optional: set the repository variable `LIVE_SERVER_HOST` (Settings → Secrets and
   variables → Actions → Variables) if the live server address changes. Without it the
   workflow uses the current OVH address.
3. Android signing key (once, then keep it safe: Android only installs a new APK over an
   old one when both are signed with the same key). Create it with
   `keytool -genkeypair -v -keystore pokeverse.keystore -alias pokeverse -keyalg RSA -keysize 4096 -validity 10000`,
   then add these repository secrets: `ANDROID_KEYSTORE_BASE64` (`base64 -w0 pokeverse.keystore`),
   `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`pokeverse`) and `ANDROID_KEY_PASSWORD`.
   Without them the APK is signed with a throwaway debug key, which is fine for testing but
   means players would have to uninstall before installing the next APK.

## Publishing an update

1. Merge the changes into `main`.
2. Actions → **Client release** → **Run workflow** on `main`, tick **Publish**, run.
3. The workflow builds Windows, Linux and Android, creates the release `client-<run number>`, then
   deploys the new manifests to Pages. Players get the update the next time they start
   the client.

Pushes and pull requests run the same build and packaging without publishing, so a broken
package shows up before anyone publishes it.

Players who install for the first time use the links on the Pages site
(`https://gitoez.github.io/PokeVerse/`), which always point at the latest release.

## How the client decides what to download

The client lists its own files with a CRC32 checksum and compares them with the manifest
for its platform. Files that are missing or different are downloaded, checked, and written
in place. If an `init.lua`, `corelib`, `updater` or `.otmod` file changed, or the
executable, the client restarts; otherwise it reloads its modules.

If GitHub cannot be reached, the client shows an error and starts normally after **Ok**.

## Platform notes

- **Windows and Linux:** the executable updates itself under the same name, so shortcuts
  keep working. The running file is renamed to `otclient.exe.old` (`otclient.old` on Linux),
  the new one is written in its place, and the old copy is deleted on a later start.
- **Android:** the APK carries the client files as `data.zip` and unpacks them on first
  start; after that the updater keeps them current like on the other platforms. Android
  apps cannot restart themselves, so after an update the client asks the player to reopen
  it. The engine cannot update itself on Android: engine changes need the new APK, which
  installs over the old one and keeps the downloaded files. The APK is built for 64-bit ARM
  phones (`arm64-v8a`), which covers current Android devices.

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
