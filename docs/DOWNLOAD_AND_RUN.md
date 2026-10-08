# Download and run PokeVerse

This page is for testers. You do **not** need a compiler, Visual Studio, MSYS2, CMake, vcpkg, Git, Android Studio or any programming tools. GitHub builds PokeVerse from the source code and packages it for you; you download the finished files and run them.

Every package is a **development build**: it runs a PokeVerse server on your own computer (address `127.0.0.1`) with development accounts whose passwords are public. Never open that server or its database to the internet.

## Where to download

| What you want | File | Where |
|---|---|---|
| Windows server + client | `PokeVerse-Windows-Dev.zip` | Actions artifacts or Releases |
| Linux server + client | `PokeVerse-Linux-Dev.tar.gz` | Actions artifacts (inside `PokeVerse-Linux-Dev.zip`) or Releases |
| Android client | `PokeVerse-Android-arm64.apk` | Actions artifacts (inside `PokeVerse-Android-arm64.zip`) or Releases |
| Compare the legacy and the Redemption client (Windows) | `PokeVerse-Client-Comparison-Windows.zip`: server, both clients and one launcher for each | Actions artifacts or Releases |
| Separate Windows packages | `PokeVerse-Server-Windows.zip`, `PokeVerse-Legacy-Windows.zip`, `PokeVerse-Redemption-Windows.zip` | Actions artifacts or Releases |
| Separate Linux packages | `PokeVerse-Server-Linux.tar.gz`, `PokeVerse-Legacy-Linux.tar.gz`, `PokeVerse-Redemption-Linux.tar.gz` | Actions artifacts (each inside a `.zip` of the same name) or Releases |
| Android client, named by client | `PokeVerse-Redemption-Android-arm64.apk` (the same APK) | Actions artifacts or Releases |

The legacy client (the original PokeVerse/PokeJornadas interface) and the Redemption client both connect to the same server. [CLIENT_COMPARISON.md](CLIENT_COMPARISON.md) explains the packages, the step-by-step Windows setup, and the feature comparison. It also explains why there is no legacy Android client.

**Latest build of any branch or pull request (GitHub Actions):**

1. Sign in to GitHub and open <https://github.com/GIToez/PokeVerse/actions/workflows/platforms.yml>.
2. Click the newest run with a green check mark (filter by branch if you need a specific one).
3. Scroll down to **Artifacts** and click `PokeVerse-Windows-Dev`, `PokeVerse-Linux-Dev` or `PokeVerse-Android-arm64`.

GitHub always delivers artifacts as a `.zip`. The Windows one *is* the package. The Linux and Android ones contain the real `.tar.gz` or `.apk`; unzip them first. Artifacts are kept for 90 days.

**Permanent versions (GitHub Releases):** <https://github.com/GIToez/PokeVerse/releases>. Each version tag (for example `v0.1.0`) has `PokeVerse-Windows-Dev-v0.1.0.zip`, `PokeVerse-Linux-Dev-v0.1.0.tar.gz`, `PokeVerse-Android-arm64-v0.1.0.apk` and `SHA256SUMS.txt` attached. No GitHub account is needed for these.

## Windows

You need Windows 10 or 11 (64-bit), a normal graphics driver, and MariaDB.

1. **Download** `PokeVerse-Windows-Dev.zip`.
2. **Extract it:** right-click the file and choose *Extract All*. You get a folder `PokeVerse-Windows-Dev`; put it anywhere, for example `C:\PokeVerse` or your Documents folder.
3. **Install MariaDB** (only once per computer): download the MSI from <https://mariadb.org/download/>, keep the defaults (service enabled, port 3306) and write down the root password you choose.
4. **Run `Setup Database.bat` once.** Press Enter to accept each default; type the MariaDB root password when asked. It ends with `Database setup: SUCCESS`. Running it again later is safe and keeps your data.
5. **Run `Start Server.bat`.** Wait until the window shows `server Online!` (one to three minutes).
6. **Run `Start Client.bat`** and log in with `player` / `player` (character Trainer) or `admin` / `admin` (GM Admin).

`Start Server and Client.bat` does steps 5 and 6 for you. To stop the server, press Ctrl+C in its window, close it, or say `/shutdown` as GM Admin; all three save first.

If Windows SmartScreen warns about the file, choose *More info* and then *Run anyway*. The development builds are not code-signed.

`Reset Development Database.bat` deletes the database and builds it again; it asks you to type the database name first. The folder's `README.txt` has the details and a troubleshooting list.

Always start the client with `Start Client.bat` (or `client\pokeverse-client.exe`) from the extracted package, not an `.exe` from a source checkout, a build folder or the original PokeJornadas files. The client checks at startup that its images are there; if they are not, it stops with "The client folder ... has no images" and names the folder it was started from. The `Work directory` line in `client\pokeverse.log` shows the same. The upstream self-updater, which started a different `pokeverse*.exe` found next to the client and deleted the others, is disabled.

## Linux

