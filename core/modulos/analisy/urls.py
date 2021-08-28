from django.urls import path

from core.modulos.analisy import views

app_name = 'analisy'
urlpatterns = [
    path('', views.AnalisyListView.as_view(), name='list_view'),
    path("pages/analisy/get-analisy/", views.get_analisy, name = "get_analisy"),
    path("export", views.export_xls, name = "export"),
    path("export_pdf", views.export_PDF, name = "export_pdf"),
]

