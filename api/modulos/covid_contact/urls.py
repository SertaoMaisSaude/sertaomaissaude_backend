from django.urls import path

from api.modulos.covid_contact.views import *

urlpatterns = [
    path("list/", CovidContactListTrue.as_view(), name="types_professional_list"),
    path("create/", CovidContactCreate.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", CovidContactUpdate.as_view(), name="types_professional_update"),
]
