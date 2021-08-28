from django.urls import path

from api.modulos.daily_news_letter.views import *

urlpatterns = [
    path("list/", DailyNewsLetterListTrue.as_view(), name="types_professional_list"),
    path("create/", DailyNewsLetterCreate.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", DailyNewsLetterUpdate.as_view(), name="types_professional_update"),
]
