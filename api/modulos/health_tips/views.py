from api.modulos.basicApiView import *
from api.modulos.health_tips.serializers import *
from core.models import HealthTips


class HealthTipsListView(IsAutenticatedListApiView):
    queryset = HealthTips.objects.all()
    serializer_class = HealthTipsListSerializer

    def get_queryset(self):
        query = super().get_queryset().filter(active=True)
        return query

class HealthTipsCreateView(IsAutenticatedCreateAPIView):
    serializer_class = HealthTipsCreateSerializer


class HealthTipsUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = HealthTipsCreateSerializer
