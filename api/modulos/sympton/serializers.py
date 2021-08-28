from rest_framework import serializers

from core.models import Sympton


class SymptonListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sympton
        fields = '__all__'
        depth = 1



class SymptonCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sympton
        fields = '__all__'
