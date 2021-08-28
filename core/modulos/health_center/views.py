from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView

from core.models import HealthCenter, LatLng, Professional
from core.modulos.health_center.form import HealthCenterForm
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger

# "add_healthcenter"
# "change_healthcenter"
# "delete_healthcenter"
# "view_healthcenter"

class MyListViewHealthCenter(LoginRequiredMixin,PermissionRequiredMixin, ListView):
    permission_required = 'core.view_healthcenter'
    permission_denied_message = 'Permission Denied'


class MyCreateViewHealthCenter(LoginRequiredMixin, PermissionRequiredMixin,CreateView):
    permission_required = 'core.add_healthcenter'
    permission_denied_message = 'Permission Denied'


class MyUpdateViewHealthCenter(LoginRequiredMixin, PermissionRequiredMixin,UpdateView):
    permission_required = 'core.change_healthcenter'
    permission_denied_message = 'Permission Denied'

class HealthCenterListView(MyListViewHealthCenter):
    template_name = 'modulos/health_center/list_view.html'
    model = HealthCenter
    paginate_by = 10

    def get_queryset(self):
        qs = super().get_queryset()
        return qs.filter()

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(HealthCenterListView, self).get_context_data(**kwargs)
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
            list = HealthCenter.objects.filter(
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
            searchCount = HealthCenter.objects.all().count()
            context['count'] = searchCount
        return context


class HealthCenterCreateView(MyCreateViewHealthCenter):
    template_name = 'modulos/health_center/create_view.html'
    form_class = HealthCenterForm
    success_url = reverse_lazy('core:pages:health_center:list_view')
    initial = {'capacidade_do_tanque': 0.00, }

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(HealthCenterCreateView, self).form_invalid(form)

    def form_valid(self, form):
        lat = form.cleaned_data['lat']
        lng = form.cleaned_data['lng']
        health_center = form.save(commit=False)
        lat_lng = LatLng.objects.create(lat=lat, lng=lng)
        health_center.latLng = lat_lng
        

        # city = Professional.objects.get(user=self.request.user).city
        # health_center.city = city



        health_center.save()
        return super().form_valid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(HealthCenterCreateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context
        
class HealthCenterUpdateView(MyUpdateViewHealthCenter):
    template_name = 'modulos/health_center/create_view.html'
    model = HealthCenter
    form_class = HealthCenterForm
    success_url = reverse_lazy('core:pages:health_center:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(HealthCenterUpdateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(HealthCenterUpdateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context
