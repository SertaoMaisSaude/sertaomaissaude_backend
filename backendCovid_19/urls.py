from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.urls import path, include
from rest_framework.documentation import include_docs_urls
from django.conf.urls.static import static

from backendCovid_19 import settings
from core import views

urlpatterns = [
                  path('site/', include('controle_site.urls')),
                  path('', include('core.urls')),
                  path('', include('controle_atendimento.urls')),
                  path('admin/', admin.site.urls),
                  path('accounts/login/', views.LoginView.as_view(), name='login'),
                  path('api/', include('api.urls')),
                  path('docs/', include_docs_urls(title='API de Documentação')),

              ] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT) + staticfiles_urlpatterns()
