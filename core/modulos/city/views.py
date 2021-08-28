from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView

from core.models import City, Professional, HealthCenter
from core.modulos.city.form import CityForm
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger


# "add_city"
# "change_city"
# "delete_city"
# "view_city"

class MyListViewCity(LoginRequiredMixin, PermissionRequiredMixin, ListView):
    permission_required = 'core.view_city'
    permission_denied_message = 'Permission Denied'


class MyCreateViewCity(LoginRequiredMixin, PermissionRequiredMixin, CreateView):
    permission_required = 'core.add_city'
    permission_denied_message = 'Permission Denied'


class MyUpdateViewCity(LoginRequiredMixin, PermissionRequiredMixin, UpdateView):
    permission_required = 'core.change_city'
    permission_denied_message = 'Permission Denied'


class CityListView(MyListViewCity):
    template_name = 'modulos/city/list_view.html'
    model = City
    paginate_by = 10

    def get_queryset(self):
        qs = super().get_queryset()
        return qs.filter()
    
    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(CityListView, self).get_context_data(**kwargs)
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
            list = City.objects.filter(
                name__icontains=self.request.GET.get('search'))
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
            searchCount = City.objects.all().count()
            context['count'] = searchCount
            return context


class CityCreateView(MyCreateViewCity):
    template_name = 'modulos/city/create_view.html'
    form_class = CityForm
    success_url = reverse_lazy('core:pages:city:list_view')
    initial = {'capacidade_do_tanque': 0.00, }

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(CityCreateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(CityCreateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context


class CityUpdateView(MyUpdateViewCity):
    template_name = 'modulos/city/create_view.html'
    model = City
    form_class = CityForm
    success_url = reverse_lazy('core:pages:city:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(CityUpdateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(CityUpdateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context