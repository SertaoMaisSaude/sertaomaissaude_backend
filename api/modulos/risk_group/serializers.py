from rest_framework import serializers

from core.models import RiskGroup


class RiskGroupSerializer(serializers.ModelSerializer):

    class Meta:
        model = RiskGroup
        fields = '__all__'
