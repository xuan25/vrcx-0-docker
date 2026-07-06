FROM ubuntu:rolling AS cage-builder

ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu's packaged Cage/wlroots trips a wlroots XWayland assertion with
# the VRCX-0 AppImage. Build the same source with release assertions disabled.
RUN set -eux; \
    sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        dpkg-dev \
        meson \
        ninja-build \
        pkgconf; \
    apt-get build-dep -y wlroots cage; \
    mkdir -p /build; \
    cd /build; \
    apt-get source wlroots cage; \
    cd /build/wlroots-*; \
    meson setup build --buildtype=release -Db_ndebug=true -Dwerror=false --prefix=/usr/local; \
    meson compile -C build; \
    meson install -C build; \
    cd /build/cage-*; \
    PKG_CONFIG_PATH="/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig" \
        meson setup build --buildtype=release -Db_ndebug=true --prefix=/usr/local --wrap-mode=nodownload; \
    meson compile -C build; \
    meson install -C build; \
    strip /usr/local/bin/cage || true; \
    rm -rf /build /var/lib/apt/lists/*

FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:/usr/local/lib

RUN apt-get update && apt-get install -y \
    libwlroots-0.19 \
    wayvnc \
    novnc \
    websockify \
    xwayland \
    dbus-x11 \
    procps \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=cage-builder /usr/local /usr/local

RUN ldconfig && cage -v

# UID 1000 is already occupied in your Ubuntu base image.
# Use a fixed UID/GID so bind-mounted directories can be owned correctly.
RUN groupadd --gid 10001 vncuser && \
    useradd --uid 10001 --gid 10001 --create-home vncuser

# configuration and desktop startup.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY fix-permissions.sh /usr/local/bin/fix-permissions.sh
COPY app-session.sh /opt/vnc/app-session.sh
COPY run-wayvnc.sh /usr/local/bin/run-wayvnc.sh

RUN chmod 755 \
/opt/vnc/app-session.sh \
/usr/local/bin/run-wayvnc.sh \
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

CMD ["/usr/local/bin/run-wayvnc.sh"]
