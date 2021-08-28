from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.shortcuts import redirect
from django.views.generic import TemplateView
from django.contrib.auth import authenticate, logout, login as django_login
from core.models import Analisy
from core.models import RiskGroup
from django.db.models import Count
from core.models import Citizen
from core.models import DailyNewsLetter
from core.models import Professional
from core.models import HealthCenter
from datetime import date
from django.db.models import Q


class DashBoard(LoginRequiredMixin, TemplateView):
    template_name = 'modulos/index.html'
    isPsf = False
    healthCenters = None

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        analisys = Analisy.objects.all()

        # countPerRiskGroup = Citizen.objects.values('listRiskGroup__name').annotate(dcount=Count('listRiskGroup__name'))

        
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
            if profissional.typeProfessional.name == "ACS":
                self.isPsf = True
                self.healthCenters = HealthCenter.objects.filter(listProfessional__id=profissional.id)
                context["healthcenters"] = self.healthCenters
        except Professional.DoesNotExist:
            pass
        
        dailyNewsletter = DailyNewsLetter.objects.filter(active=True).order_by('-date_publication')[:1]

        if dailyNewsletter.exists():
            dailyNewsletter = dailyNewsletter.first()

        #DNL ==> dailyNewsletter
        dictDNL = self.get_dnls_list_date()

        # confirmedsDNL = DailyNewsLetter.objects.values('date', 'confirmed').order_by('date')
        # deathsDNL = DailyNewsLetter.objects.values('date', 'deaths').order_by('date')

        #ABAG ==> Age by group cases
        dictABAG = self.get_categories_by_situations('age')
        
        #CBS ==> Count Categories by situations
        dictCBS = self.get_categories_by_situations('count')
        
        #CBS ==> Data Categories by situations
        dictCBSdata = self.get_categories_by_situations('data')
      
        #QBG ==> Quantity situations by gender
        dictQBG = self.get_categories_by_situations('sex')

        #==> Count per RiskGroup    
        dictCPR = self.get_categories_by_situations('riskGroup')


        dados = {'list_analisys': dictCBSdata, 'countPerRiskGroup': dictCPR, 
        'boletim': dailyNewsletter, 'dictDNL': dictDNL, 
        'dictABAG': dictABAG, 'dictQBG' : dictQBG, "dictCBS":dictCBS, 
        "dictCBSdata": dictCBSdata}


        context.update(dados)
        return context


    def get_age_by_group(self):
        # ====
        # GraphColumn: age by age group == >ABAG
        firstCase = Analisy.objects.filter(citizen__age__lt = 18).__len__() #FirstCase = 0~18 anos
        secondCase = Analisy.objects.filter(citizen__age__gte = 19, citizen__age__lte = 40).__len__()#ThirdCase = 18~40 anos
        thirdCase = Analisy.objects.filter(citizen__age__gte = 41, citizen__age__lte = 60).__len__()#SecondCase = 41~60 anos
        fourthCase = Analisy.objects.filter(citizen__age__gt = 61).__len__() #FourthCase = 60+ anos
        # ====

        return {
            'firstCase': firstCase, 
            'secondCase': secondCase, 
            'thirdCase': thirdCase,
            'fourthCase': fourthCase,
    }

    # def get_analyzed_by_gender(self, first, second, third, fourth, fifth): 
    #     # ====
    #     # GraphColumn: quantity by gender GBG
    #     # femaleCase = Analisy.objects.filter(citizen__sex__contains = "F").__len__()#Quantity sex female 
    #     # maleCase = Analisy.objects.filter(citizen__sex__contains = "M").__len__()#Quantity sex male


    #     return 


    def check_equals(self, query1, query2): 
        check = query1
        prg=[]
        [prg.append(x.pk) for x in check]
        difference = (query2.exclude(pk__in=prg))

        return difference
    
    def get_categories_by_situations(self, search): 
        #S1 – febre ou sint. respiratório + contato confirmado (cor vermelha)
        first_situation = Analisy.objects.filter(has_faver = True, covidContact__typeContactCode = "CCC").exclude(listSympton__category__name = "Sem sintomas") | Analisy.objects.filter(listSympton__category__name = "Respiratório", covidContact__typeContactCode = "CCC").exclude(listSympton__category__name = "Sem sintomas")
        first_situation = first_situation.exclude(latLng = None)
        
        #S2 – febre ou sint. respiratório + contato suspeito (cor laranja)
        second_situation = Analisy.objects.filter(has_faver = True, covidContact__typeContactCode = "CCS").exclude(listSympton__category__name = "Sem sintomas") | Analisy.objects.filter(listSympton__category__name = "Respiratório", covidContact__typeContactCode = "CCS").exclude(listSympton__category__name = "Sem sintomas")
        second_situation = second_situation.exclude(latLng = None)
        
        #S3 – febre ou sint. respiratório + não sabe se teve contato (cor amarela)
        third_situation = Analisy.objects.filter(has_faver = True, covidContact__typeContactCode = "NSC").exclude(listSympton__category__name = "Sem sintomas") | Analisy.objects.filter(listSympton__category__name = "Respiratório", covidContact__typeContactCode = "NSC").exclude(listSympton__category__name = "Sem sintomas")
        third_situation = third_situation.exclude(latLng = None)
       
        #S4 – contato confirmado (cor roxa)
        fourth_situation = Analisy.objects.filter(covidContact__typeContactCode = "CCC").exclude(latLng = None)
        fourth_situation = self.check_equals(first_situation,fourth_situation)

        #S5 – contato suspeito (cor cinza)
        fifth_situation = Analisy.objects.filter(covidContact__typeContactCode = "CCS").exclude(latLng = None)
        fifth_situation = self.check_equals(second_situation, fifth_situation)

        if self.isPsf:
            first_situation = first_situation.filter(citizen__healthCenter__in=self.healthCenters)
            second_situation = second_situation.filter(citizen__healthCenter__in=self.healthCenters)
            third_situation = third_situation.filter(citizen__healthCenter__in=self.healthCenters)
            fourth_situation = fourth_situation.filter(citizen__healthCenter__in=self.healthCenters)
            fifth_situation = fifth_situation.filter(citizen__healthCenter__in=self.healthCenters)


        if search == 'count':
            
            return {
                'first_situation': first_situation.count(), 
                'second_situation': second_situation.count(), 
                'third_situation': third_situation.count(),
                'fourth_situation' : fourth_situation.count(), 
                'fifth_situation': fifth_situation.count(),
            }
        elif search == 'data':
            return {
                'first_situation': first_situation, 
                'second_situation': second_situation, 
                'third_situation':third_situation,
                'fourth_situation' : fourth_situation, 
                'fifth_situation': fifth_situation
            }
        elif search == 'sex':
            return {
                'first_situation_male': first_situation.filter(citizen__sex__contains = "M").__len__(),
                'first_situation_female': first_situation.filter(citizen__sex__contains = "F").__len__(),

                'second_situation_male': second_situation.filter(citizen__sex__contains = "M").__len__(),
                'second_situation_female': second_situation.filter(citizen__sex__contains = "F").__len__(),

                'third_situation_male':third_situation.filter(citizen__sex__contains = "M").__len__(),
                'third_situation_female':third_situation.filter(citizen__sex__contains = "F").__len__(),

                'fourth_situation_male' : fourth_situation.filter(citizen__sex__contains = "M").__len__(),
                'fourth_situation_female' : fourth_situation.filter(citizen__sex__contains = "F").__len__(),

                'fifth_situation_male': fifth_situation.filter(citizen__sex__contains = "M").__len__(),
                'fifth_situation_female': fifth_situation.filter(citizen__sex__contains = "F").__len__(),
            }

        elif search == 'riskGroup':
            return{
                'first_situation_riskGroup': first_situation.values('citizen__listRiskGroup__name').annotate(dcount=Count('citizen__listRiskGroup__name')),
                'second_situation_riskGroup': second_situation.values('citizen__listRiskGroup__name').annotate(dcount=Count('citizen__listRiskGroup__name')),
                'third_situation_riskGroup': third_situation.values('citizen__listRiskGroup__name').annotate(dcount=Count('citizen__listRiskGroup__name')),
                'fourth_situation_riskGroup': fourth_situation.values('citizen__listRiskGroup__name').annotate(dcount=Count('citizen__listRiskGroup__name')),
                'fifth_situation_riskGroup': fifth_situation.values('citizen__listRiskGroup__name').annotate(dcount=Count('citizen__listRiskGroup__name'))
            }

        elif search == 'age':
            first_situation_age = {
                'firstCase': first_situation.filter(citizen__age__lt = 18).__len__(), #FirstCase = 0~18 anos
                'secondCase': first_situation.filter(citizen__age__gte = 19, citizen__age__lte = 40).__len__(),#ThirdCase = 18~40 anos
                'thirdCase': first_situation.filter(citizen__age__gte = 41, citizen__age__lte = 60).__len__(),#SecondCase = 41~60 anos
                'fourthCase': first_situation.filter(citizen__age__gt = 61).__len__() #FourthCase = 60+ anos
            }

            second_situation_age = {
                'firstCase': second_situation.filter(citizen__age__lt = 18).__len__(), #FirstCase = 0~18 anos
                'secondCase': second_situation.filter(citizen__age__gte = 19, citizen__age__lte = 40).__len__(),#ThirdCase = 18~40 anos
                'thirdCase': second_situation.filter(citizen__age__gte = 41, citizen__age__lte = 60).__len__(),#SecondCase = 41~60 anos
                'fourthCase': second_situation.filter(citizen__age__gt = 61).__len__() #FourthCase = 60+ anos
            }

            third_situation_age = {
                'firstCase': third_situation.filter(citizen__age__lt = 18).__len__(), #FirstCase = 0~18 anos
                'secondCase': third_situation.filter(citizen__age__gte = 19, citizen__age__lte = 40).__len__(),#ThirdCase = 18~40 anos
                'thirdCase': third_situation.filter(citizen__age__gte = 41, citizen__age__lte = 60).__len__(),#SecondCase = 41~60 anos
                'fourthCase': third_situation.filter(citizen__age__gt = 61).__len__() #FourthCase = 60+ anos
            }

            fourth_situation_age = {
                'firstCase': fourth_situation.filter(citizen__age__lt = 18).__len__(), #FirstCase = 0~18 anos
                'secondCase': fourth_situation.filter(citizen__age__gte = 19, citizen__age__lte = 40).__len__(),#ThirdCase = 18~40 anos
                'thirdCase': fourth_situation.filter(citizen__age__gte = 41, citizen__age__lte = 60).__len__(),#SecondCase = 41~60 anos
                'fourthCase': fourth_situation.filter(citizen__age__gt = 61).__len__() #FourthCase = 60+ anos
            }

            fifth_situation_age = {
                'firstCase': fifth_situation.filter(citizen__age__lt = 18).__len__(), #FirstCase = 0~18 anos
                'secondCase': fifth_situation.filter(citizen__age__gte = 19, citizen__age__lte = 40).__len__(),#ThirdCase = 18~40 anos
                'thirdCase': fifth_situation.filter(citizen__age__gte = 41, citizen__age__lte = 60).__len__(),#SecondCase = 41~60 anos
                'fourthCase': fifth_situation.filter(citizen__age__gt = 61).__len__() #FourthCase = 60+ anos
            }

            return{
                'first_situation_age': first_situation_age,
                'second_situation_age': second_situation_age,
                'third_situation_age': third_situation_age,
                'fourth_situation_age': fourth_situation_age,
                'fifth_situation_age': fifth_situation_age
            } 



    def get_dnls_list_date(self):
        #DNL ==> dailyNewsletter
        confirmedsDNL = DailyNewsLetter.objects.filter(active=True).values('date_publication', 'date', 'confirmed').order_by('date_publication')
        deathsDNL = DailyNewsLetter.objects.filter(active=True).values('date_publication', 'date', 'deaths').order_by('date_publication')
        recoveredDNL = DailyNewsLetter.objects.filter(active=True).values('date_publication', 'date', 'recovered').order_by('date_publication')

        return {'confirmedsDNL': confirmedsDNL, 'deathsDNL': deathsDNL, 'recoveredDNL': recoveredDNL}