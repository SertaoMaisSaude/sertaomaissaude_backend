import traceback
import subprocess
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.files.storage import FileSystemStorage
from core.models import Professional
from django.http import HttpResponse, JsonResponse
from django.shortcuts import redirect, render
from django.utils.decorators import method_decorator
from django.views.generic import TemplateView, RedirectView
from django.contrib.auth import authenticate, logout, login as django_login

from backendCovid_19.settings import MEDIA_ROOT
from django.conf import settings


@login_required()
def index(request):
    print('INDEX')
    return LoginView.redirect_after_login(self=LoginView, user=request.user)


class LoginView(TemplateView):
    template_name = 'core/login.html'

    def get(self, request, *args, **kwargs):
        print('get')
        return super().get(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        print("POST")
        username = request.POST.get('username')
        password = request.POST.get('password')

        user = authenticate(username=username, password=password)

        if user:

            # verificar primeiro acesso profissional
            try:
                profissional = Professional.objects.get(user=user)
                if(profissional.active):
                    if profissional.firstAccess:
                        return render(request, 'modulos/professional/alter_password.html', {'object': profissional})
                    else:
                        django_login(request, user)
                        return self.redirect_after_login(user)
                    #             if not user.is_superuser:
                    #                 if UserProfile.objects.filter(user=user).exists():
                    #                     print('user.user_profile.empresa')
                    #                     print(user.user_profile.empresa)
                    #                     if user.user_profile.empresa is not None:
                    #                         if user.user_profile.empresa.bloqueado:
                    #                             message = 'Sistema Bloqueado, entrar em contato com o suporte!'
                    #                             message_error_generic(request, message)
                    #                             return self.render_to_response({'message': message})
                    #
                    # #!olinda@nova10201
                else:
                    message = 'Usuário bloqueado, entre em contato com o administrador do sistema.'
                    return self.render_to_response({'message': message})
            except Professional.DoesNotExist:
                django_login(request, user)
                return self.redirect_after_login(user)

        message = 'Usuário ou senha incorretos!!'
        return self.render_to_response({'message': message})

    def redirect_after_login(self, user):
        print(user)
        if user.is_superuser:
            print('super Usuario')
            return redirect('/admin/')

        if user:
            return redirect('/pages/')
        #
        # if user.has_perm('global_permissions.gerente_fornecedor'):
        #     return redirect('controle_combustivel:participante_index')
        #
        # if user.has_perm('global_permissions.atendente_fornecedor'):
        #     return redirect('controle_combustivel:funcionario_index')
        #
        # if user.has_perm('global_permissions.usuario_municipio'):
        #     return redirect('core:municipio_index')
        #
        # if user.has_perm('global_permissions.controle_pedido'):
        #     if user.has_perm('global_permissions.administrador'):
        #         return redirect('controle_pedido:participante_index')
        #     else:
        #         return redirect('controle_pedido:teste_tela_caixa')

        message = 'Usuário sem permissão!!'
        return self.render_to_response({'message': message})


class LogoutRedirectViews(RedirectView):
    url = '/'

    @method_decorator(login_required(login_url='core/login'))
    def get(self, request, *args, **kwargs):
        logout(request)
        return super().get(request, *args, **kwargs)


# @login_required()
# def backup(request):
#     print('backup')
#     try:
#         if request.user.is_superuser:
#             nameBaseBack = 'backJson.json'
#             nameBaseBackZip = 'backup.tar.tgz'
#             py_virtual = '/webapps/covid_19/bin/python'
#             local = '/webapps/covid_19/COVID-19-ST-Backend/manage.py dumpdata  core --indent 2 > ' + MEDIA_ROOT + nameBaseBack
#             proc = subprocess.Popen('{} {}'.format(py_virtual, local))
#             proc.wait()
#             procs = subprocess.Popen("tar -czvf {} {}".format(nameBaseBackZip, nameBaseBack), shell=True, )
#             procs.wait()
#             fs = FileSystemStorage('')
#             print('dd')
#             print(fs)
#             with fs.open(nameBaseBackZip) as tar:
#                 response = HttpResponse(tar, content_type='application/x-gzip')
#                 response['Content-Disposition'] = 'filename="backup.tar.tgz"'
#                 return response
#     except Exception as e:
#         traceback.print_exc()
#         print(e)
#         print(local)
#         print(fs)
#         return Exception(e)


try:
    from backendCovid_19.settings import PASSWORD_POSTGRES
except:
    PASSWORD_POSTGRES = ''

try:
    from backendCovid_19.settings import PASSWORD_POSTGRES
except:
    PASSWORD_POSTGRES = ''


@login_required()
def backupTES(request):
    print('backup')
    try:
        if request.user.is_superuser:
            print('1 - AQUI...........')

            # projeto = '/webapps/covid_19/COVID-19-ST-Backend/'
            local_back = 'config/backups/'
            nameBaseBack = 'backJson.sql'
            nameBaseBackZip = 'backup.tar.tgz'
            dataBasename = 'covid_19'
            backFile = '{}{}'.format(local_back, nameBaseBack)
            password = PASSWORD_POSTGRES
            print(password)
            comando = '{} pg_dump -h localhost -U postgres -f config/backups/backJson.sql covid_19 -Fc'.format(password)

            print(comando)
            proc = subprocess.Popen(comando, shell=True)
            proc.wait()
            procs = subprocess.Popen("tar -czvf {} {}".format(nameBaseBackZip, nameBaseBack), shell=True, cwd=local_back)
            procs.wait()
            # fs = FileSystemStorage('')
            # print('dd')
            # subprocess.Popen('ls', shell=True)
            # print(fs)
            # with fs.open((local_back + nameBaseBackZip)) as tar:
            #     response = HttpResponse(tar, content_type='application/x-gzip')
            # response['Content-Disposition'] = 'filename="backup.tar.tgz"'
            # return response
            return JsonResponse({'ok': True})


    except Exception as e:
        traceback.print_exc()
        print(e)
        return JsonResponse({'ok': False})


@login_required()
def fileBackupDownload(request):
    print('backup')
    try:
        if request.user.is_superuser:
            print('1 - AQUI...........')
            local_back = 'config/backups/'
            nameBaseBackZip = 'backup.tar.tgz'
            fs = FileSystemStorage('')
            with fs.open((local_back + nameBaseBackZip)) as tar:
                response = HttpResponse(tar, content_type='application/x-gzip')
            response['Content-Disposition'] = 'filename="backup.tar.tgz"'
            return response
    except Exception as e:
        traceback.print_exc()
        print(e)
        return JsonResponse({'ok': False})


@login_required()
def deploy(request):
    print('backup')
    try:
        if request.user.is_superuser:
            print('INICIO')
            # subprocess.call([
            #     "ls"])

            # condição
            # folder = 'covid_19'

            # dev = 'dev.' in request.build_absolute_uri()
            debug = settings.DEBUG

            if debug is True:
                folder = 'covid_19_dev'
                gunicorn_name = 'covid_19_dev'

            else:
                folder = 'covid_19'
                gunicorn_name = 'covid_19'

            projeto = '/webapps/{}/COVID-19-ST-Backend/'.format(folder)

            print('PASSO 1_________________________')
            subprocess.call([
                "sudo",
                "git",
                "pull"], cwd=projeto)

            pip = '/webapps/{}/bin/pip'.format(folder)
            python = '/webapps/{}/bin/python'.format(folder)
            manage = '/webapps/{}/COVID-19-ST-Backend/manage.py'.format(folder)

            print('PASSO 2_________________________')

            subprocess.call([pip,
                             "install",
                             "-r",
                             "requeriments.txt",
                             ], cwd=projeto)

            print('PASSO 3_________________________')
            subprocess.call([python,
                             manage,
                             "migrate"])
            print('PASSO 4_________________________')
            subprocess.call([python,
                             manage,
                             "collectstatic", "--noinput"])
            print('PASSO 5_________________________')
            subprocess.call(["sudo",
                             "supervisorctl",
                             "restart",
                             gunicorn_name])

            return JsonResponse({'ok': True})

    except Exception as e:
        traceback.print_exc()
        print(e)
        return JsonResponse({'ok': False})
        pass
#
#
# from os import path
