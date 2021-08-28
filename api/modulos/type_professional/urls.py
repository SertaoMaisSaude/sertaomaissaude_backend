from django.urls import path

from api.modulos.type_professional.views import TypeProfessionalList, TypeProfessionalCreate, TypeProfessionalUpdate

urlpatterns = [
    path("list/", TypeProfessionalList.as_view(), name="types_professional_list"),
    path("create/", TypeProfessionalCreate.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", TypeProfessionalUpdate.as_view(), name="types_professional_update"),
]
