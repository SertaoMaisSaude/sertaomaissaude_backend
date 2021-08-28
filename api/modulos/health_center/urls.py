from django.urls import path

from api.modulos.health_center.views import *

urlpatterns = [

    path("list/", HealthCenterList.as_view(), name="types_professional_list"),
    path("create/", HealthCenterCreate.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", HealthCenterUpdate.as_view(), name="types_professional_update"),


    path("list/<str:neighborhood>", HealthCenterList.as_view(), name="health_center_list_by_neighborhood"),
    path("list_city_id/<int:city_id>", HealthCenterList.as_view(), name="health_center_list_by_city_id"),
]
