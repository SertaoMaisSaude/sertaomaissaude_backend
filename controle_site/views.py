from django.shortcuts import render


def index(request):
    template_name = 'controle_site/index.html'
    return render(request, template_name)
