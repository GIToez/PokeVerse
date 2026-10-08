#!/usr/bin/env python3
"""End-to-end test of an extracted PokeVerse-Windows-Dev package on Windows.

Uses only the package's own .bat files and binaries, with PATH reduced to the
Windows system folders so nothing from a compiler or developer tool is picked up:

  1. Setup Database.bat (twice: the second run must keep existing data)
  2. Create Account.bat
  3. Start Server.bat, wait for "server Online!"
  4. protocol-test.py: wrong password refused, login, character list, game login, movement
  5. Database checks: positions saved, starting items present
  6. Client smoke test: pokeverse-client.exe starts and loads its modules

Usage: test-package-windows.py <package dir> [--logs <dir>]
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))


def step(text):
    print(f"\n=== {text}", flush=True)


def fail(text):
    print(f"FAIL: {text}", flush=True)
    sys.exit(1)


def clean_env():
    windir = os.environ.get("SystemRoot", r"C:\Windows")
    env = dict(os.environ)
    env["PATH"] = ";".join([
        os.path.join(windir, "System32"),
        windir,
        os.path.join(windir, "System32", "Wbem"),
        os.path.join(windir, "System32", "WindowsPowerShell", "v1.0"),
    ])
    env["PV_NO_PAUSE"] = "1"
    return env


def cmd_line(bat, *args):
    # A plain string is passed to CreateProcess unchanged; a list would get its quotes
    # escaped as \" by subprocess, which cmd.exe does not understand.
    inner = f'call "{bat}"' + "".join(f' "{a}"' for a in args)
    return f'cmd.exe /d /c "{inner}"'


def run_bat(pkg, name, *args, check=True):
    print(f"> {name} {' '.join(args)}", flush=True)
    # Output goes to a file, not a pipe: the database started by the script inherits the
    # handle and would keep a pipe open forever.
    with tempfile.TemporaryFile() as out:
        try:
            result = subprocess.run(cmd_line(os.path.join(pkg, name), *args), cwd=pkg, env=clean_env(),
                                    stdin=subprocess.DEVNULL, stdout=out, stderr=subprocess.STDOUT, timeout=600)
        except subprocess.TimeoutExpired:
            out.seek(0)
            print(out.read().decode("latin-1"), flush=True)
            fail(f"{name} did not finish within 10 minutes")
        out.seek(0)
        print(out.read().decode("latin-1"), flush=True)
    if check and result.returncode != 0:
        fail(f"{name} exited with code {result.returncode}")
    return result


def sql(pkg, query):
    mariadb = os.path.join(pkg, "database", "mariadb", "bin", "mariadb.exe")
    result = subprocess.run([mariadb, "--no-defaults", "--protocol=tcp", "-h127.0.0.1", "-P3307",
                             "-upokeverse", "-ppokeverse", "-N", "-B", "pokeverse", "-e", query],
                            env=clean_env(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, errors="replace", timeout=120)
    if result.returncode != 0:
        fail(f"query failed: {query}\n{result.stdout}")
    return result.stdout.strip()


def protocol_test(*args):
    cmd = [sys.executable, os.path.join(HERE, "protocol-test.py"), *args]
    print("> protocol-test.py " + " ".join(args), flush=True)
    if subprocess.run(cmd, timeout=180).returncode != 0:
        fail("protocol test failed: " + " ".join(args))


def wait_for(predicate, timeout, interval=1.0):
    deadline = time.time() + timeout
    while time.time() < deadline:
        if predicate():
            return True
        time.sleep(interval)
    return False


def read(path):
    try:
        with open(path, encoding="latin-1") as f:
            return f.read()
    except OSError:
        return ""


def send_keys(keys):
    """Types into the PokeVerse client window (Windows SendKeys syntax)."""
    script = ("$w = New-Object -ComObject WScript.Shell; "
              "if (-not $w.AppActivate('PokeVerse')) { exit 2 }; Start-Sleep -Milliseconds 300; "
              f"$w.SendKeys('{keys}')")
    return subprocess.run(["powershell", "-NoProfile", "-Command", script], timeout=60).returncode == 0


def run_client(client_dir, env, logs, tag, pkg):
    client_log = os.path.join(os.environ.get("USERPROFILE", ""), "pokeverse.log")
    if os.path.exists(client_log):
        os.remove(client_log)
    client = subprocess.Popen([os.path.join(client_dir, "pokeverse-client.exe")], cwd=client_dir, env=env)
    time.sleep(25)
    alive = client.poll() is None
    text = read(client_log)
    # Release builds do not log "Loaded module" (debug level), so look for errors instead.
    errors = [l for l in text.splitlines() if "FATAL" in l or "Unable to load module" in l]
    print(text[-3000:])
    print(f"[{tag}] running after 25 s: {alive}; exit code: {client.poll()}; fatal/module errors: {len(errors)}")
    ok = alive and not errors and "application started" in text

    if ok:
        # Log in like a player: account, password, Enter; close the message of the day;
        # choose the character; walk; then check the server saw it.
        before = sql(pkg, "SELECT CONCAT(posx, ',', posy) FROM players WHERE name = 'Trainer'")
        steps = [("test{TAB}test{ENTER}", 6), ("{ENTER}", 3), ("{ENTER}", 10)]
        typed = True
        for keys, wait in steps:
            typed = typed and send_keys(keys)
            time.sleep(wait)
        online = sql(pkg, "SELECT online FROM players WHERE name = 'Trainer'")
        print(f"[{tag}] keyboard input sent: {typed}; Trainer online: {online}")
        if typed and online == "1":
            for _ in range(3):
                send_keys("{DOWN}")
                time.sleep(1)
            send_keys("^q")
            time.sleep(2)
            send_keys("{ENTER}")
            wait_for(lambda: sql(pkg, "SELECT online FROM players WHERE name = 'Trainer'") == "0", 30)
            after = sql(pkg, "SELECT CONCAT(posx, ',', posy) FROM players WHERE name = 'Trainer'")
            print(f"[{tag}] GUI login: in game; position before {before}, after logout {after}")
        else:
            print(f"[{tag}] GUI login could not be confirmed (keyboard automation on this runner)")
        ok = client.poll() is None

    if os.path.exists(client_log):
        shutil.copy(client_log, os.path.join(logs, f"client-{tag}.log"))
    if client.poll() is None:
        client.kill()
    return ok


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("package")
    parser.add_argument("--logs", default=None, help="folder to copy logs into")
    parser.add_argument("--skip-client", action="store_true")
    parser.add_argument("--mesa", default=None, help="folder with Mesa opengl32.dll for runners without a GPU driver")
    opts = parser.parse_args()
    pkg = os.path.abspath(opts.package)
    logs = os.path.abspath(opts.logs or os.path.join(pkg, "..", "test-logs"))
    os.makedirs(logs, exist_ok=True)

    step("Package contents")
    for rel in ["README.txt", "Setup Database.bat", "Start Server.bat", "Start Client.bat",
                "Start Server and Client.bat", "Create Account.bat", "Stop Database.bat",
                r"server-windows\pokeverse-server.exe", r"server-windows\config.lua",
                r"server-windows\data\world\map.otbm", r"client-legacy-windows\pokeverse-client.exe",
                r"client-legacy-windows\init.lua", r"client-legacy-windows\data\things\data.spr",
                r"database\mariadb\bin\mariadbd.exe", r"database\sql\01-base-schema.sql"]:
        path = os.path.join(pkg, rel)
        if not os.path.isfile(path):
            fail(f"missing {rel}")
        print(f"ok  {rel}  ({os.path.getsize(path)} bytes)")
    for big in [r"server-windows\data\world\map.otbm", r"client-legacy-windows\data\things\data.spr"]:
        if os.path.getsize(os.path.join(pkg, big)) < 1_000_000:
            fail(f"{big} looks like a Git LFS pointer, not the real file")
    if os.path.exists(os.path.join(pkg, "server-windows", "config.local.lua")):
        fail("the package must not contain server-windows\\config.local.lua")

    server = None
    try:
        step("Setup Database.bat (fresh)")
        run_bat(pkg, "Setup Database.bat")
        step("Setup Database.bat (again, must keep data)")
        run_bat(pkg, "Setup Database.bat")
        tables = int(sql(pkg, "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'pokeverse'"))
        print(f"Tables: {tables}")
        if tables < 50:
            fail(f"expected the full schema, found {tables} tables")

        step("Create Account.bat")
        run_bat(pkg, "Create Account.bat", "newuser", "secret", "New Trainer", "0")
        if run_bat(pkg, "Create Account.bat", "newuser", "secret", "Other Name", "1", check=False).returncode == 0:
            fail("creating a duplicate account must fail")

        step("Start Server.bat")
        server_log = os.path.join(logs, "server-console.log")
        log_file = open(server_log, "w")
        server = subprocess.Popen(cmd_line(os.path.join(pkg, "Start Server.bat")),
                                  cwd=pkg, env=clean_env(), stdin=subprocess.DEVNULL,
                                  stdout=log_file, stderr=subprocess.STDOUT)
        online = wait_for(lambda: "server Online!" in read(server_log) or server.poll() is not None, 300)
        text = read(server_log)
        print("\n".join(l for l in text.splitlines()
                        if any(k in l for k in ("Global address", "Local ports", "server Online", "rror"))))
        if not online or "server Online!" not in text:
            print(text[-5000:])
            fail("server did not come online")
        if "Global address: 127.0.0.1" not in text:
            fail("server is not bound to 127.0.0.1")
        if "Discord bridge disabled" not in text:
            fail("the Discord bridge must be disabled in the shipped package")

        step("Protocol tests")
        protocol_test("--account", "test", "--password", "wrong", "--character", "Trainer", "--expect-login-failure")
        protocol_test("--account", "test", "--password", "test", "--character", "Trainer", "--walk", "east,east,south,west")
        protocol_test("--account", "admin", "--password", "admin", "--character", "Admin", "--walk", "west,north")
        protocol_test("--account", "newuser", "--password", "secret", "--character", "New Trainer", "--walk", "east,south")
        time.sleep(3)

        step("Database checks")
        print(sql(pkg, "SELECT name, level, posx, posy, posz, lastlogin > 0, online FROM players WHERE id > 1"))
        moved = sql(pkg, "SELECT COUNT(*) FROM players WHERE name IN ('Trainer', 'Admin', 'New Trainer') "
                         "AND lastlogin > 0 AND NOT (posx = 4711 AND posy = 678)")
        if moved != "3":
            fail(f"expected 3 characters saved at a new position, got {moved}")
        dex = sql(pkg, "SELECT COUNT(*) FROM player_items i JOIN players p ON p.id = i.player_id "
                       "WHERE p.name = 'New Trainer' AND i.pid = 6 AND i.itemtype = 12281")
        if dex != "1":
            fail("New Trainer has no Pokedex")
        island = sql(pkg, "SELECT CONCAT(p.town_id, ',', p.level, ',', (SELECT COUNT(*) FROM player_items i "
                          "WHERE i.player_id = p.id AND i.itemtype IN (13499, 13492, 13497, 13820))) "
                          "FROM players p WHERE p.name = 'New Trainer'")
        if island != "10,1,4":
            fail(f"New Trainer should stay on Beginner Island (town 10, level 1) with the island kit, got {island}")
        if "MYSQL ERROR" in read(server_log):
            fail("database errors in the server log")

        if not opts.skip_client:
            step("Client smoke test (as shipped)")
            client_dir = os.path.join(pkg, "client-legacy-windows")
            ok, how = run_client(client_dir, clean_env(), logs, "as-shipped", pkg), "as shipped"
            if not ok and opts.mesa:
                # CI runners have no OpenGL 2.0 driver; retry a copy of the client with Mesa's software renderer.
                step("Client smoke test (copy with Mesa software OpenGL, CI only)")
                mesa_dir = os.path.join(pkg, "..", "client-mesa-test")
                shutil.rmtree(mesa_dir, ignore_errors=True)
                shutil.copytree(client_dir, mesa_dir)
                for f in os.listdir(opts.mesa):
                    shutil.copy(os.path.join(opts.mesa, f), mesa_dir)
                env = clean_env()
                env["GALLIUM_DRIVER"] = "llvmpipe"
                ok, how = run_client(mesa_dir, env, logs, "mesa", pkg), "with Mesa software OpenGL"
            if not ok:
                fail("the client did not start")
            print(f"Client started ({how}).")

        print("\nPASS: package database setup, account creation, server start, login, "
              "character list, game login, movement and client start verified.")
    finally:
        if server is not None:
            subprocess.run(["taskkill", "/f", "/t", "/pid", str(server.pid)], stdout=subprocess.DEVNULL)
        run_bat(pkg, "Stop Database.bat", check=False)
        for src in [os.path.join(pkg, "server-windows", "logs"), os.path.join(pkg, "database", "data", "mariadb.err")]:
            if os.path.isdir(src):
                shutil.copytree(src, os.path.join(logs, "server-logs"), dirs_exist_ok=True)
            elif os.path.isfile(src):
                shutil.copy(src, logs)


if __name__ == "__main__":
    main()
