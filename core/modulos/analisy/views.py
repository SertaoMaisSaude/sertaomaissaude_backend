from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView
from django.shortcuts import render
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.http import JsonResponse, HttpResponse, FileResponse
import io
import xlwt
import re
from datetime import datetime
from django.db.models import Q

from operator import itemgetter

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.lib.pagesizes import letter, landscape, A4
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, \
    Table, TableStyle

from core.models import Analisy, HealthCenter, Citizen, Professional

# "add_analisy"
# "change_analisy"
# "delete_analisy"
# "view_analisy"


class MyListViewAnalisy(LoginRequiredMixin, PermissionRequiredMixin, ListView):
    permission_required = 'core.view_analisy'
    permission_denied_message = 'Permission Denied'


class AnalisyListView(MyListViewAnalisy):
    template_name = 'modulos/analisy/list_view.html'
    model = Analisy
    paginate_by = 10
    # search_fields = ['analisy_citizen__name']
    healthCenters = None

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(AnalisyListView, self).get_context_data(**kwargs)
        search = self.request.GET.get('search')
        searchCount = 0
        list = Analisy.objects.all()

        page = self.request.GET.get('page')

        # Gets de Filtros
        sex = self.request.GET.getlist('sex')
        healthCenter = self.request.GET.getlist('hcenter')
        neighborhood = self.request.GET.getlist('nbhood')
        date = self.request.GET.get('date')

        context['healthcenters'] = HealthCenter.objects.all()

        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
            if profissional.typeProfessional.name == "ACS":
                self.healthCenters = HealthCenter.objects.filter(listProfessional__id=profissional.id)
                list = list.filter(citizen__healthCenter__in=self.healthCenters)
                context = self.get_objectList(list)
                context['healthcenters'] = self.healthCenters
                

        except Professional.DoesNotExist:
            pass


        if date:
            date = date[-4:]+'-'+date[3:5]+'-'+date[0:2]

        

        context['neighborhoods'] = Citizen.objects.exclude(neighborhood__exact='').values(
            'neighborhood').distinct()


        if search:
            list = list.filter(
                citizen__name__icontains=self.request.GET.get('search'))

            if sex.__len__() > 0:
                list = list.filter(citizen__sex__in=sex)
                context['sex'] = sex

            if healthCenter.__len__() > 0:
                list = list.filter(citizen__healthCenter__in=healthCenter)
                context['hcenter'] = healthCenter


            if neighborhood.__len__() > 0:
                if neighborhood[0] == 'vazio':
                    list = list.filter(Q(citizen__neighborhood = None) | Q(citizen__neighborhood__exact=''))
                    
                else:
                    list = list.filter(citizen__neighborhood__in=neighborhood)
                context['nbhood'] = neighborhood

            if date:
                list = list.filter(date__date=date)
                date = date[-2:]+'/'+date[5:7]+"/"+date[0:4]
                context['date'] = date

            searchCount = list.__len__()
            context['search_list_mode'] = True
            context['search'] = search
            context['count'] = searchCount

            paginator = Paginator(list, 10)
            if page is not None:
                context['search_list'] = paginator.page(page)
                return context

            else:
                context['search_list'] = paginator.page(1)
                return context
        else:

            if sex.__len__() > 0:
                list = list.filter(citizen__sex__in=sex)
                context['search_list_mode'] = True
                context['count'] = list.__len__()
                context['sex'] = sex
                paginator = Paginator(list, 10)
                if page is not None:
                    context['search_list'] = paginator.page(page)
                    # return context
                else:
                    context['search_list'] = paginator.page(1)
                    # return context

            if healthCenter.__len__() > 0:
                list = list.filter(citizen__healthCenter__in=healthCenter)
                context['hcenter'] = healthCenter
                context['search_list_mode'] = True
                context['count'] = list.__len__()
                paginator = Paginator(list, 10)
                if page is not None:
                    context['search_list'] = paginator.page(page)
                    # return context
                else:
                    context['search_list'] = paginator.page(1)

            if neighborhood.__len__() > 0:
                if neighborhood[0] == 'vazio':
                    list = list.filter(Q(citizen__neighborhood = None) | Q(citizen__neighborhood__exact=''))
                    
                else:
                    list = list.filter(citizen__neighborhood__in=neighborhood)
                
                context['nbhood'] = neighborhood
                context['search_list_mode'] = True
                context['count'] = list.__len__()
                paginator = Paginator(list, 10)
                if page is not None:
                    context['search_list'] = paginator.page(page)
                    
                else:
                    context['search_list'] = paginator.page(1)

            if date:
                list = list.filter(date__date=date)
                date = date[-2:]+'/'+date[5:7]+"/"+date[0:4]
                context['date'] = date
                context['search_list_mode'] = True
                context['count'] = list.__len__()
                paginator = Paginator(list, 10)
                if page is not None:
                    context['search_list'] = paginator.page(page)
                    # return context
                else:
                    context['search_list'] = paginator.page(1)

            if not date and not neighborhood.__len__() > 0 and not healthCenter.__len__() > 0 and not sex.__len__() > 0:
                searchCount = Analisy.objects.all().count()
                context['count'] = searchCount

            return context

        return context

    def get_queryset(self):
        # cities = City.objects.get(user=self.request.user)
        qs = super().get_queryset()
        # #print(qs.filter(setor_empresa__empresa=userProfile.empresa))
        return qs.filter()


    def get_objectList(self, queryset):
        page_size = self.get_paginate_by(queryset)
        if page_size:
            paginator, page, queryset, is_paginated = self.paginate_queryset(queryset, page_size)
            context = {
                'paginator': paginator,
                'page_obj': page,
                'is_paginated': is_paginated,
                'object_list': queryset
            }
        else:
            context = {
                'paginator': None,
                'page_obj': None,
                'is_paginated': False,
                'object_list': queryset
            }
        return context

