from api.modulos.health_center.serializers import HealthCenterSerializer, HealthCenterListSerializer, HealthCenterListCustomSerializer
from core.models import HealthCenter
from api.modulos.basicApiView import IsAutenticatedListApiView, IsAutenticatedCreateAPIView, IsAutenticatedUpdateAPIView


class HealthCenterList(IsAutenticatedListApiView):
    queryset = HealthCenter.objects.all()
    serializer_class = HealthCenterListSerializer

    def get_queryset(self):
        query = super().get_queryset()
        bairro = self.kwargs.get('neighborhood', None)
        city_id = self.kwargs.get('city_id', None)
        if bairro is not None:
            query = query.filter(neighborhood__icontains=bairro)
            self.serializer_class = HealthCenterListCustomSerializer

        if city_id is not None:
            query = query.filter(city_id=int(city_id))
            self.serializer_class = HealthCenterListCustomSerializer



        query = query.filter(active=True)
        return query


class HealthCenterCreate(IsAutenticatedCreateAPIView):
    serializer_class = HealthCenterSerializer


class HealthCenterUpdate(IsAutenticatedUpdateAPIView):
    serializer_class = HealthCenterSerializer
