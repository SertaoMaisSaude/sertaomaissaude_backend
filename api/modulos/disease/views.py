from api.modulos.basicApiView import *
from api.modulos.disease.serializers import *
from core.models import Disease


class DiseaseListView(IsAutenticatedListApiView):
    queryset = Disease.objects.all()
    serializer_class = DiseaseListSerializer


class DiseaseCreateView(IsAutenticatedCreateAPIView):
    serializer_class = DiseaseCreateSerializer


class DiseaseUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = DiseaseCreateSerializer
