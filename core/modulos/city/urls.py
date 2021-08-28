from django.urls import path

from core.modulos.city import views

app_name = 'city'
urlpatterns = [
    path('', views.CityListView.as_view(), name='list_view'),
    path('create', views.CityCreateView.as_view(), name='create_view'),
    path('update/<int:pk>', views.CityUpdateView.as_view(), name='update_view'),
]
