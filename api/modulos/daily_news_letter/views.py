from api.modulos.daily_news_letter.serializers import *
from api.modulos.basicApiView import *
from core.models import DailyNewsLetter


class DailyNewsLetterListTrue(IsAutenticatedListApiView):
    queryset = DailyNewsLetter.objects.all()
    serializer_class = DailyNewsLetterListSerializer

    def get_queryset(self):
        query = super().get_queryset().filter(active=True)
        return query


class DailyNewsLetterCreate(IsAutenticatedCreateAPIView):
    serializer_class = DailyNewsLetterCreateSerializer


class DailyNewsLetterUpdate(IsAutenticatedUpdateAPIView):
    serializer_class = DailyNewsLetterCreateSerializer
