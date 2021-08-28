from rest_framework import serializers
from core.models import RiskAnalisy


class RiskAnalisyListSerializer(serializers.ModelSerializer):
    class Meta:
        model = RiskAnalisy
        fields = '__all__'
        depth = 1


class RiskAnalisyCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = RiskAnalisy
        fields = '__all__'


