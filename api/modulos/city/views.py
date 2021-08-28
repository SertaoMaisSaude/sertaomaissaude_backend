#
from api.modulos.city.serializers import *
from core.models import City
from api.modulos.basicApiView import IsAutenticatedListApiView, IsAutenticatedCreateAPIView, IsAutenticatedUpdateAPIView


class CityListTrue(IsAutenticatedListApiView):
    queryset = City.objects.all()
    serializer_class = CityListSerializer

    def get_queryset(self):
        query = super().get_queryset().filter(active=True)
        return query


class CityCreate(IsAutenticatedCreateAPIView):
    serializer_class = CityCreateSerializer


class CityUpdate(IsAutenticatedUpdateAPIView):
    serializer_class = CityCreateSerializer
