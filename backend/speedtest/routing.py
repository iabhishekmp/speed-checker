from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/speedtest/?$', consumers.SpeedtestConsumer.as_asgi()),
]
