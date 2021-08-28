from django.urls import path

from api.modulos.health_tips.views import *
urlpatterns = [
    path("list/", HealthTipsListView.as_view(), name="types_professional_list"),
    path("create/", HealthTipsCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", HealthTipsCreateView.as_view(), name="types_professional_update"),
]
