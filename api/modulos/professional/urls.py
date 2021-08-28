from django.urls import path

from api.modulos.professional.views import ProfessionalListView, ProfessionalCreateView, ProfessionalUpdateView

urlpatterns = [
    path("list/", ProfessionalListView.as_view(), name="types_professional_list"),
    path("create/", ProfessionalCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", ProfessionalUpdateView.as_view(), name="types_professional_update"),
]
