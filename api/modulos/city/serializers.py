from rest_framework import serializers

from core.models import City, LatLng


class CityListSerializer(serializers.ModelSerializer):
    class Meta:
        model = City
        fields = '__all__'
        depth = 1


class CityCreateSerializer(serializers.ModelSerializer):
    lat = serializers.CharField(source='latLng.lat')
    lng = serializers.CharField(source='latLng.lng')

    class Meta:
        model = City
        # fields = '__all__'
        fields = ['lat', 'lng', 'name']

    def create(self, validated_data):
        latLnt = validated_data.pop('latLng')
        instancia = City.objects.create(**validated_data)
        latLng = LatLng.objects.create(**latLnt)
        instancia.latLng = latLng
        instancia.save()
        return instancia
