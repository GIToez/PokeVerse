<#
PokeVerse Windows test package helper. The .bat files in the package root call this script;
it is not meant to be run by hand (see README.txt).

  -Action Setup       create/upgrade the database, create the server's database user,
                      write server\config.lua, then verify
  -Action Reset       DROP the database (after confirmation), then Setup
  -Action Verify      connect with the credentials in server\config.lua and check every table
  -Action WaitServer  wait until the server accepts connections on -Port
  -Action PortFree    exit 1 when something already listens on -Port
  -Action Stop        send Ctrl+C to the running pokeverse-server.exe (it saves, then exits) and
                      wait up to -TimeoutSeconds for it to finish

Every value can come from a parameter, a POKEVERSE_DB_* environment variable, or a prompt.
-NonInteractive (or POKEVERSE_NONINTERACTIVE=1) never prompts and uses the defaults.
Any SQL error stops the script with exit code 1.
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Setup', 'Reset', 'Verify', 'WaitServer', 'PortFree', 'Stop')]
    [string]$Action,
    [string]$DbHost,
    [string]$DbPort,
    [string]$AdminUser,
    [string]$AdminPassword,
    [string]$Database,
    [string]$AppUser,
    [string]$AppPassword,
    [ValidateSet('Ask', 'Yes', 'No')]
    [string]$DevSeed,
    [switch]$NonInteractive,
    [switch]$Force,
    [int]$Port = 7564,
    [int]$TimeoutSeconds = 300
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$Root = Split-Path -Parent $PSScriptRoot
$ServerDir = Join-Path $Root 'server'
$DbDir = Join-Path $Root 'database'
$ConfigFile = Join-Path $ServerDir 'config.lua'
$ExampleConfig = Join-Path $ServerDir 'config.example.lua'
$Latin1 = [Text.Encoding]::GetEncoding(28591)
if ($env:POKEVERSE_NONINTERACTIVE -eq '1') { $NonInteractive = $true }

function Write-Step([string]$Text) { Write-Host "==> $Text" -ForegroundColor Cyan }
function Write-Ok([string]$Text) { Write-Host "OK: $Text" -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host "WARNING: $Text" -ForegroundColor Yellow }

function Get-Setting([string]$Value, [string]$EnvName, [string]$Prompt, [string]$Default) {
    if ($Value) { return $Value }
    $fromEnv = [Environment]::GetEnvironmentVariable($EnvName)
    if ($fromEnv) { return $fromEnv }
    if ($NonInteractive) { return $Default }
    $answer = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
    return $answer.Trim()
}

function Get-Secret([string]$Value, [string]$EnvName, [string]$Prompt, [string]$Default) {
    if ($Value) { return $Value }
    $fromEnv = [Environment]::GetEnvironmentVariable($EnvName)
    if ($null -ne $fromEnv) { return $fromEnv }
    if ($NonInteractive) { return $Default }
    $suffix = ''
    if ($Default) { $suffix = ' (Enter = default)' }
    $secure = Read-Host "$Prompt$suffix" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    if (-not $plain) { return $Default }
    return $plain
}

function Assert-Name([string]$Value, [string]$What) {
    if ($Value -notmatch '^[A-Za-z0-9_]+$') { throw "$What '$Value' may only contain letters, digits and _" }
}

