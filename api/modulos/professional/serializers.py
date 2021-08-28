from django.contrib.auth.models import User
from rest_framework import serializers

from core.models import Professional



class ProfessionalListSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username')
    class Meta:
        model = Professional
        exclude=['user']
        depth = 1



class ProfessionalCreateSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username')
    password = serializers.CharField(source='user.password')

    class Meta:
        model = Professional
        exclude=['user']

    def create(self, validated_data):
        print(validated_data)
        user = validated_data.pop('user')
        typeProfessional = validated_data['typeProfessional']
        name = validated_data['name']
        print(validated_data)
        print(user)

        if User.objects.filter(username=user['username']).exists():
            raise serializers.ValidationError('Login já existe')

        user = User.objects.create(username=user['username'], password=user['password'])
        professional = Professional.objects.create(user=user,
                                                   typeProfessional=typeProfessional,
                                                   name=name)
        return professional
