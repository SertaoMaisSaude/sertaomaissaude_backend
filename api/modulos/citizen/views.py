from api.modulos.citizen.serializers import *
from api.modulos.basicApiView import *
from core.models import HealthCenter


class CitizenListView(IsAutenticatedListApiView):
    queryset = Citizen.objects.all()
    serializer_class = CitizenListSerializer


class CitizenCreateView(IsAutenticatedCreateAPIView):
    serializer_class = CitizenCreateSerializer


class CitizenUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = CitizenCreateSerializer
