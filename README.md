# VRCX-0 noVNC Container

Run the VRCX-0 Linux AppImage in a Docker container and access it through a browser with noVNC.

The container starts a headless Cage Wayland kiosk session, exposes it through WayVNC, and serves noVNC with websockify on localhost. VRCX-0 state is persisted into bind-mounted directories under `data/`.

## Requirements

- Docker Compose

## Quick Start

1. Create an environment file:

   ```sh
   cp .env.example .env
   ```

2. Edit `.env` and set noVNC credentials:

   ```env
   VNC_USERNAME=vnc
   VNC_PASSWORD=changeit
   NOVNC_PORT=6080
   ```

   `VNC_USERNAME` defaults to `vnc` if omitted.

3. Build and start the container:

   ```sh
   docker compose up --build -d
   ```

4. Open noVNC:

   ```text
   http://127.0.0.1:6080/vnc.html
   ```

   If you changed `NOVNC_PORT`, use that port instead.
