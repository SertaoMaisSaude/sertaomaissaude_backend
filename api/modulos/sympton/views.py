from api.modulos.category_sympton.serializers import *
from api.modulos.basicApiView import *
from api.modulos.sympton.serializers import *
from core.models import Sympton


class SymptonListView(IsAutenticatedListApiView):
    queryset = Sympton.objects.all()
    serializer_class = SymptonListSerializer


class SymptonCreateView(IsAutenticatedCreateAPIView):
    serializer_class = SymptonCreateSerializer


class SymptonUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = SymptonCreateSerializer
