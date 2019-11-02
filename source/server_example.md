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

## Parameters

| Parameter     | Function                                                                                 | Default        |
|---------------|------------------------------------------------------------------------------------------|----------------|
| SERVER_DIR    | Location for server files.                                                               | `/data/server` |
| STEAM         | Location of steamcmd client.                                                             |`/steam`        |
| PLATFORM      | Platform to force specify when auto updating. `linux` or `windows`.                      | `windows`      |
| STEAM_APP_ID  | Steam application ID for auto updating.                                                  | `0`            |
| UPDATE_OS     | Update core OS on startup. `1` enable, `0` disable.                                      | `1`            |
| UPDATE_STEAM  | Update steamcmd on startup. `1` enable, `0` disable.                                     | `1`            |
| UPDATE_SERVER | Update dedicated server specified by `STEAM_APP_ID` on startup. `1` enable, `0` disable. | `1`            |
| PUID          | User ID to run steamcmd under as well as mount permissions.                              | `1000`         |
| PGID          | Group ID to run steamcmd under as well as mount permissions.                             | `1000`         |
| LANG          | Language environment to use in containers.                                               | `en_US.UTF-8`  |
| LANGUAGE      | Language environment to use in containers.                                               | `en_US:UTF-8`  |
| LC_ALL        | Language environment to use in containers.                                               | `en_US.UTF-8`  |

## Ports
Default ports exposed by the container. Additional ports for servers can be
exposed during docker configuration.

See https://support.steampowered.com/kb_article.php?ref=8571-GLVN-8711 for a
detailed list of steam ports.

| Port  | Protocol | Required? | Description             |
|-------|----------|-----------|-------------------------|
|`27015`| TCP      | Optional  | SRCDS RCON port.        |
|`27015`| UDP      | Mandatory | Gameplay traffic.       |
|`27016`| UDP      | Mandatory | Steam announce traffic. |

## Volumes

| Volume  | Function                                   |
|---------|--------------------------------------------|
| /data   | User data location for images.             |

## Custom Server
`/data/custom_server` is the script that will be called when the docker
container is launched. This is under your control to allow you to setup the
server however you wish. You **must create this script**.

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

Documentation can be found within the container itself using:

```
docker run -it --rm -a stdout --entrypoint cat rpufky/steam:latest /docker/server_example.md
```

### Linux Example
This will launch a linux dedicated server, assuming that the linux server is
launched via a `startserver.sh` script in the install directory.

```
su steam -c "/data/server/startserver.sh -configfile=/data/server/serverconfig.xml"
```
* this example would launch a 7 days to die dedicated server (294420).

### Windows Example
All flavors of wine are installed (wind, wine32 and wine64). Check specific
dedicated server documentation and forums for launching a dedicated windows
server under wine for your game.

```
su steam -c "xvfb-run --auto-servernum \
  wine64 ${SERVER_DIR}/ConanSandboxServer.exe -log -nosteam"
```
* This example lauches a conan exiles dedicated server (443030).

> It is important to note that we must bring up a lightweight window manager
> to launch these servers. This is what `xvfb-run --auto-servernum` does.

## 0755 steam:steam `/data/custom_server`
``` bash
#!/bin/bash
#
# Example server script. Do NOT run.
# This runs as ROOT by default. Drop privileges.
#
# Do any additional server setup here. Perms are pre-setup for steam:steam
# unless you explicitly change anything. Docker environment variables are
# available.


# Launch the dedicated windows server under the steam user.
# This will run wine (for windows servers) and launch the server.
su steam -c  "xvfb-run \
  --auto-servernum \
  wine64 ${SERVER_DIR}/ConanSandboxServer.exe -log -nosteam"

# Launch the dedicated linux server under the steam user.
su steam -c "/data/server/startserver.sh \
  -configfile=/data/server/serverconfig.xml"
```
