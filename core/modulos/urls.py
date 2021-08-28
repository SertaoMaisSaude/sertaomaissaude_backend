from django.urls import path, include

from core.modulos import views

app_name = 'pages'
urlpatterns = [
    path('', views.DashBoard.as_view(), name='login'),
    path('citys/', include('core.modulos.city.urls')),
    path('professionals/', include('core.modulos.professional.urls')),
    path('health_tips/', include('core.modulos.health_tips.urls')),
    path('daily_newsletter/', include('core.modulos.daily_newsletter.urls')),
    path('blog_post/', include('core.modulos.blog_post.urls')),
    path('health_center/', include('core.modulos.health_center.urls')),
    path('analisy/', include('core.modulos.analisy.urls')),
]