def get_list(group):
    dict = {}

    if group.count() > 0:
        for obj in group:
            dict["{}".format(obj)] = obj.name

    elif group.count() == 0:
        dict['Nenhum'] = "Nenhum"

    return dict


def get_analisy(request):
    id_analisy = request.GET.get('id', None)
    obj_analisy = Analisy.objects.get(id=id_analisy)

    symptoms = get_list(obj_analisy.listSympton.all())

    risk_groups = get_list(obj_analisy.citizen.listRiskGroup.all())

    if obj_analisy.citizen.otherRiskGroup is not None:
        risk_groups['other_risk_groups'] = obj_analisy.citizen.otherRiskGroup

    if obj_analisy.otherSympton is not None:
        symptoms['other_sympton'] = obj_analisy.otherSympton

    data = {
        "citizen": obj_analisy.citizen.getJson(),
        "analisy": obj_analisy.getJson(),
        "faver": "Não" if obj_analisy.has_faver == False else "{}°C".format(obj_analisy.fever),
        "covidContact": obj_analisy.covidContact.description,
        "symptoms": symptoms,
        "risk_groups": risk_groups,
    }

    if obj_analisy.latLng:
        data["lat"] = obj_analisy.latLng.lat
        data["lng"] = obj_analisy.latLng.lng
    else:
        data["lat"] = None
        data["lng"] = None

    return JsonResponse(data)




def check_situations(date):
    temp = date.filter(has_faver = True, covidContact__typeContactCode = "CCC").exclude(listSympton__category__name = "Sem sintomas") | date.filter(listSympton__category__name = "Respiratório", covidContact__typeContactCode = "CCC").exclude(listSympton__category__name = "Sem sintomas") | date.filter(has_faver = True, covidContact__typeContactCode = "CCS").exclude(listSympton__category__name = "Sem sintomas") | date.filter(listSympton__category__name = "Respiratório", covidContact__typeContactCode = "CCS").exclude(listSympton__category__name = "Sem sintomas") | date.filter(has_faver = True, covidContact__typeContactCode = "NSC").exclude(listSympton__category__name = "Sem sintomas") | date.filter(listSympton__category__name = "Respiratório", covidContact__typeContactCode = "NSC").exclude(listSympton__category__name = "Sem sintomas") | date.filter(covidContact__typeContactCode = "CCC").exclude(latLng = None) | date.filter(covidContact__typeContactCode = "CCS").exclude(latLng = None)
    temp = temp.exclude(latLng = None)
    temp = temp.distinct("citizen__phoneNumber")
    return temp 

