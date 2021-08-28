from rest_framework import serializers
from core.models import  HealthTips


class HealthTipsListSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthTips
        fields = '__all__'
        depth = 1


class HealthTipsCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthTips
        fields = '__all__'


