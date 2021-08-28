
from api.modulos.professional.serializers import *
from api.modulos.basicApiView import *
from core.models import Professional

class ProfessionalListView(IsAutenticatedListApiView):
    queryset = Professional.objects.all()
    serializer_class = ProfessionalListSerializer


    def get_queryset(self):
        query = super().get_queryset().filter(active=True)
        return query


class ProfessionalCreateView(IsAutenticatedCreateAPIView):
    queryset = Professional.objects.all()
    serializer_class = ProfessionalCreateSerializer


class ProfessionalUpdateView(IsAutenticatedUpdateAPIView):
    queryset = Professional.objects.all()
    serializer_class = ProfessionalCreateSerializer
