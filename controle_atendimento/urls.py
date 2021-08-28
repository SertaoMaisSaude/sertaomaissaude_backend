from django.urls import path, include

from core import views

app_name = 'atendimento'
urlpatterns = [
    path('pages/', include('controle_atendimento.modulos.urls')),
]
