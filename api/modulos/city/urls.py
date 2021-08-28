from django.urls import path

from api.modulos.city.views import *

urlpatterns = [
    path("list/", CityListTrue.as_view(), name="types_professional_list"),
    path("create/", CityCreate.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", CityUpdate.as_view(), name="types_professional_update"),
]
