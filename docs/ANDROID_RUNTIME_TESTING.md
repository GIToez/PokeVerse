# Android Runtime Testing

The Android client (`arm64-v8a` APK) builds in CI (`platforms.yml`, "Android Redemption client"). It has **never been installed or run**: the CI runners and the development VM have no Android device and no KVM for an emulator. Every runtime row below is NOT TESTED until someone runs it. A successful build is not evidence that the client works (`PLATFORM_COMPATIBILITY.md`).

Android uses the same game protocol as the desktop clients, so the PokeVerse server needs no changes. What differs is the network setup, packaging (`data.zip` inside the APK), touch input and screen size.

## What you need

- An ARM64 Android phone or tablet (Android 8.0 or newer), with USB debugging enabled. Alternatively, an emulator with an `arm64-v8a` system image: on Apple Silicon or an ARM64 host it runs natively; on x86_64 hosts the image needs ARM translation (Android 11+ Google APIs images).
- `adb` from the Android SDK platform-tools.
- `PokeVerse-Android-arm64.apk` from the CI artifact `PokeVerse-Android-arm64` or a GitHub Release (`DOWNLOAD_AND_RUN.md`), or a local build (`BUILD_REDEMPTION.md`, "Android ARM64"). `adb` is optional: opening the APK on the phone installs it too.
- A PokeVerse server on the same private network: the Windows or Linux development package (`DOWNLOAD_AND_RUN.md`).

## Point the server at your network (DEVELOPMENT ONLY)

The development server listens on 127.0.0.1 and tells clients to connect to 127.0.0.1. On a phone, 127.0.0.1 is the phone itself, so you must change this.

1. Find the server PC's private address, for example `192.168.1.20` (`ipconfig` on Windows, `ip addr` on Linux).
2. In the server's `config.lua` set:

   ```lua
   ip = "192.168.1.20"
   bindOnlyConfiguredIpAddress = true
   ```

   The login server now listens on that address, and the character list sends it as the world address.
3. Allow inbound TCP 7564 (login) and 8548 (game) from the private network in the PC firewall.
4. Restart the server.
5. On the phone's login screen, type the same address in the server field (the Android build shows an editable server address and port; the desktop builds connect to 127.0.0.1 without one). Keep port 7564.

The development accounts have public passwords. Only do this on a private network you control, never on a public or shared one, and switch `ip` back to `127.0.0.1` afterwards.

For an emulator on the same PC, the host is `10.0.2.2` from inside the emulator. In that case set `ip = "10.0.2.2"` with `bindOnlyConfiguredIpAddress = false`, which makes the server listen on every interface; keep the PC firewall closed to the network while doing so.

## Install

```bash
adb devices                      # the phone must be listed as "device"
adb install -r PokeVerse-Android-arm64.apk
adb logcat -c
adb logcat | grep -i -E "otclient|pokeverse|lua|fatal" > android-logcat.txt
```

Keep the `logcat` capture running while testing, and attach it to every FAIL.

## Checklist

Mark each row **PASS**, **FAIL** or **NOT TESTED** and add a note. Record the device model, Android version and GPU.

| # | Check | Expected | Result |
|---|---|---|---|
| A1 | Install | `adb install` reports Success | |
| A2 | First launch | `data.zip` unpacks; the language picker appears; no crash | |
| A3 | Orientation and scaling | Login screen fits in landscape; text readable; nothing off-screen | |
| A4 | Login screen | Enter the server address (`192.168.1.20`), port 7564, client version 854; `player`/`player` | |
| A5 | Character list | Trainer listed | |
| A6 | Enter game | Map, NPCs and HUD render; correct colours; no missing sprites | |
| A7 | Movement | Joystick or tap-to-walk moves the character; the position stays in sync | |
| A8 | Chat | On-screen keyboard opens; a line is sent and shown | |
| A9 | Pokémon bar (GM Admin with `/cb Charmander, 15, 10`) | Tap a portrait to summon | |
| A10 | Move bar | Tap a move on a target; cooldown shows | |
| A11 | Windows | Pokémon Info, Pokédex, Battle Pass, tasks, shop, market open and can be closed by touch | |
| A12 | Long press / right click equivalent | Context actions (look, use, attack) reachable | |
| A13 | Background and resume | Home button, then back: the client reconnects or stays connected | |
| A14 | Screen off for one minute | No crash; the session either survives or reports a disconnect | |
| A15 | Network loss (airplane mode for 10 s) | A disconnect message, no crash; logging in again works | |
| A16 | Battery and heat | Note after 15 minutes of play | |
| A17 | Exit | Closing from the menu or the app switcher leaves no crash report | |

## Known risks to look for

- The production profile disables modules the server cannot serve (`CLIENT_VARIANTS.md`). Check that no disabled module is needed for touch input.
- Several PokeVerse windows were designed for a mouse at 1024×768. Small buttons may be hard to tap; note which.
- The `UICreature` sprites and the 854 SPR are large. Watch memory warnings in logcat on low-end devices.
- Software keyboard focus inside the market search and price fields.

## After testing

Put the results in `PLATFORM_COMPATIBILITY.md` (Android column), with the APK's CI run id. Until then the Android status stays: build PASS, runtime NOT TESTED.
