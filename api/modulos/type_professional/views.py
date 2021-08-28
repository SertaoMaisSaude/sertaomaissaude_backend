from api.modulos.type_professional.serializers import *
from core.models import TypeProfessional
from api.modulos.basicApiView import *


class TypeProfessionalList(IsAutenticatedListApiView):
    queryset = TypeProfessional.objects.all()
    serializer_class = TypeProfessionalListSerializer


class TypeProfessionalCreate(IsAutenticatedCreateAPIView):
    queryset = TypeProfessional.objects.all()
    serializer_class = TypeProfessionalCreateSerializer


class TypeProfessionalUpdate(IsAutenticatedUpdateAPIView):
    queryset = TypeProfessional.objects.all()
    serializer_class = TypeProfessionalCreateSerializer
#

#
#
#
#
#
# class PollDetail(RetrieveDestroyAPIView):
#     queryset = Poll.objects.all()
#     serializer_class = PollSerializer
#
#
# class ChoiceList(ListCreateAPIView):
#     queryset = Choice.objects.all()
#     serializer_class = ChoiceSerializer
#
#
# class CreateVote(CreateAPIView):
#     serializer_class = VoteSerializer
