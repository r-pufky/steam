# Left 4 Dead
Dedicated Linux server example running Left 4 Dead with sourcemod and metamod.

Assumes all files are based in `/d/games/l4d` and have
`UID/GID` of `50510`.

### Create docker compose file.
`/d/games/l4d/docker-compose.yml` (linux dedicated server)
``` yaml
---
version: "3"

services:
  l4d:
    image:             rpufky/steam:stable
    restart:           unless-stopped
    container_name:    l4d
    ports:
      - '27015:27015'
      - '27015:27015/udp'
      - '27016:27016/udp'
    environment:
      - PUID=50510
      - PGID=50510
      - UPDATE_OS=1
      - UPDATE_STEAM=1
      - UPDATE_SERVER=1
      - PLATFORM=linux
      - STEAM_APP_ID=222840
      - TZ=America/Los_Angeles
    volumes:
      - /d/games/l4d/data:/data
      - /etc/localtime:/etc/localtime:ro

```

### Create custom_server script.
Left 4 dead requires server config files to be executed **from** the install
directory, so always copy the current config on startup. Repeat for other
files.

**-pidfile** must be used as the docker container cannot write to the default
PID location. This will produce a `cat: hlds.{PID}.pid: No such file or
directory` error.

`/d/games/l4d/data/custom_server`
``` bash
#!/bin/bash
#
# Runs as root. Drop privileges.
#
ln -s /d/games/l4d/server.cfg /d/games/l4d/data/server/left4dead/cfg/server.cfg 2> /dev/null
su steam -c "/data/server/srcds_run -console -game left4dead -map l4d_hospital01_apartment -port 27015 +maxplayers 4 -nohltv +exec /data/server/left4dead/cfg/server.cfg -pidfile /data/server/l4d.pid"
```

### Add custom server configuration.
`/d/games/l4d/server.cfg`
``` ini
hostname                    "{NAME}"
sv_password                 "{PASS}"
sv_allow_lobby_connect_only 0
sv_gametypes                "coop,survival,versus,teamversus"
rcon_password               "{RCON PASS}"
sv_rcon_banpenalty          360
sv_rcon_log                 1
sv_rcon_maxfailures         3
sv_rcon_minfailuretime      600

// General Play
motd_enabled          1
mp_disable_autokick   1    
sv_allow_wait_command 0
sv_allowdownload      0
sv_allowupload        0

sv_alltalk        0
sv_alternateticks 0
sv_cheats         0
sv_consistency    1
sv_contact        ""
sv_downloadurl    ""
sv_pausable       0
sv_lan            0
sv_region         1

// Rate settings
sv_minrate    40000   // Min bandwidth rate allowed on server
sv_maxrate    50000   // Max bandwidth rate allowed on server
sv_mincmdrate 0       // Minimum cmd rate (match server tickrate)
sv_maxcmdrate 67      // Minimum cmd rate (match server tickrate)

// Server Logging
sv_log_onefile 0      //Log server information to only one file.
sv_logbans     1      //Log server bans in the server logs.
sv_logecho     1      //Echo log information to the console.
sv_logfile     1      //Log server information in the log file.
sv_logflush    0      //Flush the log file to disk on each write (slow).
sv_logsdir     "logs" //Folder in the game directory where server logs will be stored.
```
See [Left 4 Dead CVARS](https://developer.valvesoftware.com/wiki/List_of_L4D_Cvars)

### Start the server to download game files and stop it.
``` bash
dc up -d l4d; dc logs -f
dc stop l4d
```

### Install metamod, sourcemod and restart server.
* [Download SourceMod Here](https://www.sourcemod.net/)
* [Download MetaMod Here](http://www.sourcemm.net/)
* [Download Custom metamod.vdf Here](https://www.metamodsource.net/vdf)

``` bash
cd /d/games/l4d/data/server/left4dead
cp /d/games/l4d/sourcemod-*.tar.gz . && tar xvf sourcemod-*.tar.gz
cp /d/games/l4d/metamod-*.tar.gz . && tar xvf metamod-*.tar.gz
cp /d/games/l4d/metamod.vdf addons

cd /d/games/l4d
dc up -d l4d; dc logs -f
```

See [Installing SourceMod](https://wiki.alliedmods.net/Installing_SourceMod) for
installation instructions. [Adding admins](https://wiki.alliedmods.net/Adding_Admins_(SourceMod))
can be done via [Steam ID's](https://steamid.io/). Admin [commands](https://wiki.alliedmods.net/Admin_Commands_(SourceMod)).
