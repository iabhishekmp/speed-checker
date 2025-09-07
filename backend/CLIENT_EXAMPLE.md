# Python WebSocket client example (shows how to talk to the server)

This example uses `websockets` to perform the protocol. It:
- connects
- sends {"action":"start",...}
- responds to server 'ping' messages with {"type":"pong","seq":...}
- receives binary download frames and counts them
- upon 'upload_start' message, sends binary frames totalling upload_bytes
- receives final result JSON

Install:
    pip install websockets

Example:
```python
import asyncio, json, time, websockets

async def run():
    uri = "ws://localhost:8000/ws/speedtest/"
    async with websockets.connect(uri) as ws:
        # start test
        start_msg = {"action":"start","download_bytes":5000000,"upload_bytes":5000000,"ping_count":5,"chunk_size":65530}
        await ws.send(json.dumps(start_msg))

        download_bytes_recv = 0
        expected_upload_bytes = 0

        while True:
            msg = await ws.recv()
            if isinstance(msg, bytes):
                # download binary frame
                download_bytes_recv += len(msg)
                continue
            # text message
            data = json.loads(msg)
            if data.get('type') == 'ping':
                seq = data.get('seq')
                # reply immediately with pong
                await ws.send(json.dumps({"type":"pong","seq":seq}))
                continue
            action = data.get('action')
            if action == 'download_start':
                print("Download starting, server will send bytes:", data.get('bytes'))
                continue
            if action == 'upload_start':
                expected_upload_bytes = data.get('bytes')
                print("Server asked for upload of bytes:", expected_upload_bytes)
                # send upload binary frames
                sent = 0
                chunk = b'\x11' * data.get('chunk_size', 65530) if data.get('chunk_size') else b'\x11'*65530
                while sent < expected_upload_bytes:
                    tosend = chunk[:min(len(chunk), expected_upload_bytes - sent)]
                    await ws.send(tosend)
                    sent += len(tosend)
                print("Upload done, sent:", sent)
                continue
            if action == 'result':
                print("Final result:", data.get('data'))
                break

asyncio.run(run())
```

Adjust chunk_size to match server settings if needed.
