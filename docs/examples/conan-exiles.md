# Conan Exiles
Dedicated Windows server example running Conan Exiles.

Assumes all files are based in `/d/games/conan` and have
`UID/GID` of `50500`.

### Create docker compose file.
`/d/games/conan/docker-compose.yml` (linux dedicated server)
``` yaml
---
version: "3"

services:
  conan:
    image:             rpufky/steam:stable
    restart:           unless-stopped
    stop_grace_period: 1m
    container_name:    conan
    ports:
      - '27015:27015'
      - '27015:27015/udp'
      - '27016:27016/udp'
      - '7777:7777/udp'
      - '7778:7778/udp'
    environment:
      - PUID=50500
      - PGID=50500
      - UPDATE_OS=1
      - UPDATE_STEAM=1
      - UPDATE_SERVER=1
      - PLATFORM=windows
      - STEAM_APP_ID=443030
      - TZ=America/Los_Angeles
    volumes:
      - /d/games/conan/data:/data
      - /etc/localtime:/etc/localtime:ro
```

### Start the server to download game files and stop it.
``` bash
dc up -d conan; dc logs -f
dc stop conan
```
When the message `custom_server` not found appears, all games files have been
downloaded.

### Create custom_server script.
After receiving shutdown command, Conan Exiles takes a few seconds to write
to the database before shutting down. This is handled by catching the signal
and handling gracefully in coordination with `stop_grace_period`.

`/d/games/conan/data/custom_server`
``` bash
#!/bin/bash
#
# Runs as root. Drop privileges.
#
# Capture kill/term signals and send SIGINT to gracefully shutdown conan server.
PROCESS_WAIT_TIME=25
WATCHDOG_TIME=300

function shutdown() {
  echo 'Shutting down server ...'
  if [ "$(pgrep -n Conan)" != '' ]; then
    echo "Sending SIGINT to Conan server (max ${PROCESS_WAIT_TIME} secs) ..."
    kill -SIGINT `pgrep -n Conan`
    sleep ${PROCESS_WAIT_TIME}
  fi
  if [ "$(pgrep wine)" != '' ]; then
    echo "Sending SIGINT to wine processes (max ${PROCESS_WAIT_TIME} sec) ..."
    kill -SIGINT `pgrep wine`
    sleep ${PROCESS_WAIT_TIME}
  fi
  exit 0
}
trap shutdown SIGINT SIGKILL SIGTERM

function start_server() {
  su steam -c "xvfb-run --auto-servernum wine64 ${SERVER_DIR}/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log"
}

function watch_server() {
  if ps aux | grep [C]onanSandboxServer > /dev/null; then
    echo 'Server is running ...'
  else
    echo 'Starting server ...'
    start_server &
  fi
}

while true; do
  watch_server
  # background and using wait enables trap capture.
  sleep ${WATCHDOG_TIME} &
  wait
done
```

### Add custom server configuration.
Only relevant changes shown. See [Conan Exiles Setup](https://r-pufky.github.io/docs/game/conan/index.html) for reference.

Enable better bandwidth for server.
`/d/games/conan/data/server/ConanSandbox/Saved/Config/WindowsServer/Game.ini`
``` ini
[/script/engine.gamenetworkmanager]
TotalNetBandwidth=4000000
MaxDynamicBandwidth=100000
MinDynamicBandwidth=40000
```

Set server name, password and voice/bandwidth options.
`/d/games/conan/data/server/ConanSandbox/Saved/Config/WindowsServer/Engine.ini`
``` ini
[OnlineSubsystem]
bUseBuildIdOverride=True
bHasVoiceEnabled=False
BuildIdOverride=1691868810
ServerPassword={PASS}
ServerName={SERVER NAME}

[OnlineSubsystemSteam]
ServerQueryPort=27715

[Voice]
bEnabled=False

[/script/onlinesubsystemutils.ipnetdriver]
MaxClientRate=100000
MaxInternetClientRate=100000
```

Set server admin password and disable PVP.
`/d/games/conan/data/server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini`
``` ini
[ServerSettings]
AdminPassword=dungeon1
PVPEnabled=False
```

### Add Custom Mods
Mods can be installed by downloading then copying to `/d/games/conan/data/server/Mods`.

Add mods to enable to `modlist.txt` using relative paths.
``` ini
*Pythagoras_Support_Beams.pak
*TaesArcheryFix.pak
*ExtendedCartography.pak
*StraysBackToTheFire.pak
*PRN_NPCEquipmentLoot.pak
*ConfigurableElevators.pak
*BossSmallServer.pak
*LorestoneBugFixMay2018.pak
*femaleWoPain2.pak
*Banners.pak
```

### Start Server
dc up -d conan; dc logs -f
```
