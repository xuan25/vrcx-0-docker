FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    novnc \
    websockify \
    openbox \
    wmctrl \
    x11-utils \
    dbus-x11 \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# UID 1000 is already occupied in your Ubuntu base image.
# Use a fixed UID/GID so bind-mounted directories can be owned correctly.
RUN groupadd --gid 10001 vncuser && \
    useradd --uid 10001 --gid 10001 --create-home vncuser

# configuration and desktop startup.
COPY tigervnc/config.pl /etc/tigervnc/vncserver-config-mandatory
COPY tigervnc/xstartup /opt/vnc/xstartup
COPY openbox-kiosk.xml /opt/vnc/openbox-kiosk.xml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY fix-permissions.sh /usr/local/bin/fix-permissions.sh
COPY app-session.sh /opt/vnc/app-session.sh
COPY run-vnc.sh /usr/local/bin/run-vnc.sh

RUN chmod 755 \
/opt/vnc/xstartup \
/opt/vnc/app-session.sh \
/usr/local/bin/run-vnc.sh \
/usr/local/bin/entrypoint.sh \
/usr/local/bin/fix-permissions.sh

# Install additional dependencies for VRCX-0 AppImage
RUN apt-get update && apt-get install -y \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    libegl1 \
    libgl1 \
    libgbm1 \
    libglx0 \
    libnss3 \
    libasound2t64 \
    && rm -rf /var/lib/apt/lists/*

# Change this URL when upgrading VRCX-0.
ARG APPIMAGE_URL="https://github.com/Map1en/VRCX-0/releases/download/v2.10.0/VRCX-0_2.10.0_linux_x86_64.AppImage"

RUN curl -L --fail "$APPIMAGE_URL" \
      -o /opt/app.AppImage && \
    chmod +x /opt/app.AppImage

USER vncuser
WORKDIR /home/vncuser

EXPOSE 6080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/local/bin/run-vnc.sh"]
