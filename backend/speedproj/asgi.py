
import os
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
import django
from channels.auth import AuthMiddlewareStack
from speedtest import routing as speed_routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'speedproj.settings')
django.setup()

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(
            speed_routing.websocket_urlpatterns
        )
    ),
})
