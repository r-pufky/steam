FROM debian:stretch-slim

ENV SERVER_DIR=/data/server \
    STEAM=/steam \
    PLATFORM=windows \
    STEAM_APP_ID=0 \
    UPDATE_OS=1 \
    UPDATE_STEAM=1 \
    UPDATE_SERVER=1 \
    PUID=1000 \
    PGID=1000 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

COPY docker /docker

RUN export DEBIAN_FRONTEND='noninteractive' && \
    export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true && \
    apt-get --quiet update && \
    # Install base packages. Suppress locale error - always errors before setup.
    apt-get install --yes --no-install-recommends --no-install-suggests 2> /dev/null \
      wget \
      locales \
      ca-certificates \
      gnupg \
      apt-utils && \
    echo "\nLC_ALL=${LC_ALL}\nLANG=${LANG}" >> /etc/environment && \
    sed --in-place --expression='s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    /usr/sbin/locale-gen && \
    # Base system packages.
    apt-get install --yes --no-install-recommends --no-install-suggests \
      lib32stdc++6 \
      lib32gcc1 \
      software-properties-common && \
    # Add wine repository (windows-based dedicated servers only) and install.
    if [ "${PLATFORM}" = 'windows' ]; then \
      dpkg --add-architecture i386 && \
      wget -qO - 'https://dl.winehq.org/wine-builds/winehq.key' | apt-key add - && \
      apt-add-repository 'deb http://dl.winehq.org/wine-builds/debian/ stretch main' && \
      apt-get --quiet update && \
      apt-get install -y --no-install-recommends --no-install-suggests \
        wine \
        wine32 \
        wine64 \
        libwine \
        libwine:i386 \
        fonts-wine \
        wine-stable \
        xauth \
        xvfb \
    ; fi && \
    # Create steam user and install steam cmd.
    useradd --create --home ${STEAM} steam && \
    su steam -c " \
      cd ${STEAM} && \
      wget -qO - 'http://media.steampowered.com/installer/steamcmd_linux.tar.gz' | tar zxvf - && \
		  ${STEAM}/steamcmd.sh +quit" && \
    mkdir -p /data && \
    chown -R steam:steam ${STEAM} /data /docker && \
    chmod 0755 /docker/* && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rfv /var/lib/{apt,dpkg,cache,log}

WORKDIR /data

VOLUME /data

ENTRYPOINT /docker/startup

# For ports required by steam servcies, see:
# https://support.steampowered.com/kb_article.php?ref=8571-GLVN-8711
# Be sure to include any server-specific ports.
EXPOSE 27015/tcp 27015/udp 27016/udp
