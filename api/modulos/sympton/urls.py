from django.urls import path

from api.modulos.sympton.views import *

urlpatterns = [
    path("list/", SymptonListView.as_view(), name="types_professional_list"),
    path("create/", SymptonCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", SymptonUpdateView.as_view(), name="types_professional_update"),
]
