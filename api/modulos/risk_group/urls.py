from django.urls import path

from api.modulos.risk_group.views import *

urlpatterns = [
    path("list/", RiskGroupList.as_view(), name="types_professional_list"),
    path("create/", RiskGroupCreate.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", RiskGroupUpdate.as_view(), name="types_professional_update"),
]
