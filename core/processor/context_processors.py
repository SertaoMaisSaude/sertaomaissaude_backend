from django.conf import settings
from django.contrib.auth.models import User


def debug(request):
    nomeBotao = 'DEPLOY DEV ' if settings.DEBUG else 'DEPLOY PROD'
    return {'DEBUG': settings.DEBUG,
            'nomeBotao': nomeBotao,
            'DEPLOY_PRODUCAO': request.user.user_permissions.filter(codename='faz_deploy_producao').exists()
            }
