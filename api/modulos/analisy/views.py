from api.modulos.analisy.serializers import *
from api.modulos.basicApiView import *
from core.models import Analisy


class AnalisyListView(IsAutenticatedListApiView):
    queryset = Analisy.objects.all()
    serializer_class = AnalisyListSerializer


class AnalisyCreateView(IsAutenticatedCreateAPIView):
    serializer_class = AnalisyCreateSerializer


class AnalisyUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = AnalisyCreateSerializer
