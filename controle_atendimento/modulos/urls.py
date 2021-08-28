from django.urls import path, include

from core.modulos import views

app_name = 'pages'
urlpatterns = [
    path('triagem/', include('controle_atendimento.modulos.atendimento.urls')),
]
