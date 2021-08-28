from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView

from core.models import HealthTips, Professional, HealthCenter
from core.modulos.health_tips.form import HealthTipsForm
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger


# "add_healthtips"
# "change_healthtips"
# "delete_healthtips"
# "view_healthtips"

class MyListViewHealthTips(LoginRequiredMixin, PermissionRequiredMixin, ListView):
    permission_required = 'core.view_healthtips'
    permission_denied_message = 'Permission Denied'


class MyCreateViewHealthTips(LoginRequiredMixin, PermissionRequiredMixin, CreateView):
    permission_required = 'core.add_healthtips'
    permission_denied_message = 'Permission Denied'


class MyUpdateViewHealthTips(LoginRequiredMixin, PermissionRequiredMixin, UpdateView):
    permission_required = 'core.change_healthtips'
    permission_denied_message = 'Permission Denied'


class HealthTipsListView(MyListViewHealthTips):
    template_name = 'modulos/health_tips/list_view.html'
    model = HealthTips
    paginate_by = 10

    def get_queryset(self):
        qs = super().get_queryset()
        return qs.filter()
    
    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(HealthTipsListView, self).get_context_data(**kwargs)
        search = self.request.GET.get('search')
        searchCount = 0
        list = []
        page = self.request.GET.get('page')

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
            list = HealthTips.objects.filter(
                title__icontains=self.request.GET.get('search'))
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
            searchCount = HealthTips.objects.all().count()
            context['count'] = searchCount
            return context


class HealthTipsCreateView(MyCreateViewHealthTips):
    template_name = 'modulos/health_tips/create_view.html'
    form_class = HealthTipsForm
    success_url = reverse_lazy('core:pages:health_tips:list_view')
    initial = {'capacidade_do_tanque': 0.00, }

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(HealthTipsCreateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(HealthTipsCreateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context


class HealthTipsUpdateView(MyUpdateViewHealthTips):
    template_name = 'modulos/health_tips/create_view.html'
    model = HealthTips
    form_class = HealthTipsForm
    success_url = reverse_lazy('core:pages:health_tips:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(HealthTipsUpdateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(HealthTipsUpdateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context
