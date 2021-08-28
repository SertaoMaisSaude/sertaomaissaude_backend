import datetime

from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response

from api.modulos.analisy.serializers import AnalisyListSerializer
from core.models import Analisy, Citizen, CovidContact, Sympton, RiskGroup, City, CategorySympton, LatLng

from core.util import date_util


class IsAutenticatedApiView(APIView):
    permission_classes = (IsAuthenticated,)


from django.core import serializers


# , , , , , , , latLng

class MapeamentoBI(IsAutenticatedApiView):

    def get(self, request, *args, **kwargs):
        print('vamos lá')
        print(args)
        data = kwargs.get("data", None)
        data = data.replace("-", "/")
        print(request.user)
        print(data)
        data = date_util.getDateToStringFormat(data, date_util.FORMAT_DATA)

        analises = Analisy.objects.filter(
            date__day=data.day,
            date__month=data.month,
            date__year=data.year
        )

        citizens = Citizen.objects.filter(analyses__in=analises).distinct()
        symptons = Sympton.objects.filter(analyses__in=analises).distinct()
        covid_contacts = CovidContact.objects.filter(analyses__in=analises).distinct()
        risk_groups = RiskGroup.objects.filter(citizens__in=citizens).distinct()
        citys = City.objects.filter(citizens__in=citizens).distinct()
        categorys_symptons = CategorySympton.objects.filter(symptoms__in=symptons).distinct()

        latLngs_citys = LatLng.objects.filter(cities__in=citys).distinct()
        latLngs_analisys = LatLng.objects.filter(analyses__in=analises).distinct()

        print('citizens',citizens.values('neighborhood'))

        print([p['neighborhood'] for p in citizens.values('neighborhood').distinct()])

        lista = {
            'citys': [dado.getJson() for dado in citys],
            'covid_contacts': [dado.getJson() for dado in covid_contacts],
            'citizens': [dado.getJson() for dado in citizens],
            'symptons': [dado.getJson() for dado in symptons],
            'categorys_symptons': [dado.getJson() for dado in categorys_symptons],
            'risk_groups': [dado.getJson() for dado in risk_groups],
            'analisys': [dado.getJson() for dado in analises],
            'latLngs_citys':[dado.getJson() for dado in latLngs_citys],
            'latLngs_analisys':[dado.getJson() for dado in latLngs_analisys],
            'neighborhood':[p['neighborhood'] for p in citizens.values('neighborhood').distinct()],

        }

        return Response(lista)
