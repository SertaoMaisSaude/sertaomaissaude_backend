from django.urls import path

from core.modulos.professional import views

app_name = 'professional'
urlpatterns = [
    path('', views.ProfessionalListView.as_view(), name='list_view'),
    path('create', views.ProfessionalCreateView.as_view(), name='create_view'),
    path('update/<int:pk>', views.ProfessionalUpdateView.as_view(), name='update_view'),
    path('update_psw', views.update_password, name='update_psw')
]