def export_xls(request):

    search = request.GET.get('search')
    sex = request.GET.getlist('sex')
    healthCenter = request.GET.getlist('hcenter')
    neighborhood = request.GET.getlist('nbhood')
    date = request.GET.get('date')


   
    

    date_relatory = datetime.now().date().__str__()
    
    date_relatory = date_relatory[-2:]+"-" + \
        date_relatory[5:7]+"-"+date_relatory[0:4]

    # Configuração de resposta e style
    response = HttpResponse(content_type='application/ms-excel')
    response['Content-Disposition'] = 'attachment; filename="relatory.xls"'
    wb = xlwt.Workbook(encoding='utf-8')
    ws = wb.add_sheet('Análises '+date_relatory)
    font_style = xlwt.XFStyle()
    font_style.font.bold = True

    # Cabeçalho do arquivo
    row_num = 0
    columns = ['NOME', 'SEXO', 'IDADE', 'TELEFONE', 'LATITUDE', 'LONGITUDE',
        'FEBRE?', 'CONTATO PESSOAL COVID?', 'DATA', 'GRUPO DE RISCO', 'SINTOMAS']
    for col_num in range(len(columns)):
        ws.write(row_num, col_num, columns[col_num], font_style)

    # Reset font style
    font_style = xlwt.XFStyle()

    # Pesquisa
    rows = Analisy.objects.all()

    isPsf = False
    healthCenters = None

    try:
        profissional = Professional.objects.get(user=request.user)
        # context['profissional'] = profissional
        if profissional.typeProfessional.name == "ACS":
            isPsf = True
            healthCenters = HealthCenter.objects.filter(listProfessional__id=profissional.id)
            # context["healthcenters"] = healthCenters
    except Professional.DoesNotExist:
        pass

    if isPsf:
            rows = rows.filter(citizen__healthCenter__in=healthCenters)

    # Filtros
    if search:
        rows = rows.filter(citizen__name__icontains=search)

    if sex.__len__() > 0:
        rows = rows.filter(citizen__sex__in=sex)

    if healthCenter.__len__() > 0:
        rows = rows.filter(citizen__healthCenter__in=healthCenter)

    if neighborhood.__len__() > 0:
        rows = rows.filter(citizen__neighborhood__in=neighborhood)

    if date:
        date = date[-4:]+'-'+date[3:5]+'-'+date[0:2]
        rows = rows.filter(date__date=date)

    if '/triagem' in request.META.get("HTTP_REFERER"):
        rows = check_situations(rows)


    for row in rows:
        try:
            row_adapter = ((row.citizen.name, row.citizen.sex, row.citizen.age, row.citizen.phoneNumber, row.latLng.lat, row.latLng.lng, get_faver(
                row.has_faver, row.fever), row.covidContact.description, row.date.__str__(), get_list_risk_group(row.citizen.listRiskGroup.all()), get_list_risk_group(row.listSympton.all())))
        except AttributeError:
            row_adapter = ((row.citizen.name, row.citizen.sex, row.citizen.age, row.citizen.phoneNumber, '', '', get_faver(row.has_faver, row.fever),
                           row.covidContact.description, row.date.__str__(), get_list_risk_group(row.citizen.listRiskGroup.all()), get_list_risk_group(row.listSympton.all())))

        row_num += 1
        col_num = 0
        for col in row_adapter:
            ws.write(row_num, col_num, col, font_style)
            col_num += 1
    wb.save(response)
    return response


