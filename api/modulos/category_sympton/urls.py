from django.urls import path

from api.modulos.category_sympton.views import *

urlpatterns = [
    path("list/", CategorySymptonListView.as_view(), name="types_professional_list"),
    path("create/", CategorySymptonCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", CategorySymptonUpdateView.as_view(), name="types_professional_update"),
]
