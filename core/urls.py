from django.urls import path, include

from core import views

app_name = 'core'
urlpatterns = [
    path('', views.index),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.LogoutRedirectViews.as_view(), name='logout'),
    path('pages/', include('core.modulos.urls')),

    path('deploy/', views.deploy, name='deploy'),
    path('backup/', views.backupTES, name='backup'),
    path('fileBackupDonwload/', views.fileBackupDownload, name='fileDownload'),

    # path('', views.Index.as_view()),
]
