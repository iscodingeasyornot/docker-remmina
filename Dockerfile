# Use a base image with Ubuntu
FROM jlesage/baseimage-gui:ubuntu-22.04-v4.5.3

# Update package lists and install required dependencies
RUN apt-get update && \
    apt-get install -y sudo build-essential git-core cmake libssl-dev libx11-dev libxext-dev \
    libxinerama-dev libxcursor-dev libxdamage-dev libxv-dev libxkbfile-dev libasound2-dev \
    libcups2-dev libxml2 libxml2-dev libxrandr-dev libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev libxi-dev libavutil-dev \
    libavcodec-dev libxtst-dev libgtk-3-dev libgcrypt20-dev libssh-dev libpulse-dev \
    libvte-2.91-dev libxkbfile-dev libtelepathy-glib-dev libjpeg-dev \
    libgnutls28-dev libavahi-ui-gtk3-dev libvncserver-dev \
    libayatana-appindicator3-dev intltool libsecret-1-dev libwebkit2gtk-4.0-dev \
    libsystemd-dev libsoup2.4-dev libjson-glib-dev libswresample-dev libsodium-dev \
    libusb-1.0-0-dev libpcre2-dev libicu-dev libpython3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Remove freerdp-x11 package and all packages containing the string remmina in the package name
RUN apt-get purge -y $(apt list --installed 2>/dev/null | grep -E "^remmina|^libfreerdp|^freerdp|^libwinpr" | awk -F/ '{print $1}')

# Create directories and clone repositories
RUN mkdir ~/remmina_devel && \
    cd ~/remmina_devel && \
    git clone --branch stable-2.0 https://github.com/FreeRDP/FreeRDP.git && \
    cd FreeRDP && \
    cmake -DCMAKE_BUILD_TYPE=Debug -DWITH_SSE2=ON -DWITH_CUPS=on -DWITH_ICU=on -DWITH_PULSE=on -DCMAKE_INSTALL_PREFIX:PATH=/opt/remmina_devel/freerdp . && \
    make && \
    sudo make install && \
    echo /opt/remmina_devel/freerdp/lib | sudo tee /etc/ld.so.conf.d/freerdp_devel.conf > /dev/null && \
    sudo ldconfig && \
    sudo ln -s /opt/remmina_devel/freerdp/bin/xfreerdp /usr/local/bin/

RUN cd ~/remmina_devel && \
    git clone https://gitlab.com/Remmina/Remmina.git && \
    cd Remmina && \
    cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX:PATH=/opt/remmina_devel/remmina -DCMAKE_PREFIX_PATH=/opt/remmina_devel/freerdp . && \
    make && \
    sudo make install && \
    sudo ln -s /opt/remmina_devel/remmina/bin/remmina /usr/local/bin/

# Change screenshot dir (WIP)
#RUN mkdir -p /config/screenshot && \
#    sed -i 's|^screenshot_path=/root|screenshot_path=/config/screenshot|' /config/xdg/config/remmina/remmina.pref
RUN mkdir -p /config/screenshot
COPY remmina.pref /config/xdg/config/remmina/remmina.pref
# Copy the start script.
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh
# Set the name of the application.
RUN set-cont-env APP_NAME "Remmina"
