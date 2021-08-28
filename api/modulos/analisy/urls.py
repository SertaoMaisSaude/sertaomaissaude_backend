from django.urls import path
from api.modulos.analisy.views import *

urlpatterns = [
    path("list/", AnalisyListView.as_view(), name="types_professional_list"),
    path("create/", AnalisyCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", AnalisyCreateView.as_view(), name="types_professional_update"),
]
