from django.contrib.auth.decorators import login_required, permission_required
from django.shortcuts import render
from rest_framework.decorators import api_view

from core.models import *
from controle_atendimento.modulos.atendimento.form import SituacoesForm, StatusForm
from django.db.models import Q



def check_equals(query1, query2): 
        check = query1
        prg=[]
        [prg.append(x.pk) for x in check]
        difference = (query2.exclude(pk__in=prg))

        return difference




@login_required()
@permission_required('core.view_analisy', raise_exception=True)
def index(request):
    context = {}
    isPsf = False
    healthCenters = None

    try:
        profissional = Professional.objects.get(user=request.user)
        context['profissional'] = profissional
        if profissional.typeProfessional.name == "ACS":
            isPsf = True
            healthCenters = HealthCenter.objects.filter(listProfessional__id=profissional.id)
            context["healthcenters"] = healthCenters
    except Professional.DoesNotExist:
        pass
    
    if healthCenters == None:
        context['healthcenters'] = HealthCenter.objects.all() #teste

    context['neighborhoods'] = Citizen.objects.exclude(neighborhood__exact='').values(
        'neighborhood').distinct()

    
    dados = Analisy.objects.distinct("citizen__phoneNumber")

    
    

    # S1 – febre ou sint. respiratório + contato confirmado (cor vermelha)
    first_situation = dados.filter(has_faver=True, covidContact__typeContactCode="CCC").exclude(
        listSympton__category__name="Sem sintomas") | dados.filter(
        listSympton__category__name__startswith="Respiratório", covidContact__typeContactCode="CCC")
    
    first_situation = first_situation.exclude(latLng = None)

    # S2 – febre ou sint. respiratório + contato suspeito (cor laranja)
    second_situation = dados.filter(has_faver=True, covidContact__typeContactCode="CCS").exclude(
        listSympton__category__name="Sem sintomas") | dados.filter(
        listSympton__category__name__startswith="Respiratório", covidContact__typeContactCode="CCS")

    second_situation = second_situation.exclude(latLng = None)

    # S3 – febre ou sint. respiratório + não sabe se teve contato (cor amarela)
    third_situation = dados.filter(has_faver=True, covidContact__typeContactCode="NSC").exclude(
        listSympton__category__name="Sem sintomas") | dados.filter(
        listSympton__category__name__startswith="Respiratório", covidContact__typeContactCode="NSC")

    third_situation = third_situation.exclude(latLng = None)

    # S4 – assintomático + contato confirmado (cor roxa)
    fourth_situation = dados.filter(has_faver=False, covidContact__typeContactCode="CCC").exclude(listSympton__category__name__startswith="Respiratório")
    fourth_situation = fourth_situation.exclude(latLng = None)

    # S5 – assintomático + contato suspeito (cor cinza)
    fifth_situation = dados.filter(has_faver=False, covidContact__typeContactCode="CCS").exclude(listSympton__category__name__startswith="Respiratório")
    fifth_situation = fifth_situation.exclude(latLng = None)


    if isPsf:
        first_situation = first_situation.filter(citizen__healthCenter__in=healthCenters)
        second_situation = second_situation.filter(citizen__healthCenter__in=healthCenters)
        third_situation = third_situation.filter(citizen__healthCenter__in=healthCenters)
        fourth_situation = fourth_situation.filter(citizen__healthCenter__in=healthCenters)
        fifth_situation = fifth_situation.filter(citizen__healthCenter__in=healthCenters)


   
    

    #Prioridade de apresentacao se mudar de situação - Apresentar a mais grave.
    fifth_situation = fifth_situation.exclude(citizen__phoneNumber__in = fourth_situation.values("citizen__phoneNumber"))
    fifth_situation = fifth_situation.exclude(citizen__phoneNumber__in = third_situation.values("citizen__phoneNumber"))
    fifth_situation = fifth_situation.exclude(citizen__phoneNumber__in = second_situation.values("citizen__phoneNumber"))
    fifth_situation = fifth_situation.exclude(citizen__phoneNumber__in = first_situation.values("citizen__phoneNumber"))

    fourth_situation = fourth_situation.exclude(citizen__phoneNumber__in=third_situation.values("citizen__phoneNumber"))
    fourth_situation = fourth_situation.exclude(citizen__phoneNumber__in=second_situation.values("citizen__phoneNumber"))
    fourth_situation = fourth_situation.exclude(citizen__phoneNumber__in=first_situation.values("citizen__phoneNumber"))

    third_situation = third_situation.exclude(citizen__phoneNumber__in=second_situation.values("citizen__phoneNumber"))
    third_situation = third_situation.exclude(citizen__phoneNumber__in=first_situation.values("citizen__phoneNumber"))

    second_situation = second_situation.exclude(citizen__phoneNumber__in=first_situation.values("citizen__phoneNumber"))

   

    sex = request.GET.getlist('sex')
    healthCenter = request.GET.getlist('hcenter')
    neighborhood = request.GET.getlist('nbhood')
    date = request.GET.get('date')
    
    if date:
        date = date[-4:] + '-' + date[3:5] + '-' + date[0:2]

    if sex.__len__() > 0:
        first_situation = first_situation.filter(citizen__sex__in=sex)
        second_situation = second_situation.filter(citizen__sex__in=sex)
        third_situation = third_situation.filter(citizen__sex__in=sex)
        fourth_situation = fourth_situation.filter(citizen__sex__in=sex)
        fifth_situation = fifth_situation.filter(citizen__sex__in=sex)
        context['sex'] = sex
        context['search_list'] = 'filtro'

    if healthCenter.__len__() > 0:
        first_situation = first_situation.filter(citizen__healthCenter__in=healthCenter)
        second_situation = second_situation.filter(citizen__healthCenter__in=healthCenter)
        third_situation = third_situation.filter(citizen__healthCenter__in=healthCenter)
        fourth_situation = fourth_situation.filter(citizen__healthCenter__in=healthCenter)
        fifth_situation = fifth_situation.filter(citizen__healthCenter__in=healthCenter)
        context['hcenter'] = healthCenter
        context['search_list'] = 'filtro'

    if neighborhood.__len__() > 0:
        first_situation = first_situation.filter(citizen__neighborhood__in=neighborhood)
        second_situation = second_situation.filter(citizen__neighborhood__in=neighborhood)
        third_situation = third_situation.filter(citizen__neighborhood__in=neighborhood)
        fourth_situation = fourth_situation.filter(citizen__neighborhood__in=neighborhood)
        fifth_situation = fifth_situation.filter(citizen__neighborhood__in=neighborhood)
        context['nbhood'] = neighborhood
        context['search_list'] = 'filtro'

    if date:
        
        first_situation = first_situation.filter(date__date=date)
        second_situation = second_situation.filter(date__date=date)
        third_situation = third_situation.filter(date__date=date)
        fourth_situation = fourth_situation.filter(date__date=date)
        fifth_situation = fifth_situation.filter(date__date=date)
        date = date[-2:] + '/' + date[5:7] + "/" + date[0:4]
        context['date'] = date

    

    first_situation = (set(first_situation))
    second_situation = (set(second_situation))
    third_situation = (set(third_situation))
    fourth_situation = (set(fourth_situation))
    fifth_situation = (set(fifth_situation))

    context['first_situation']= first_situation
    context['second_situation']= second_situation
    context['third_situation']= third_situation
    context['fourth_situation']= fourth_situation
    context['fifth_situation']= fifth_situation

    
    context['formstatus']= StatusForm
    context['formsituacao']= SituacoesForm


    if request.method == "POST":
        analise = request.POST.get('analise')
        status = request.POST.get('status')
        situacao = request.POST.get('situacao')
        analisesearh = Analisy.objects.get(pk=analise)
        analisesearh.patient_situation = situacao
        analisesearh.teleatend_status = status
        analisesearh.save()
    

    
    return render(request, 'modulos/pre_triagem/list_view.html', context=context)


@login_required()
@permission_required('core.view_analisy', raise_exception=True)
def viewcitizen(request, id):
    if request.method == "POST":
        analise = request.POST.get('analise')
        status = request.POST.get('status')
        situacao = request.POST.get('situacao')
        analisesearh = Analisy.objects.get(pk=analise)
        analisesearh.patient_situation = situacao
        analisesearh.teleatend_status = status
        analisesearh.save()

    analise = Analisy.objects.get(pk=id)
    analises = Analisy.objects.filter(citizen__phoneNumber=analise.citizen.phoneNumber)
    return render(request, 'modulos/pre_triagem/view_citizen.html',
                  {'analizy': analise, 'formstatus': StatusForm, 'formsituacao': SituacoesForm, 'analises':analises})
