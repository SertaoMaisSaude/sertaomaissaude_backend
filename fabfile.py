# -*- coding: utf-8 -*-
from fabric.api import *
from fabric.contrib import console


@with_settings(warn_only=True)
@hosts("root@165.22.191.46")
def deploy():
    with cd('/webapps/covid_19/COVID-19-ST-Backend/'):
        run("sudo git pull")
        if console.confirm("Install requirements.txt?", default=True):
            run('sudo ../bin/pip install -r requeriments.txt')
        if console.confirm("Run migrations?", default=True):
            run('sudo ../bin/python manage.py migrate')
        if console.confirm("Run collectstatic?", default=True):
            run('sudo ../bin/python manage.py collectstatic --noinput')
        run('sudo supervisorctl restart covid_19')


@with_settings(warn_only=True)
@hosts("root@165.22.191.46")
def deployDev():
    with cd('/webapps/covid_19_dev/COVID-19-ST-Backend/'):
        run("sudo git pull")
        if console.confirm("Install requirements.txt?", default=True):
            run('sudo ../bin/pip install -r requeriments.txt')
        if console.confirm("Run migrations?", default=True):
            run('sudo ../bin/python manage.py migrate')
        if console.confirm("Run collectstatic?", default=True):
            run('sudo ../bin/python manage.py collectstatic --noinput')
        run('sudo supervisorctl restart covid_19_dev')



@with_settings(warn_only=True)
@hosts("root@165.22.191.46")
def restartNginx():
    run('service nginx restart')


@with_settings(warn_only=True)
@hosts("root@165.22.191.46")
def restartSupervisor():
    run('service supervisor restart')
