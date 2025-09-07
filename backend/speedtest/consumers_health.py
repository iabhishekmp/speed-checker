from channels.generic.websocket import AsyncWebsocketConsumer
import json
class HealthConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        await self.send_json({'status':'ok'})
        await self.close()
    async def send_json(self, data):
        await super().send(text_data=json.dumps(data))
