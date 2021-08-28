from rest_framework import serializers

from core.models import DailyNewsLetter


class DailyNewsLetterListSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyNewsLetter
        fields = '__all__'
        depth=1


class DailyNewsLetterCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyNewsLetter
        exclude = ['city', 'date']

    def create(self, validated_data):
        print(validated_data)
        user = self.context['request'].user
        validated_data.update({
            'city': user.userProfile.city
        })
        print(validated_data)
        return DailyNewsLetter.objects.create(**validated_data)
