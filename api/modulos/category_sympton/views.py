from api.modulos.category_sympton.serializers import *
from api.modulos.basicApiView import *
from core.models import CategorySympton


class CategorySymptonListView(IsAutenticatedListApiView):
    queryset = CategorySympton.objects.all()
    serializer_class = CategorySymptonSerializer


class CategorySymptonCreateView(IsAutenticatedCreateAPIView):
    serializer_class = CategorySymptonSerializer


class CategorySymptonUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = CategorySymptonSerializer