function Find-MysqlClient {
    if ($env:POKEVERSE_MYSQL) {
        if (Test-Path -LiteralPath $env:POKEVERSE_MYSQL) { return (Resolve-Path -LiteralPath $env:POKEVERSE_MYSQL).Path }
        throw "POKEVERSE_MYSQL points to '$env:POKEVERSE_MYSQL', which does not exist"
    }
    foreach ($name in 'mariadb.exe', 'mysql.exe') {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    $candidates = @(
        "$env:ProgramFiles\MariaDB*\bin\mariadb.exe",
        "$env:ProgramFiles\MariaDB*\bin\mysql.exe",
        "${env:ProgramFiles(x86)}\MariaDB*\bin\mysql.exe",
        "$env:ProgramFiles\MySQL\MySQL Server*\bin\mysql.exe",
        'C:\xampp\mysql\bin\mysql.exe',
        'C:\laragon\bin\mysql\*\bin\mysql.exe',
        'C:\wamp64\bin\mariadb\*\bin\mariadb.exe',
        'C:\wamp64\bin\mariadb\*\bin\mysql.exe'
    )
    foreach ($pattern in $candidates) {
        $hit = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    throw ("No MariaDB client found (mariadb.exe or mysql.exe). Install MariaDB Server from https://mariadb.org/download/ " +
        "(it includes the client), or set POKEVERSE_MYSQL to the full path of mariadb.exe.")
}

function ConvertTo-OptionValue([string]$Value) {
    return '"' + ($Value -replace '\\', '\\' -replace '"', '\"') + '"'
}

function ConvertTo-SqlString([string]$Value) {
    return "'" + ($Value -replace '\\', '\\' -replace "'", "''") + "'"
}

# Runs SQL through the mariadb client. The password goes through a temporary option file,
# never the command line. A non-zero exit code or an ERROR line on stderr throws.
function Invoke-Sql {
    param([hashtable]$Conn, [string]$Sql, [string]$File, [string]$Db, [string]$What)
    $temp = @()
    try {
        $opt = [IO.Path]::GetTempFileName(); $temp += $opt
        $lines = @('[client]', "host=$($Conn.Host)", "port=$($Conn.Port)",
            "user=$(ConvertTo-OptionValue $Conn.User)", "password=$(ConvertTo-OptionValue $Conn.Password)",
            'default-character-set=utf8mb4')
        [IO.File]::WriteAllLines($opt, $lines)
        if ($Sql) {
            $File = [IO.Path]::GetTempFileName(); $temp += $File
            [IO.File]::WriteAllText($File, $Sql)
        }
        $out = [IO.Path]::GetTempFileName(); $temp += $out
        $err = [IO.Path]::GetTempFileName(); $temp += $err
        $arguments = @("`"--defaults-extra-file=$opt`"", '--batch', '--skip-column-names')
        if ($Db) { $arguments += "--database=$Db" }
        $p = Start-Process -FilePath $script:Mysql -ArgumentList $arguments -RedirectStandardInput $File `
            -RedirectStandardOutput $out -RedirectStandardError $err -NoNewWindow -PassThru
        $null = $p.Handle
        $p.WaitForExit()
        $stdout = [IO.File]::ReadAllText($out)
        $stderr = [IO.File]::ReadAllText($err).Trim()
        if ($p.ExitCode -ne 0 -or $stderr -match '(?m)^ERROR') {
            throw "SQL failed while ${What} (mariadb exit code $($p.ExitCode)):`n$stderr"
        }
        if ($stderr) { Write-Warn "${What}: $stderr" }
        return $stdout
    }
    finally {
        foreach ($t in $temp) { Remove-Item -LiteralPath $t -Force -ErrorAction SilentlyContinue }
    }
}

function Get-Inputs([bool]$NeedAdmin) {
    $s = @{}
    $s.Host = Get-Setting $DbHost 'POKEVERSE_DB_HOST' 'MariaDB host' '127.0.0.1'
    $s.Port = Get-Setting $DbPort 'POKEVERSE_DB_PORT' 'MariaDB port' '3306'
    if ($s.Port -notmatch '^\d+$') { throw "Port '$($s.Port)' is not a number" }
    if ($NeedAdmin) {
        $s.AdminUser = Get-Setting $AdminUser 'POKEVERSE_DB_ADMIN_USER' 'MariaDB administrator user (creates the database)' 'root'
        $s.AdminPassword = Get-Secret $AdminPassword 'POKEVERSE_DB_ADMIN_PASSWORD' "Password for $($s.AdminUser)" ''
    }
    $s.Database = Get-Setting $Database 'POKEVERSE_DB_NAME' 'Database name' 'pokeverse'
    Assert-Name $s.Database 'Database name'
    $s.AppUser = Get-Setting $AppUser 'POKEVERSE_DB_USER' 'Database user for the server' 'pokeverse'
    Assert-Name $s.AppUser 'Database user'
    $s.AppPassword = Get-Secret $AppPassword 'POKEVERSE_DB_PASSWORD' "Password for database user $($s.AppUser) (local testing default: pokeverse-dev)" 'pokeverse-dev'
    $seed = Get-Setting $DevSeed 'POKEVERSE_DB_DEVSEED' 'Install DEVELOPMENT accounts player/player and admin/admin? (Yes/No)' 'Yes'
    $s.DevSeed = $seed -match '^(y|yes)$'
    return $s
}

function Set-ConfigValue([string]$Text, [string]$Key, [string]$LuaValue) {
    $pattern = "(?m)^(\s*$Key\s*=\s*)[^\r\n]*"
    $re = New-Object Text.RegularExpressions.Regex $pattern
    if (-not $re.IsMatch($Text)) { throw "config.lua has no '$Key' line" }
    $evaluator = [Text.RegularExpressions.MatchEvaluator] { param($m) $m.Groups[1].Value + $LuaValue }.GetNewClosure()
    return $re.Replace($Text, $evaluator, 1)
}

function ConvertTo-LuaString([string]$Value) {
    return '"' + ($Value -replace '\\', '\\' -replace '"', '\"') + '"'
}

function Write-ServerConfig([hashtable]$S) {
    if (-not (Test-Path -LiteralPath $ConfigFile)) {
        if (-not (Test-Path -LiteralPath $ExampleConfig)) { throw "Missing $ExampleConfig" }
        Copy-Item -LiteralPath $ExampleConfig -Destination $ConfigFile
        Write-Ok "created server\config.lua from config.example.lua"
    }
    $text = [IO.File]::ReadAllText($ConfigFile, $Latin1)
    $text = Set-ConfigValue $text 'sqlType' '"mysql"'
    $text = Set-ConfigValue $text 'sqlHost' (ConvertTo-LuaString $S.Host)
    $text = Set-ConfigValue $text 'sqlPort' $S.Port
    $text = Set-ConfigValue $text 'sqlUser' (ConvertTo-LuaString $S.AppUser)
    $text = Set-ConfigValue $text 'sqlPass' (ConvertTo-LuaString $S.AppPassword)
    $text = Set-ConfigValue $text 'sqlDatabase' (ConvertTo-LuaString $S.Database)
    [IO.File]::WriteAllText($ConfigFile, $text, $Latin1)
    Write-Ok "server\config.lua uses $($S.AppUser)@$($S.Host):$($S.Port)/$($S.Database)"
}

function Read-ServerConfig {
    if (-not (Test-Path -LiteralPath $ConfigFile)) {
        throw "server\config.lua is missing. Extract the whole package again, then run Setup Database.bat."
    }
    $text = [IO.File]::ReadAllText($ConfigFile, $Latin1)
    $get = {
        param($key)
        $m = [regex]::Match($text, "(?m)^\s*$key\s*=\s*(""(?<s>(?:[^""\\]|\\.)*)""|(?<n>\d+))")
        if (-not $m.Success) { throw "config.lua has no '$key' value" }
        if ($m.Groups['s'].Success) { return ($m.Groups['s'].Value -replace '\\(.)', '$1') }
        return $m.Groups['n'].Value
    }
    return @{ Host = (& $get 'sqlHost'); Port = (& $get 'sqlPort'); User = (& $get 'sqlUser');
        Password = (& $get 'sqlPass'); Database = (& $get 'sqlDatabase') }
}

function Test-Database([hashtable]$Conn, [string]$Db) {
    Write-Step "Verifying database $Db as $($Conn.User)@$($Conn.Host):$($Conn.Port)"
    $listed = Invoke-Sql -Conn $Conn -Db $Db -What 'listing tables' -Sql ("SELECT table_name FROM information_schema.tables WHERE table_schema = " + (ConvertTo-SqlString $Db) + ";")
    $have = @{}
    foreach ($t in ($listed -split "`r?`n")) { if ($t.Trim()) { $have[$t.Trim().ToLowerInvariant()] = $true } }
    $requiredFile = Join-Path $DbDir 'required-tables.txt'
    $required = @(Get-Content -LiteralPath $requiredFile | Where-Object { $_.Trim() -and -not $_.StartsWith('#') } | ForEach-Object { $_.Trim() })
    $missing = @($required | Where-Object { -not $have.ContainsKey($_.ToLowerInvariant()) })
    if ($missing.Count -gt 0) {
        throw ("Database $Db is missing $($missing.Count) of $($required.Count) required tables: " + ($missing -join ', ') +
            "`nRun Setup Database.bat (or Reset Development Database.bat for a clean database).")
    }
    Write-Ok "$($required.Count) tables the server needs are present ($($have.Count) tables in total)"
    $counts = (Invoke-Sql -Conn $Conn -Db $Db -What 'counting accounts' -Sql 'SELECT (SELECT COUNT(*) FROM accounts), (SELECT COUNT(*) FROM players);').Trim() -split '\s+'
    Write-Ok "$($counts[0]) accounts, $($counts[1]) characters"
    $dev = (Invoke-Sql -Conn $Conn -Db $Db -What 'checking development accounts' -Sql "SELECT COUNT(*) FROM accounts WHERE name IN ('player','admin');").Trim()
    if ($dev -eq '2') { Write-Warn "DEVELOPMENT accounts player/player and admin/admin exist. Never expose this database or server to the internet." }
}

function Invoke-Setup([hashtable]$S, [bool]$DropFirst) {
    $admin = @{ Host = $S.Host; Port = $S.Port; User = $S.AdminUser; Password = $S.AdminPassword }
    Write-Step "MariaDB client: $script:Mysql"
    $version = (Invoke-Sql -Conn $admin -What "connecting as $($S.AdminUser)" -Sql 'SELECT VERSION();').Trim()
    Write-Ok "connected to $($S.Host):$($S.Port) as $($S.AdminUser), server version $version"
    if ($version -notmatch 'MariaDB') { Write-Warn "this is not a MariaDB server; PokeVerse is tested with MariaDB 10.11 only" }

    $db = $S.Database
    if ($DropFirst) {
        Write-Step "Dropping database $db"
        Invoke-Sql -Conn $admin -What "dropping $db" -Sql "DROP DATABASE IF EXISTS ``$db``;" | Out-Null
        Write-Ok "database $db dropped"
    }
    $exists = (Invoke-Sql -Conn $admin -What 'checking for the database' -Sql ("SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = " + (ConvertTo-SqlString $db) + ";")).Trim()
    if ($exists -eq '1') {
        Write-Step "Database $db exists: applying migrations and seeds only (Reset Development Database.bat rebuilds it)"
    }
    else {
        Write-Step "Creating database $db"
        Invoke-Sql -Conn $admin -What "creating $db" -Sql "CREATE DATABASE ``$db`` CHARACTER SET latin1;" | Out-Null
        Write-Step 'Importing database\schema\pokeaventuras.sql'
        try {
            Invoke-Sql -Conn $admin -Db $db -What 'importing pokeaventuras.sql' -File (Join-Path $DbDir 'schema\pokeaventuras.sql') | Out-Null
        }
        catch {
            Invoke-Sql -Conn $admin -What "removing the incomplete $db" -Sql "DROP DATABASE IF EXISTS ``$db``;" | Out-Null
            throw "$($_.Exception.Message)`nThe incomplete database $db was removed."
        }
        Write-Ok 'schema imported'
    }

    Write-Step "Creating or updating database user $($S.AppUser) for the server"
    $hosts = @('localhost', '127.0.0.1')
    if ($S.Host -notin @('localhost', '127.0.0.1', '::1')) { $hosts = @('%') }
    $pw = ConvertTo-SqlString $S.AppPassword
    $sql = ''
    foreach ($h in $hosts) {
        $who = "'$($S.AppUser)'@'$h'"
        $sql += "CREATE USER IF NOT EXISTS $who IDENTIFIED BY $pw;`nALTER USER $who IDENTIFIED BY $pw;`nGRANT ALL PRIVILEGES ON ``$db``.* TO $who;`n"
    }
    $sql += "FLUSH PRIVILEGES;`n"
    Invoke-Sql -Conn $admin -What 'creating the database user' -Sql $sql | Out-Null
    Write-Ok "user $($S.AppUser)@($($hosts -join ', ')) can use $db"

    $migrations = @(Get-ChildItem -LiteralPath (Join-Path $DbDir 'migrations') -Filter '*.sql' | Sort-Object Name)
    foreach ($m in $migrations) {
        Write-Step "Applying migration $($m.Name)"
        Invoke-Sql -Conn $admin -Db $db -What "applying $($m.Name)" -File $m.FullName | Out-Null
    }
    Write-Ok "$($migrations.Count) migration(s) applied"

    if ($S.DevSeed) {
        Write-Step 'Installing DEVELOPMENT accounts (database\seeds\dev_accounts.sql)'
        Invoke-Sql -Conn $admin -Db $db -What 'installing dev_accounts.sql' -File (Join-Path $DbDir 'seeds\dev_accounts.sql') | Out-Null
        Write-Ok 'accounts player/player (Trainer) and admin/admin (GM Admin) installed'
    }
    else {
        Write-Step 'Development accounts skipped'
    }

    Write-ServerConfig $S
    Test-Database @{ Host = $S.Host; Port = $S.Port; User = $S.AppUser; Password = $S.AppPassword } $db
}

# The server handles Ctrl+C like SIGQUIT on Linux: save players and the map, then exit. A process
# can only send Ctrl+C to a console it is attached to, so a hidden helper process (its console is
# thrown away) attaches to the server's console, ignores the event itself and sends it.
function Stop-Server([int]$Timeout) {
    $procs = @(Get-Process -Name 'pokeverse-server' -ErrorAction SilentlyContinue)
    if ($procs.Count -eq 0) { Write-Ok 'No PokeVerse server is running.'; return }
    $helper = @'
param([uint32]$ServerId)
Add-Type -Namespace PokeVerse -Name ConsoleCtrl -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError = true)] public static extern bool AttachConsole(uint processId);
[DllImport("kernel32.dll", SetLastError = true)] public static extern bool FreeConsole();
[DllImport("kernel32.dll", SetLastError = true)] public static extern bool SetConsoleCtrlHandler(System.IntPtr handler, bool add);
[DllImport("kernel32.dll", SetLastError = true)] public static extern bool GenerateConsoleCtrlEvent(uint ctrlEvent, uint processGroupId);
"@
[PokeVerse.ConsoleCtrl]::FreeConsole() | Out-Null
if (-not [PokeVerse.ConsoleCtrl]::AttachConsole($ServerId)) { exit 2 }
[PokeVerse.ConsoleCtrl]::SetConsoleCtrlHandler([IntPtr]::Zero, $true) | Out-Null
if (-not [PokeVerse.ConsoleCtrl]::GenerateConsoleCtrlEvent(0, 0)) { exit 3 }
Start-Sleep -Milliseconds 500
exit 0
'@
    $helperFile = Join-Path ([IO.Path]::GetTempPath()) ("pokeverse-stop-{0}.ps1" -f [Guid]::NewGuid())
    [IO.File]::WriteAllText($helperFile, $helper)
    try {
        foreach ($p in $procs) {
            Write-Step "Stopping pokeverse-server.exe (process $($p.Id)); it saves first"
            $h = Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -Wait -PassThru -ArgumentList @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$helperFile`"", '-ServerId', $p.Id)
            if ($h.ExitCode -ne 0) {
                throw "could not send Ctrl+C to process $($p.Id) (helper exit code $($h.ExitCode)); press Ctrl+C in the server window instead"
            }
        }
    }
    finally { Remove-Item -LiteralPath $helperFile -Force -ErrorAction SilentlyContinue }
    foreach ($p in $procs) {
        if (-not $p.WaitForExit($Timeout * 1000)) { throw "pokeverse-server.exe did not exit within $Timeout s" }
    }
    Write-Ok 'The server saved and stopped. Its window may ask "Terminate batch job (Y/N)?"; answer N or close it.'
}

function Test-PortOpen([int]$P) {
    $client = New-Object Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect('127.0.0.1', $P, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(1000)) { return $false }
        $client.EndConnect($async)
        return $true
    }
    catch { return $false }
    finally { $client.Close() }
}

try {
    switch ($Action) {
        'Setup' {
            $script:Mysql = Find-MysqlClient
            Invoke-Setup (Get-Inputs $true) $false
            Write-Host ''
            if (Test-Path -LiteralPath (Join-Path $Root 'Start Server and Client.bat')) {
                Write-Ok 'Database setup finished. Next: Start Server and Client.bat (or Start Server.bat, then Start Client.bat).'
            }
            else { Write-Ok 'Database setup finished. Next: Start Server.bat, then start a client.' }
        }
        'Reset' {
            $script:Mysql = Find-MysqlClient
            $s = Get-Inputs $true
            Write-Host ''
            Write-Host "!!! Reset DELETES the database '$($s.Database)' on $($s.Host):$($s.Port): every account, character, Pokemon and item in it. !!!" -ForegroundColor Red
            if (-not $Force) {
                if ($NonInteractive) { throw 'Reset needs -Force when running non-interactively' }
                $typed = Read-Host "Type the database name ($($s.Database)) to confirm, anything else cancels"
                if ($typed -cne $s.Database) { Write-Host 'Cancelled; nothing was changed.'; exit 2 }
            }
            Invoke-Setup $s $true
            Write-Host ''
            Write-Ok 'Database reset finished.'
        }
        'Verify' {
            $script:Mysql = Find-MysqlClient
            $c = Read-ServerConfig
            Test-Database @{ Host = $c.Host; Port = $c.Port; User = $c.User; Password = $c.Password } $c.Database
        }
        'WaitServer' {
            Write-Step "Waiting up to $TimeoutSeconds s for the server on 127.0.0.1:$Port"
            $start = Get-Date
            $seen = $false
            while ($true) {
                if (Test-PortOpen $Port) { Write-Ok "server is accepting connections on port $Port"; break }
                $elapsed = ((Get-Date) - $start).TotalSeconds
                if (Get-Process -Name 'pokeverse-server' -ErrorAction SilentlyContinue) { $seen = $true }
                elseif ($elapsed -gt 15) {
                    if ($seen) { throw 'pokeverse-server.exe stopped during startup; read the server window for the reason.' }
                    throw 'pokeverse-server.exe is not running; read the server window for the reason.'
                }
                if ($elapsed -gt $TimeoutSeconds) { throw "server did not open port $Port within $TimeoutSeconds s" }
                if ([int]$elapsed % 15 -eq 0) { Write-Host ("  still loading ({0:N0} s)..." -f $elapsed) }
                Start-Sleep -Seconds 1
            }
        }
        'PortFree' {
            if (Test-PortOpen $Port) { Write-Host "Port $Port is already in use (is a PokeVerse server already running?)" -ForegroundColor Yellow; exit 1 }
        }
        'Stop' { Stop-Server $TimeoutSeconds }
    }
    exit 0
}
catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
