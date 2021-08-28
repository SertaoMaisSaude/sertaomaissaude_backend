from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.contrib.auth.models import User, Group
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView
from django.shortcuts import redirect
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import authenticate
from unicodedata import normalize

from django.contrib import messages

from core.models import Professional, TypeProfessional, HealthCenter
from core.modulos.professional.form import ProfessionalForm
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger


# "add_professional"
# "change_professional"
# "delete_professional"
# "view_professional"


class MyListViewProfessional(LoginRequiredMixin, PermissionRequiredMixin, ListView):
    permission_required = 'core.view_professional'
    permission_denied_message = 'Permission Denied'


class MyCreateViewProfessional(LoginRequiredMixin, PermissionRequiredMixin, CreateView):
    permission_required = 'core.add_professional'
    permission_denied_message = 'Permission Denied'


class MyUpdateViewProfessional(LoginRequiredMixin, PermissionRequiredMixin, UpdateView):
    permission_required = 'core.change_professional'
    permission_denied_message = 'Permission Denied'
    pass





class ProfessionalListView(MyListViewProfessional):
    template_name = 'modulos/professional/list_view.html'
    model = Professional
    paginate_by = 10

    def get_queryset(self):
        qs = super().get_queryset()
        return qs.filter()
    
    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(ProfessionalListView, self).get_context_data(**kwargs)
        search = self.request.GET.get('search')
        searchCount = 0
        list = Professional.objects.all()
        page = self.request.GET.get('page')

        types = self.request.GET.getlist('type')

        healthCenter = self.request.GET.getlist('hcenter')

        # Filtros
        context['types_profissional'] = TypeProfessional.objects.all()
        context['healthcenters'] = HealthCenter.objects.all()

        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
            if profissional.typeProfessional.name == "ACS":
                self.isPsf = True
                self.healthCenters = HealthCenter.objects.filter(listProfessional__id=profissional.id)
                context["healthcenters"] = self.healthCenters
        except Professional.DoesNotExist:
            pass


        if search:
            # if types.__len__() > 0:
            #     list = Professional.objects.filter(
            #         name__icontains=self.request.GET.get('search'), typeProfessional__id__in=types)
            # else:
            #     list = Professional.objects.filter(
            #         name__icontains=self.request.GET.get('search'))

            list = list.filter(
                name__icontains=self.request.GET.get('search'))
                
            # Filtro por tipo de profissional
            if types.__len__() > 0:
                list = list.filter(
                    typeProfessional__id__in=types)
                context['type'] = types

            # Filtro por centro de saude
            if healthCenter.__len__() > 0:
                list = list.filter(
                    id__in=HealthCenter.objects.filter(
                        id__in=healthCenter).values('listProfessional'))
                context['hcenter'] = healthCenter
                

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
            if types.__len__() > 0:
                list = list.filter(
                    typeProfessional__id__in=types)
                context['search_list'] = list
                context['search_list_mode'] = True
                context['count'] = list.count()
                context['type'] = types

            if healthCenter.__len__() > 0:
                list = list.filter(
                    id__in=HealthCenter.objects.filter(
                        id__in=healthCenter).values('listProfessional'))
                context['search_list'] = list
                context['search_list_mode'] = True
                context['count'] = list.count()
                context['hcenter'] = healthCenter
            else:
                searchCount = Professional.objects.all().count()
                context['count'] = searchCount
            
            return context


class ProfessionalCreateView(MyCreateViewProfessional):
    template_name = 'modulos/professional/create_view.html'
    form_class = ProfessionalForm
    success_url = reverse_lazy('core:pages:professional:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(ProfessionalCreateView, self).form_invalid(form)

    def form_valid(self, form):
        login = form.cleaned_data['username']
        stringPhone = form.cleaned_data['phoneNumber'][-4:]
        stringName = form.cleaned_data['name'].split(' ')[0].lower()

        senha = normalize('NFKD', stringPhone+stringName).encode('ASCII','ignore').decode('ASCII')

        profissional = form.save(commit=False)
        user = User()
        user.username = login
        user.set_password(senha)

        user.save()

        user_group = Group.objects.get(name = profissional.typeProfessional.userGroup.name) 
        user_group.user_set.add(user)

        profissional.user = user


        # city = Professional.objects.get(user=self.request.user).city
        # profissional.city = city
        
        profissional.firstAccess = True
        profissional.save()

        messages.success(self.request, 'Usuário '+user.username+' criado. Sua senha inicial é '+senha)
        return super().form_valid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(ProfessionalCreateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context


class ProfessionalUpdateView(MyUpdateViewProfessional):
    template_name = 'modulos/professional/create_view.html'
    model = Professional
    form_class = ProfessionalForm
    success_url = reverse_lazy('core:pages:professional:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(ProfessionalUpdateView, self).form_invalid(form)

    def form_valid(self, form):
        login = form.cleaned_data['username']
        # senha = form.cleaned_data['password']
        profissional = form.save(commit=False)
        user = profissional.user
        user.username = login
        # if len(senha) > 0:
        #     user.set_password(senha)
        user.save()

        user.groups.clear()

        user_group = Group.objects.get(name = profissional.typeProfessional.userGroup.name) 
        user_group.user_set.add(user)


        profissional.save()
        return super().form_valid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(ProfessionalUpdateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context


def update_password(request):
    senha_atual = request.POST['password']  
    print(request.user)

    try:
        profissional = Professional.objects.get(user__username=request.POST['login'])
        if profissional.firstAccess:
            user = authenticate(username=profissional.user.username, password=senha_atual)
            profissional.firstAccess = False
            profissional.save()
        else:
            user = authenticate(username=request.user.username, password=senha_atual)   
    except Professional.DoesNotExist:
        user = authenticate(username=request.user.username, password=senha_atual)    

    if user: 
        senha_nova = request.POST['new_password']
        user.set_password(senha_nova)
        user.save()
        
        return JsonResponse({'data': True}, safe=False)
    else:
        return JsonResponse({'data': False}, safe=False)
