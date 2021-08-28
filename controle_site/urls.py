from django.urls import path, include

from controle_site import views

app_name = 'controle_site'
urlpatterns = [
    path('', views.index),
]