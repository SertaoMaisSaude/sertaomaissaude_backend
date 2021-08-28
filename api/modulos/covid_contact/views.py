from api.modulos.covid_contact.serializers import *
from api.modulos.basicApiView import *
from core.models import CovidContact


class CovidContactListTrue(IsAutenticatedListApiView):
    queryset = CovidContact.objects.all()
    serializer_class = CovidContactSerializer

    def get_queryset(self):
        query = super().get_queryset().filter(active=True)
        return query


class CovidContactCreate(IsAutenticatedCreateAPIView):
    serializer_class = CovidContactSerializer


class CovidContactUpdate(IsAutenticatedUpdateAPIView):
    serializer_class = CovidContactSerializer