def get_list_risk_group(listRiskGroup):
    str_list = ''
    for risk in listRiskGroup:
        if listRiskGroup.last().id == risk.id:
            str_list += risk.name
        else:
            str_list += risk.name + ', '
    return str_list


def get_faver(has_faver, fever):
    if has_faver:
        if fever is None:
            return "Sim"
        else:
            return fever.__str__()
    else:
        return "Não"


def export_PDF(request):

    search = request.GET.get('search')
    sex = request.GET.getlist('sex')
    healthCenter = request.GET.getlist('hcenter')
    neighborhood = request.GET.getlist('nbhood')
    date = request.GET.get('date')

    date_relatory = datetime.now().date().__str__()
    date_relatory = date_relatory[-2:]+"-" + \
        date_relatory[5:7]+"-"+date_relatory[0:4]

    # Pesquisa
    rows = Analisy.objects.all()

    isPsf = False
    healthCenters = None

    try:
        profissional = Professional.objects.get(user=request.user)
        # context['profissional'] = profissional
        if profissional.typeProfessional.name == "ACS":
            isPsf = True
            healthCenters = HealthCenter.objects.filter(listProfessional__id=profissional.id)
            # context["healthcenters"] = healthCenters
    except Professional.DoesNotExist:
        pass

    if isPsf:
            rows = rows.filter(citizen__healthCenter__in=healthCenters)

    # Filtros
    if search:
        rows = rows.filter(citizen__name__icontains=search)

    if sex.__len__() > 0:
        rows = rows.filter(citizen__sex__in=sex)

    if healthCenter.__len__() > 0:
        rows = rows.filter(citizen__healthCenter__in=healthCenter)

    if neighborhood.__len__() > 0:
        rows = rows.filter(citizen__neighborhood__in=neighborhood)

    if date:
        date = date[-4:]+'-'+date[3:5]+'-'+date[0:2]
        rows = rows.filter(date__date=date)

    if '/triagem' in request.META.get("HTTP_REFERER"): 
        rows = check_situations(rows)

    list = [
        ['NOME', 'SEXO','IDADE', 'TELEFONE','FEBRE?','CONTATO PESSOAL COVID?','DATA','GRUPO DE RISCO','SINTOMAS']
    ]
    
    for row in rows:
        try:
            list.append([
                row.citizen.name,
                row.citizen.sex,
                row.citizen.age.__str__(),
                row.citizen.phoneNumber,
                # row.latLng.lat.__str__(),
                # row.latLng.lng.__str__(),
                get_faver(row.has_faver, row.fever),
                row.covidContact.description,
                row.date.__str__(),
                get_list_risk_group(row.citizen.listRiskGroup.all()),
                get_list_risk_group(row.listSympton.all())
            ])
        except AttributeError:
            list.append([
                row.citizen.name,
                row.citizen.sex,
                row.citizen.age.__str__(),
                row.citizen.phoneNumber,
                # '',
                # '',
                get_faver(row.has_faver, row.fever),
                row.covidContact.description,
                row.date.__str__(),
                get_list_risk_group(row.citizen.listRiskGroup.all()),
                get_list_risk_group(row.listSympton.all())
            ])




    #     try:
    #         list.append({
    #             'name': row.citizen.name,
    #             'sex': row.citizen.sex,
    #             'age': row.citizen.age,
    #             'phoneNumber': row.citizen.phoneNumber,
    #             'lat': row.latLng.lat,
    #             'lng': row.latLng.lng,
    #             'fever': get_faver(row.has_faver, row.fever),
    #             'covidContact': row.covidContact.description,
    #             'date': row.date.__str__(),
    #             'riskGroup': get_list_risk_group(row.citizen.listRiskGroup.all()),
    #             'sympton': get_list_risk_group(row.listSympton.all())
    #         })
    #     except AttributeError:
    #         list.append({
    #             'name': row.citizen.name,
    #             'sex': row.citizen.sex,
    #             'age': row.citizen.age,
    #             'phoneNumber': row.citizen.phoneNumber,
    #             'lat': '',
    #             'lng': '',
    #             'fever': get_faver(row.has_faver, row.fever),
    #             'covidContact': row.covidContact.description,
    #             'date': row.date.__str__(),
    #             'riskGroup': get_list_risk_group(row.citizen.listRiskGroup.all()),
    #             'sympton': get_list_risk_group(row.listSympton.all())
    #         })

    # fields = (
    #     ('name', 'NOME'),
    #     ('sex', 'SEXO'),
    #     ('age', 'IDADE'),
    #     ('phoneNumber', 'TELEFONE'),
    #     ('lat', 'LATITUDE'),
    #     ('lng', 'LONGITUDE'),
    #     ('fever', 'FEBRE?'),
    #     ('covidContact', 'CONTATO PESSOAL COVID?'),
    #     ('date', 'DATA'),
    #     ('riskGroup', 'GRUPO DE RISCO'),
    #     ('sympton', 'SINTOMAS'),
    # )


    dateActualy = datetime.now().date().__str__()
    dateActualy = dateActualy[-2:]+"/"+dateActualy[5:7]+"/"+dateActualy[0:4]
    timeActualy = datetime.now().time().__str__()[0:8]
    
    title = "Relatório Sertão Saúde em "+dateActualy+" às "+timeActualy

    data = DataToPdf(fields=None, data=list, title=title)
    return FileResponse(data.export('relatory.pdf'), as_attachment=True, filename='relatory.pdf')


