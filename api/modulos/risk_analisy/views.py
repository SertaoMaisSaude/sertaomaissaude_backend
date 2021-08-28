from api.modulos.basicApiView import *
from api.modulos.risk_analisy.serializers import *
from core.models import  RiskAnalisy


class RiskAnalisyListView(IsAutenticatedListApiView):
    queryset = RiskAnalisy.objects.all()
    serializer_class = RiskAnalisyListSerializer


class RiskAnalisyCreateView(IsAutenticatedCreateAPIView):
    serializer_class = RiskAnalisyCreateSerializer


class RiskAnalisyUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = RiskAnalisyCreateSerializer
