# [![steam][f8]®](https://developer.valvesoftware.com/wiki/SteamCMD) Steam (SteamCMD)

> This is **NOT** an official Valve steam docker container.

Generic Steam dedicated server using Docker.

This provides a core installation of `steamcmd` to host dedicated servers. Both
linux and windows servers can be hosted using this image.

## How it Runs
The docker image contains a base ubuntu install with wine (windows support) and
an up to date steamcmd utility installed.

After launching the container:
1. Permisssions are propagated for user `steam`.
1. OS is updated (if enabled).
1. steamcmd is updated (if enabled).
1. specific steam dedicated server is updated (if enabled).
1. Execution passed to `/data/custom_server` as **root**.

   * You must create this script in your `/data` directory and set it
     executable.
   * See [custom server](#custom-server) for documentation.

## Example Configurations
Fully working examples of different dedicated servers.

* [Left 4 Dead (w/ SourceMod,MetaMod)](https://github.com/r-pufky/steam/blob/master/docs/examples/left-4-dead.md) Linux Server
* [Left 4 Dead 2 (w/ SourceMod,MetaMod)](https://github.com/r-pufky/steam/blob/master/docs/examples/left-4-dead-2.md) Linux Server
* [Conan Exiles](https://github.com/r-pufky/steam/blob/master/docs/examples/conan-exiles.md) Windows Server

## Version Tags

| Tag          | Description                                                                         |
|--------------|-------------------------------------------------------------------------------------|
| stable       | Ubuntu 18.04 with wine and steamcmd from binary repo.                               |
| latest       | Ubuntu 18.04 with latest winehq STABLE packages and steamcmd. This **WILL** break.  |
| experimental | Ubuntu 18.04 with latest winehq STAGING packages and steamcmd. This **WILL** break. |
* Containers are automatically rebuilt weekly.

## Parameters

| Parameter        | Function                                                                                 | Default        |
|------------------|------------------------------------------------------------------------------------------|----------------|
| SERVER_DIR       | Location for server files.                                                               | `/data/server` |
| STEAM            | Location of steamcmd client.                                                             |`/steam`        |
| PLATFORM         | Platform to force specify when auto updating. `linux` or `windows`.                      | `windows`      |
| STEAM_APP_ID     | Steam application ID for auto updating.                                                  | `0`            |
| STEAM_APP_EXTRAS | Optional. Additional options for steam app update.                                       | ``             |
| UPDATE_OS        | Update core OS on startup. `1` enable, `0` disable.                                      | `1`            |
| UPDATE_STEAM     | Update steamcmd on startup. `1` enable, `0` disable.                                     | `1`            |
| UPDATE_SERVER    | Update dedicated server specified by `STEAM_APP_ID` on startup. `1` enable, `0` disable. | `1`            |
| PUID             | User ID to run steamcmd under as well as mount permissions.                              | `1000`         |
| PGID             | Group ID to run steamcmd under as well as mount permissions.                             | `1000`         |
| LANG             | Language environment to use in containers.                                               | `en_US.UTF-8`  |
| LANGUAGE         | Language environment to use in containers.                                               | `en_US:UTF-8`  |
| LC_ALL           | Language environment to use in containers.                                               | `en_US.UTF-8`  |

## Ports
Default ports exposed by the container. Additional ports for servers can be
exposed during docker configuration.

See [Required Ports for Steam](https://support.steampowered.com/kb_article.php?ref=8571-GLVN-8711)
for a detailed list of steam ports.

| Port  | Protocol | Required? | Description             |
|-------|----------|-----------|-------------------------|
|`27015`| TCP      | Optional  | SRCDS RCON port.        |
|`27015`| UDP      | Mandatory | Gameplay traffic.       |
|`27016`| UDP      | Optional  | Steam announce traffic. |

## Volumes

| Volume  | Function                                   |
|---------|--------------------------------------------|
| /data   | User data location for images.             |

## User/Group IDs
When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`PUID` and `PGID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.


## Detailed Usage Instructions
Details how to setup a new server from scratch. See [Example Configurations](#example-configurations)
for working examples.

### docker-compose (windows dedicated server)
```
---
version: "3"
services:
  steam:
    image: rpufky/steam:stable
    restart: unless-stopped
    ports:
      - 27015:27015
      - 27015:27015/udp
      - 27016:27016/udp
    environment:
      - PUID=1000
      - PGID=1000
      - UPDATE_OS=1
      - UPDATE_STEAM=1
      - UPDATE_SERVER=1
      - PLATFORM=windows
      - STEAM_APP_ID=443030
      - TZ=America/Los_Angeles
    volumes:
      - /my/docker/server/data:/data
      - /etc/localtime:/etc/localtime:ro
```

### docker-compose (linux dedicated server)
```
---
version: "3"
services:
  steam:
    image: rpufky/steam:stable
    restart: unless-stopped
    ports:
      - 27015:27015
      - 27015:27015/udp
      - 27016:27016/udp
    environment:
      - PUID=1000
      - PGID=1000
      - UPDATE_OS=1
      - UPDATE_STEAM=1
      - UPDATE_SERVER=1
      - PLATFORM=linux
      - STEAM_APP_ID=294420
      - TZ=America/Los_Angeles
    volumes:
      - /my/docker/server/data:/data
      - /etc/localtime:/etc/localtime:ro
```

## Custom Server
`/data/custom_server` is the script that will be called when the docker
container is launched. This is under your control to allow you to setup the
server however you wish. You **must create this script** and it **must** be
executable.

[supervisord](supervisord.org) has been provided for service convenience.

Dedicated server files are installed automatically to `${SERVER_DIR}`, and all
docker environment variables are avaliable for use.

Do any pre-launch configuration here (e.g. update or install mods, backups,
etc.). Any files created will belong to **root** so ensure that permissions are
changed.

Remember to **drop privileges** before launching server, this will ensure
minimum exposure if there are vulnerabilities in the game, as well as prevent
any permissions issues with server files.

```
su steam -c 'your server launch command'
```

> Your specific launch command will vary based on what server you install.
> Check dedicated server documentation for that game.

### Linux Example
This will launch a **Left 4 Dead** ``srcsd_run`` linux dedicated server.

```
su steam -c "/data/server/srcds_run -console -game left4dead -map l4d_hospital01_apartment -port 27015 +maxplayers 4 -nohltv +exec /data/server.cfg"
```
* this example would launch a Left 4 Dead dedicated server (222840).

### Windows Example
All flavors of wine are installed (wind, wine32 and wine64). Check specific
dedicated server documentation and forums for launching a dedicated windows
server under wine for your game.

```bash
su steam -c "xvfb-run --auto-servernum \
  wine64 ${SERVER_DIR}/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log"
```
* This example lauches a conan exiles dedicated server (443030).

> It is important to note that we must bring up a lightweight window manager
> to launch these servers. This is what `xvfb-run --auto-servernum` does.

### Dedicated Server with **NO** Saves / Saved States
For servers that don't require saving of state between reboots, a simple bash script will handle the server just fine:

Windows
```bash
# This will run wine (for windows servers) and launch the server.
su steam -c "xvfb-run --auto-servernum \
  wine64 ${SERVER_DIR}/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -nosteamclient -game -server -log"
```

Linux
```bash
# launch the dedicated linux server under the steam user.
su steam -c "/data/server/startserver.sh \
  -configfile=/data/server/serverconfig.xml"
```

### Dedicated Server requiring Saves / Saved States (Bash)
If the dedicated server requires specific saving of state on shutdown, bash can be used to manage the shutdown process. This works for simplier dedicated servers. More complex servers should consider the included supervisord process manager.

Ensure that the docker container is given [more than 10 seconds][2k] for shutdown if needed:
```
services:
  steam:
    image: rpufky/steam:latest
    restart: unless-stopped
    stop_grace_period: 1m
    ...
```

/data/custom_server:
```bash
#!/bin/bash
#
# Runs as Root. Drop privileges.
#
# Capture kill/term signals and send SIGINT to gracefully shutdown conan
# server.
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
  # Using background with wait enables signal trap capture.
  sleep ${WATCHDOG_TIME} &
  wait
done
```

### Dedicated Server requiring Saves / Saved States (Supervisord)
[supervisor](supervisord.org) has been provided for service convenience. If you
want to manage you server with a process manager just set `/data/custom_server`
to:

```bash
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
```

Then place all of your supervisord configuration files in `/data/supervisord` and ensure that the correct permissions are set. Supervisord will launch as **root**, and you should execute your server with `user=steam` to drop privileges for your processes.

A [good supervisord example][3n] using a Conan Exiles server is
[located here.][3n]

Ensure that the docker container is given [more than 10 seconds][2k] for shutdown if needed:
```
services:
  steam:
    image: rpufky/steam:latest
    restart: unless-stopped
    stop_grace_period: 1m
    ...
```

## Winetricks
[winetricks](https://wiki.winehq.org/Winetricks) is installed to
`/usr/bin/winetricks` and may be used in `custom_server` to apply specific
patches; remember to switch to the `steam` user when executing this commands.

custom_server
```bash
su steam -c "winetricks dotnet472"
su steam -c "winetricks vcrun2013"
```

## Building
Both debian-slim and ubuntu images build within about 2-3MB of each other, so
only the ubuntu base is used. build using included makefile:

Main steam image with ubuntu wine repository:
```bash
sudo make steam
```

Steam image using winehq repository:
```bash
sudo make latest
```

## Troubleshooting

### Failed to determine free disk space for ... error 75
This happens when steamcmd is downloading an app because the underlying data
store cannot be queried for a quota. Common with ZFS backed data stores.
Either set an explicit qouta or ignore it.

```
sudo zfs set quota=2T zpool1/docker
```

### Windows (wine) takes ~5 minutes to launch on first boot
Wine may block on boot events during the first boot. This is expressed by an
approximate 5 minute pause during these messages:

> _"0014:err:ole:get_local_server_stream Failed: 80004002"_
>
> _"__wine_kernel_init boot event wait timed out"_

Subsequent boots will not see the delay. This should be mitigated in the
container build already, but can manually be run with:

```bash
wineboot --update
```

```bash
xvfb-run --autoservernum wineboot --update
```

This is a suspected issue with the GCC build toolchain, but has not been
resolved yet. See:
* https://ubuntuforums.org/archive/index.php/t-1499348.html
* https://bugs.winehq.org/show_bug.cgi?id=38653

### 'cat: hlds.{PID}.pid: No such file or directory'
This happens when `srcds_run` cannot write a PID to the autogenerated PID file.

Manually specify a PID file to use in the container that the **steam** user has
access to.

``` bash
srcds_run ... -pidfile /data/server/{GAME}.pid
```

## Licensing
Steam Logo, SteamCMD ©2019 Valve Corporation. Steam and the Steam logo are
trademarks and/or registered trademarks of Valve Corporation in the U.S.
and/or other countries.

[3n]: https://github.com/alinmear/docker-conanexiles/blob/master/src/etc/supervisor/conf.d/conanexiles.conf
[2k]: https://docs.docker.com/compose/compose-file/#stop_grace_period
[f8]: https://raw.githubusercontent.com/r-pufky/steam/master/media/steam-icon-logo.png
