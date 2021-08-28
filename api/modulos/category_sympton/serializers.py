from rest_framework import serializers

from core.models import CategorySympton


class CategorySymptonSerializer(serializers.ModelSerializer):
    class Meta:
        model = CategorySympton
        fields = '__all__'
