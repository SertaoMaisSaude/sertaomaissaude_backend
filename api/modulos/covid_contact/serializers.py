from rest_framework import serializers

from core.models import CovidContact


class CovidContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = CovidContact
        fields = '__all__'

