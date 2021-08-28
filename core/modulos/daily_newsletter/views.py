from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView
from datetime import datetime

from core.models import DailyNewsLetter, Professional, HealthCenter
from core.modulos.daily_newsletter.form import DailyNewsLetterForm
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger

# "add_dailynewsletter"
# "change_dailynewsletter"
# "delete_dailynewsletter"
# "view_dailynewsletter"

class MyListViewDailyNewsLetter(LoginRequiredMixin,PermissionRequiredMixin, ListView):
    permission_required = 'core.view_dailynewsletter'
    permission_denied_message = 'Permission Denied'


class MyCreateViewDailyNewsLetter(LoginRequiredMixin,PermissionRequiredMixin, CreateView):
    permission_required = 'core.add_dailynewsletter'
    permission_denied_message = 'Permission Denied'


class MyUpdateViewDailyNewsLetter(LoginRequiredMixin,PermissionRequiredMixin, UpdateView):
    permission_required = 'core.change_dailynewsletter'
    permission_denied_message = 'Permission Denied'



class DailyNewsLetterListView(MyListViewDailyNewsLetter):
    template_name = 'modulos/daily_newsletter/list_view.html'
    model = DailyNewsLetter
    paginate_by = 10

    def get_queryset(self):
        qs = super().get_queryset()
        return qs.filter()
    
    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(DailyNewsLetterListView, self).get_context_data(**kwargs)
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
            list = DailyNewsLetter.objects.filter(
                date_publication__date=self.request.GET.get('search'))
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
            searchCount = DailyNewsLetter.objects.all().count()
            context['count'] = searchCount
            return context


class DailyNewsLetterCreateView(MyCreateViewDailyNewsLetter):
    template_name = 'modulos/daily_newsletter/create_view.html'
    form_class = DailyNewsLetterForm
    success_url = reverse_lazy('core:pages:daily_newsletter:list_view')
    initial = {'capacidade_do_tanque': 0.00, }

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(DailyNewsLetterCreateView, self).form_invalid(form)

    def form_valid(self, form):
        date_input = form.cleaned_data['date_publication']
        date_time = datetime.now()
        date_publication = datetime(             
            int(date_input.__str__()[0:4]),
            int(date_input.__str__()[5:7]),
            int(date_input.__str__()[8:10]),
            date_time.hour,
            date_time.minute,
            date_time.second
        )

        daily_news_letter = form.save(commit=False)
        daily_news_letter.date_publication = date_publication

        # profissional = Professional.objects.get(user=self.request.user)
        # city = profissional.city

        # daily_news_letter.city = city

        daily_news_letter.save()

        return super().form_valid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(DailyNewsLetterCreateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context

class DailyNewsLetterUpdateView(MyUpdateViewDailyNewsLetter):
    template_name = 'modulos/daily_newsletter/create_view.html'
    model = DailyNewsLetter
    form_class = DailyNewsLetterForm
    success_url = reverse_lazy('core:pages:daily_newsletter:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(DailyNewsLetterUpdateView, self).form_invalid(form)

    def form_valid(self, form):
        date_input = form.cleaned_data['date_publication']
        date_time = datetime.now()
        date_publication = datetime(             
            int(date_input.__str__()[0:4]),
            int(date_input.__str__()[5:7]),
            int(date_input.__str__()[8:10]),
            date_time.hour,
            date_time.minute,
            date_time.second
        )

        daily_news_letter = form.save(commit=False)
        daily_news_letter.date_publication = date_publication

        # profissional = Professional.objects.get(user=self.request.user)
        # city = profissional.city

        # daily_news_letter.city = city

        daily_news_letter.save()

        return super().form_valid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(DailyNewsLetterUpdateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context