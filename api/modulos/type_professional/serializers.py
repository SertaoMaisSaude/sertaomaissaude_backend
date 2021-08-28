from rest_framework import serializers

from core.models import TypeProfessional


class TypeProfessionalListSerializer(serializers.ModelSerializer):
    class Meta:
        model = TypeProfessional
        fields = '__all__'
        depth = 1



class TypeProfessionalCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = TypeProfessional
        fields = '__all__'

