from django.urls import path

from api.modulos.disease.views import *

urlpatterns = [
    path("list/", DiseaseListView.as_view(), name="types_professional_list"),
    path("create/", DiseaseCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", DiseaseCreateView.as_view(), name="types_professional_update"),
]
