# steam
Generic Steam dedicated server using Docker.

This provides a core installation of `steamcmd` to host dedicated servers. Both
linux and windows servers can be hosted using this image.

## How it Runs
The docker image contains a base ubuntu install with wine (windows support) and
an up to date steamcmd utility installed.

After start, OS, steamcmd and dedicated server are updated based on
configuration; permissions are setup to steam:steam using the specified
PUID/PGID and then execution is passed over to `/data/custom_server` with root
privleges.

`/data/custom_server` is controlled and written by you. This will enable you to
make any explicitly needed updates / changes / etc before launching the server.

* Ensure any files touched have permissions updated.
* Drop to non-root user when launching server `su steam -c ''`.
* Docker environment variables are avaliable to use.
* `wine`, `win32` and `win64` are all avaliable to use.
* A pre-made example script is included in the image. Execute the following to
  display the contents:

  `docker run -it --rm -a stdout --entrypoint cat rpufky/steam:latest
/docker/server_example`

## Version Tags

| Tag    | Description                                |
|--------|--------------------------------------------|
| latest | Latest ubuntu image with wine and steamcmd |

## Parameters

| Parameter     | Function                                                                                 | Default        |
|---------------|------------------------------------------------------------------------------------------|----------------|
| SERVER_DIR    | Location for server files.                                                               | `/data/server` |
| STEAM         | Location of steamcmd client.                                                             |`/steam`        |
| PLATFORM      | Platform to force specify when auto updating. `linux` or `windows`.                      | `windows`      |
| STEAM_APP_ID  | Steam application ID for auto updating.                                                  | `0`            |
| UPDATE_OS     | Update core OS on startup. `1` enable, `0` disable.                                      | `1`            |
| UPDATE_STEAM  | Update steamcmd on startup. `1` enable, `0` disable.                                     | `0`            |
| UPDATE_SERVER | Update dedicated server specified by `STEAM_APP_ID` on startup. `1` enable, `0` disable. | `1`            |
| PUID          | User ID to run steamcmd under as well as mount permissions.                              | `1000`         |
| PGID          | Group ID to run steamcmd under as well as mount permissions.                             | `1000`         |
| LANG          | Language environment to use in containers.                                               | `en_US.UTF-8`  |
| LANGUAGE      | Language environment to use in containers.                                               | `en_US:en`     |
| LC_ALL        | Language environment to use in containers.                                               | `en_US.UTF-8`  |

## Ports
Default ports exposed by the container. Additional ports for servers can be
exposed during docker configuration.

See https://support.steampowered.com/kb_article.php?ref=8571-GLVN-8711 for a
detailed list of steam ports.

| Port  | Protocol | Required? | Description             |
|-------|----------|-------------------------------------|
|`27015`| TCP      | Optional  | SRCDS RCON port.        |
|`27015`| UDP      | Mandatory | Gameplay traffic.       |
|`27016`| UDP      | Mandatory | Steam announce traffic. |

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

### docker-compose (windows dedicated server)
```
---
version: "3"
services:
  steam:
    image: rpufky/steam:latest
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
    image: rpufky/steam:latest
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

## Building
Both debian-slim and ubuntu images build within about 2-3MB of each other, so
only the ubuntu base is used. build using included makefile:

```
sudo make steam
```

## Failed to determine free disk space for ... error 75
This happens when steamcmd is downloading an app because the underlying data
store cannot be queried for a quota. Common with ZFS backed data stores.
Either set an explicit qouta or ignore it.

`sudo zfs set quota=2T zpool1/docker`
