from django.urls import path, include
from controle_atendimento.modulos.atendimento import views

app_name = 'triagem'
urlpatterns = [
    path('', views.index, name='list_view'),
    path('<int:id>', views.viewcitizen, name='view_citizen'),
]