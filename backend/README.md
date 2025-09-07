
# Django Speed Test (ready-to-run)

This repository contains a minimal Django project that implements a browser speed test similar to fast.com / speedtest.net.
Features:
- Streaming download endpoint for throughput testing
- Upload endpoint to accept posted data
- WebSocket (Django Channels) ping/pong for low-latency measurement
- Client with real-time throughput graph using Chart.js
- Example `nginx.conf` for efficient static/streaming serving

## Quick setup (development)

1. Create virtualenv and activate:
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run migrations:
   ```bash
   python manage.py migrate
   ```

4. Run the development server (ASGI):
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

5. Open `http://localhost:8000/` in a modern browser.

## Notes
- This uses Channels' in-memory layer for dev. For production use `channels_redis`.
- The client uses Chart.js from CDN to show a real-time throughput graph.
- Example `nginx.conf` is included under `deployment/nginx.conf` for use with a production setup.
