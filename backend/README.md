
# Django WebSocket Speedtest (Production-ready)

This project exposes a WebSocket-only API that runs a speed test and returns a JSON result:
{
  "ping": <ms>,
  "download": <mbps>,
  "upload": <mbps>,
  "latency": <ms>
}

Flow:
1. Client connects to ws://HOST/ws/speedtest/
2. Client sends a JSON start message:
   {
     "action": "start",
     "download_bytes": 5000000,
     "upload_bytes": 5000000,
     "ping_count": 5,
     "chunk_size": 65530
   }
3. Server does:
   - ping sequence (server measures RTT for ping_count pings)
   - download: sends binary frames totalling download_bytes (server times sending)
   - waits for client to ACK download (optional)
   - waits for client to upload binary frames totalling upload_bytes (server measures receive time)
4. Server sends final JSON result and closes.

Dockerized with:
- daphne ASGI server
- redis for channel layer
- nginx configured as reverse proxy (for production)

See docker-compose.yml and deployment/nginx.conf.

IMPORTANT: Client must implement the WebSocket protocol to respond to 'ping' with 'pong' and must send upload binary frames when requested.