You need 64-bit Linux with glibc 2.38 or newer (Ubuntu 24.04 or newer, Debian 13, Fedora 39 or newer), a desktop session with a graphics driver, and MariaDB.

1. **Download** `PokeVerse-Linux-Dev.tar.gz` (unzip the artifact `.zip` first if it came from Actions).
2. **Extract it** with tar, which keeps the scripts executable:

   ```bash
   tar -xzf PokeVerse-Linux-Dev.tar.gz
   cd PokeVerse-Linux-Dev
   ```

3. **Install MariaDB** if needed: `sudo apt install mariadb-server` (Debian/Ubuntu) or `sudo dnf install mariadb-server` (Fedora), then `sudo systemctl enable --now mariadb`.
4. **Run `./setup-database.sh` once.** It may ask for your sudo password (it uses `sudo mariadb` as the database administrator). It ends with `Database setup: SUCCESS`; running it again is safe. `./setup-database.sh --reset` deletes and rebuilds the database after you confirm.
5. **Run `./start-server.sh`** and wait for `server Online!`. Ctrl+C saves and stops it.
6. **In a second terminal, run `./start-client.sh`** and log in as above.

## Android

You need an ARM64 Android phone or tablet (Android 8 or newer, which is nearly every phone made since 2017) and a PC on the same Wi-Fi running the Windows or Linux package.

1. **Download** `PokeVerse-Android-arm64.apk` on the phone, or download it on the PC and copy it over (USB cable, cloud drive, e-mail). If it came from Actions, unzip `PokeVerse-Android-arm64.zip` first.
2. **Open the APK** on the phone. If Android asks, allow installing apps from that source (the browser or file manager you opened it with), then tap *Install*.
3. **Launch PokeVerse.** The first start unpacks the game data and takes a little longer.

The phone cannot use `127.0.0.1` (on a phone that address is the phone itself). On the login screen, type the PC's local address (for example `192.168.1.20`; run `ipconfig` on Windows or `ip addr` on Linux to find it) in the server field and keep port `7564`. The PC's server must be set to listen on that address first; follow "Point the server at your network" in [ANDROID_RUNTIME_TESTING.md](ANDROID_RUNTIME_TESTING.md).

Installing a newer APK over an older one keeps your settings and replaces the game data. If Android says *App not installed* or reports a signature conflict, the two builds were signed with different development keys: uninstall PokeVerse first, then install the new APK.

## What is still needed on a clean computer

| Platform | Install yourself | Included in the package |
|---|---|---|
| Windows | MariaDB Server; a graphics driver with OpenGL (already present on normal PCs) | server and client executables, every DLL the server needs (MinGW runtime, Boost, Lua, libxml2, OpenSSL, MariaDB client library), the C runtime is built into the client, game data, map, database schema and migrations |
| Linux | MariaDB Server (provides the `mariadb` command the scripts use); OpenGL/X11 graphics libraries (present on any desktop install); glibc 2.38+ | server and client executables, the server's shared libraries in `server/lib/` (Boost, Lua, libxml2, OpenSSL, ICU, MariaDB client, libstdc++), game data, map, database schema and migrations |
| Android | nothing | the whole client and its game data |

MariaDB is the only external program you have to install to run a server.

## For developers

Building from source is described in [BUILD_WINDOWS.md](BUILD_WINDOWS.md), [BUILD_SERVER_WINDOWS.md](BUILD_SERVER_WINDOWS.md), [BUILD_SERVER_LINUX.md](BUILD_SERVER_LINUX.md) and [BUILD_REDEMPTION.md](BUILD_REDEMPTION.md). It is never required just to test.

The packages come from `.github/workflows/platforms.yml`. Each package goes through the same pipeline: source, then build, stage, validate, upload, end-to-end test.

- **Package scripts:** `tools/package_windows.sh`, `tools/package_linux.sh`, and the Android steps of `android-client`.
- **Validators:** `tools/validate_windows_package.sh --check-imports`, `tools/validate_linux_package.sh` and `tools/validate_android_apk.sh`. They refuse incomplete packages, Git LFS pointer files, unsigned APKs and test-harness content, and they fail the workflow before anything is uploaded.
- **End-to-end tests:** after uploading, CI runs each package outside the checkout, through its own launchers. The Windows test is the `windows-package` job and the Linux test is `tools/test_linux_package.sh`. Both cover database setup, server start, ports, character list, entering the game and a clean stop.
- **Releases:** pushing a tag `vX.Y.Z` runs the same workflow, and the `release` job attaches the three files to that tag's GitHub Release.
- **Android signing:** to give every APK the same signature, so updates install without uninstalling, add the repository secrets `POKEVERSE_ANDROID_DEV_KEYSTORE_BASE64` (a base64-encoded development keystore), `POKEVERSE_ANDROID_DEV_KEYSTORE_PASSWORD` and `POKEVERSE_ANDROID_DEV_KEY_ALIAS`. Never commit a keystore, and never use a production key for development builds.

Any change that affects compiling or packaging must keep these artifacts building. A feature is not integrated until the Platforms workflow produces all three packages.
