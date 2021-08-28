from django.urls import path

from api.modulos.citizen.views import *

urlpatterns = [
    path("list/", CitizenListView.as_view(), name="types_professional_list"),
    path("create/", CitizenCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", CitizenCreateView.as_view(), name="types_professional_update"),
]
