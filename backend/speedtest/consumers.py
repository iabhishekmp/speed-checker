import asyncio
import json
import time
from channels.generic.websocket import AsyncWebsocketConsumer

class SpeedtestConsumer(AsyncWebsocketConsumer):
    """
    WebSocket Speedtest:
    - Client connects to /ws/speedtest/
    - Client can send JSON: {"action":"start", "download_bytes":int, "upload_bytes":int, "ping_count":int, "chunk_size":int}
    - If client sends nothing, server will run default test.
    - Server sends final JSON: {"ping":..,"download":..,"upload":..,"latency":..}
    """

    async def connect(self):
        await self.accept()
        self.test_started = False
        self._upload_bytes_needed = 0
        self._upload_bytes_received = 0
        self._upload_start_ts = None
        self._upload_end_ts = None
        self._waiting_for_upload = False
        # Run default test if client sends nothing
        asyncio.create_task(self._run_default_test())

    async def send_json(self, content):
        """Wrapper to send JSON"""
        await self.send(text_data=json.dumps(content))

    async def _run_default_test(self):
        await asyncio.sleep(1)  # wait 1 second
        if not self.test_started:
            self.test_started = True
            await self._run_test()

    async def receive(self, text_data=None, bytes_data=None):
        if self.test_started:
            # ignore messages after test started
            return

        self.test_started = True

        if text_data:
            try:
                msg = json.loads(text_data)
            except Exception:
                msg = {}
            download_bytes = int(msg.get("download_bytes", 5*1024*1024))
            upload_bytes = int(msg.get("upload_bytes", 5*1024*1024))
            ping_count = int(msg.get("ping_count", 5))
            chunk_size = int(msg.get("chunk_size", 64*1024))
        else:
            download_bytes = 5*1024*1024
            upload_bytes = 5*1024*1024
            ping_count = 5
            chunk_size = 64*1024

        asyncio.create_task(
            self._run_test(download_bytes, upload_bytes, ping_count, chunk_size)
        )

    async def _run_test(self, download_bytes=5*1024*1024, upload_bytes=5*1024*1024,
                        ping_count=5, chunk_size=64*1024):
        # 1️⃣ Ping test (simulated if no client response)
        ping_values = []
        for i in range(ping_count):
            start = time.perf_counter()
            await self.send_json({"type":"ping","seq":i})
            # Wait for pong from client
            try:
                pong = await asyncio.wait_for(self._wait_for_pong(i), timeout=5)
                rtt = (time.perf_counter() - start) * 1000.0
                ping_values.append(rtt)
            except asyncio.TimeoutError:
                # skip this ping
                continue
            await asyncio.sleep(0.05)
        ping_ms = sorted(ping_values)[len(ping_values)//2] if ping_values else None

        # 2️⃣ Download test
        await self.send_json({"action":"download_start","bytes":download_bytes})
        sent = 0
        start_dl = time.perf_counter()
        chunk = b'\x00' * chunk_size
        while sent < download_bytes:
            to_send = min(chunk_size, download_bytes - sent)
            await self.send(bytes_data=chunk[:to_send])
            sent += to_send
            await asyncio.sleep(0)
        end_dl = time.perf_counter()
        download_mbps = (download_bytes*8)/((end_dl - start_dl)*1_000_000) if (end_dl - start_dl)>0 else 0.0

        # 3️⃣ Upload test
        await self.send_json({"action":"upload_start","bytes":upload_bytes})
        self._upload_bytes_needed = upload_bytes
        self._upload_bytes_received = 0
        self._upload_start_ts = None
        self._upload_end_ts = None
        self._waiting_for_upload = True

        upload_timeout = max(10.0, upload_bytes / (1024*1024) * 5.0)
        t0 = time.perf_counter()
        while self._waiting_for_upload and (time.perf_counter()-t0)<upload_timeout:
            await asyncio.sleep(0.05)

        if self._upload_start_ts and self._upload_end_ts and (self._upload_end_ts - self._upload_start_ts)>0:
            upload_mbps = (self._upload_bytes_received*8)/((self._upload_end_ts - self._upload_start_ts)*1_000_000)
        else:
            upload_mbps = 0.0

        # 4️⃣ Send final result
        result = {
            "ping": round(ping_ms,2) if ping_ms else None,
            "download": round(download_mbps,2),
            "upload": round(upload_mbps,2),
            "latency": round(ping_ms,2) if ping_ms else None,
        }
        await self.send_json({"action":"result","data":result})
        await asyncio.sleep(0.1)
        await self.close()

    async def _wait_for_pong(self, seq):
        while True:
            msg = await self._receive_json()
            if msg.get("type")=="pong" and msg.get("seq")==seq:
                return msg

    async def _receive_json(self):
        fut = asyncio.get_event_loop().create_future()
        self._pending_json_future = fut
        try:
            return await fut
        finally:
            self._pending_json_future = None

    async def receive_bytes(self, bytes_data):
        """Handle client upload"""
        if not getattr(self, "_waiting_for_upload", False):
            return
        if self._upload_start_ts is None:
            self._upload_start_ts = time.perf_counter()
        self._upload_bytes_received += len(bytes_data)
        if self._upload_bytes_received >= self._upload_bytes_needed:
            self._upload_end_ts = time.perf_counter()
            self._waiting_for_upload = False
