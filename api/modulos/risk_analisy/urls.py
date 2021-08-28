from django.urls import path

from api.modulos.risk_analisy.views import *
urlpatterns = [
    path("list/", RiskAnalisyListView.as_view(), name="types_professional_list"),
    path("create/", RiskAnalisyCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", RiskAnalisyCreateView.as_view(), name="types_professional_update"),
]
