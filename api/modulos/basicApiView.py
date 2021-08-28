from rest_framework.generics import ListAPIView, CreateAPIView, UpdateAPIView
from rest_framework.permissions import IsAuthenticated


class IsAutenticatedListApiView(ListAPIView):
    permission_classes = (IsAuthenticated,)




class IsAutenticatedCreateAPIView(CreateAPIView):
    permission_classes = (IsAuthenticated,)


class IsAutenticatedUpdateAPIView(UpdateAPIView):
    permission_classes = (IsAuthenticated,)
