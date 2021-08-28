from rest_framework import serializers

from api.modulos.professional.serializers import ProfessionalListSerializer
from core.models import LatLng, HealthCenter, Professional


class HealthCenterListSerializer(serializers.ModelSerializer):
    listProfessional = ProfessionalListSerializer(many=True)

    class Meta:
        model = HealthCenter
        fields = '__all__'
        depth = 1


class HealthCenterListCustomSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthCenter
        fields = ['id', 'name', 'neighborhood']


class HealthCenterSerializer(serializers.ModelSerializer):
    lat = serializers.CharField(source='latLng.lat')
    lng = serializers.CharField(source='latLng.lng')

    class Meta:
        model = HealthCenter
        exclude = ['latLng']

    def create(self, validated_data):
        print(validated_data)
        latLnt = validated_data.pop('latLng')
        listProfessional = validated_data.pop('listProfessional', None)
        print(validated_data)
        print(listProfessional)
        instancia = HealthCenter.objects.create(**validated_data)
        latLng = LatLng.objects.create(**latLnt)
        if listProfessional:
            for i in listProfessional:
                print(i)

            listProfessional = [prof.id for prof in listProfessional]
            listProfessional = Professional.objects.filter(id__in=listProfessional)
            instancia.listProfessional.add(*listProfessional)
        instancia.latLng = latLng
        instancia.save()
        return instancia
