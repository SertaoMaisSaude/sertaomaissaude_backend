from rest_framework import serializers
from core.models import Citizen, RiskGroup


class CitizenListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Citizen
        fields = '__all__'
        depth = 1


class CitizenCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Citizen
        exclude = ['userProfile', 'city']

    def create(self, validated_data):
        print(validated_data)
        listRiskGroup = validated_data.pop('listRiskGroup', None)
        user = self.context['request'].user
        validated_data.update({
            'city': user.userProfile.city
        })
        print(validated_data)
        print(listRiskGroup)
        instancia = Citizen.objects.create(**validated_data)
        if listRiskGroup:
            for i in listRiskGroup:
                print(i)

            listRiskGroup = [prof.id for prof in listRiskGroup]
            listRiskGroup = RiskGroup.objects.filter(id__in=listRiskGroup)
            instancia.listRiskGroup.add(*listRiskGroup)

        instancia.save()
        return instancia
