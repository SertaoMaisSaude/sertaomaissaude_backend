from rest_framework import serializers
from core.models import Analisy, LatLng, Sympton, City


class AnalisyListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Analisy
        fields = '__all__'
        depth = 1


class AnalisyCreateSerializer(serializers.ModelSerializer):
    lat = serializers.CharField(source='latLng.lat', required=False)
    lng = serializers.CharField(source='latLng.lng', required=False)
    class Meta:
        model = Analisy
        # fields = '__all__'
        exclude = ['date', 'latLng']



    def create(self, validated_data):
        print(validated_data)
        latLnt = validated_data.pop('latLng', None)

        listSympton = validated_data.pop('listSympton', None)
        print(validated_data)
        print(listSympton)
        if latLnt:
            validated_data.update({
                'latLng': LatLng.objects.create(**latLnt)
            })
        # else:
        #     city = City.objects.filter(id=validated_data['city'])
        #     validated_data.update({
        #         'latLng': city.latLng
        #     })
        instancia = Analisy.objects.create(**validated_data)
        if listSympton:
            listSympton = [prof.id for prof in listSympton]
            listSympton = Sympton.objects.filter(id__in=listSympton)
            instancia.listSympton.add(*listSympton)
        instancia.save()
        return instancia
