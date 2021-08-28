from django.urls import path

from core.modulos.health_tips import views

app_name = 'health_tips'
urlpatterns = [
    path('', views.HealthTipsListView.as_view(), name='list_view'),
    path('create', views.HealthTipsCreateView.as_view(), name='create_view'),
    path('update/<int:pk>', views.HealthTipsUpdateView.as_view(), name='update_view'),
]
