from rest_framework import serializers
from core.models import Analisy, LatLng, Sympton, Disease


class DiseaseListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disease
        fields = '__all__'
        depth = 1


class DiseaseCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disease
        fields = '__all__'



    def create(self, validated_data):
        print(validated_data)
        listSympton = validated_data.pop('listSympton', None)
        instancia = Disease.objects.create(**validated_data)
        if listSympton:
            listSympton = [prof.id for prof in listSympton]
            listSympton = Sympton.objects.filter(id__in=listSympton)
            instancia.listSympton.add(*listSympton)
        instancia.save()
        return instancia
