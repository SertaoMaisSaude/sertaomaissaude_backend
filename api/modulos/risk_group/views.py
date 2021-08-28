#
from api.modulos.risk_group.serializers import RiskGroupSerializer
from core.models import RiskGroup
from api.modulos.basicApiView import IsAutenticatedListApiView, IsAutenticatedCreateAPIView, IsAutenticatedUpdateAPIView


class RiskGroupList(IsAutenticatedListApiView):
    queryset = RiskGroup.objects.all()
    serializer_class = RiskGroupSerializer


class RiskGroupCreate(IsAutenticatedCreateAPIView):
    serializer_class = RiskGroupSerializer


class RiskGroupUpdate(IsAutenticatedUpdateAPIView):
    serializer_class = RiskGroupSerializer
