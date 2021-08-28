from django.urls import path

from core.modulos.daily_newsletter import views

app_name = 'daily_newsletter'

urlpatterns = [
    path('', views.DailyNewsLetterListView.as_view(), name='list_view'),
    path('create', views.DailyNewsLetterCreateView.as_view(), name='create_view'),
    path('update/<int:pk>', views.DailyNewsLetterUpdateView.as_view(), name='update_view'),
]
