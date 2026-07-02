# VRCX-0 noVNC Container

Run the VRCX-0 Linux AppImage in a Docker container and access it through a browser with noVNC.

The container starts TigerVNC, launches VRCX-0 in an Openbox session, and exposes noVNC on localhost. VRCX-0 state is persisted into bind-mounted directories under `data/`.

## Requirements

- Docker Compose

## Quick Start

1. Create an environment file:

   ```sh
   cp .env.example .env
   ```

2. Edit `.env` and set a VNC password:

   ```env
   VNC_PASSWORD=changeit
   NOVNC_PORT=6080
   ```

   TigerVNC only uses the first eight characters of the password, so use exactly eight characters.

3. Build and start the container:

   ```sh
   docker compose up --build -d
   ```

4. Open noVNC:

   ```text
   http://127.0.0.1:6080/vnc.html
   ```

   If you changed `NOVNC_PORT`, use that port instead.
