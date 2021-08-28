from django.urls import path

from core.modulos.health_center import views

app_name = 'health_center'
urlpatterns = [
    path('', views.HealthCenterListView.as_view(), name='list_view'),
    path('create', views.HealthCenterCreateView.as_view(), name='create_view'),
    path('update/<int:pk>', views.HealthCenterUpdateView.as_view(), name='update_view'),
]