class DataToPdf():

    def __init__(self, fields, data, sort_by=None, title=None):
        self.fields = fields
        self.data = data
        self.title = title
        self.sort_by = sort_by

    def export(self, filename, data_align='LEFT', table_halign='MIDDLE'):

        buffer = io.BytesIO()

        doc = SimpleDocTemplate(buffer, pagesize=landscape(
            A4), leftMargin=10, rightMargin=10, topMargin=20, bottomMargin=10)

        styles = getSampleStyleSheet()
        styleH = styles['Heading2']
        styleH.alignment = TA_CENTER
        styleH.fontSize = 24

        story = []

        if self.title:
            story.append(Paragraph(self.title, styleH))
            story.append(Spacer(1, 0.25 * inch))

        # if self.sort_by:
        #     reverse_order = False
        #     if (str(self.sort_by[1]).upper() == 'DESC'):
        #         reverse_order = True

        #     self.data = sorted(self.data,
        #                        key=itemgetter(self.sort_by[0]),
        #                        reverse=reverse_order)

        # converted_data = self.__convert_data()
        # table = Table(converted_data, hAlign=table_halign)
        # table.setStyle
        style = TableStyle([
                            ('FONT', (0, 0), (-1, 0), 'Times-Roman'),
                            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
                            ('ALIGN',(0, 0),(0,-1), data_align),
                            ('INNERGRID', (0, 0), (-1, -1), 0.50, colors.black),
                            ('BOX', (0,0), (-1,-1), 0.25, colors.black),
                            ('VALIGN',(0,0),(-1,-1),'MIDDLE'),
                       ])

       

      # Configure style and word wrap
        s = getSampleStyleSheet()
        s = s["BodyText"]
        s.wordWrap = 'CJK'
        s.fontSize = 10
        s.fontName = "Times-Roman"
        s.alignment = TA_CENTER
        

        data2 = [[Paragraph(cell, s) for cell in row] for row in self.data]
        t = Table(data2)
        t.setStyle(style)

        # Send the data and build the file
        story.append(t)
        # doc.build(elements)

        # story.append(table)
        doc.build(story)

        buffer.seek(0)

        return buffer

    def __convert_data(self):       
        keys, names = zip(*[[k, n] for k, n in self.fields])
        new_data = [names]

        for d in self.data:
            new_data.append([d[k] for k in keys])

        return new_data
