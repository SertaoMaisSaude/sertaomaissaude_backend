from django.contrib.auth.mixins import LoginRequiredMixin, PermissionRequiredMixin
from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView

from core.models import BlogPost, Professional, HealthCenter
from core.modulos.blog_post.form import BlogPostForm
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger


# "add_blogpost"
# "change_blogpost"
# "delete_blogpost"
# "view_blogpost"

class MyListViewBlogPost(LoginRequiredMixin, PermissionRequiredMixin, ListView):
    permission_required = 'core.view_blogpost'
    permission_denied_message = 'Permission Denied'


class MyCreateViewBlogPost(LoginRequiredMixin, PermissionRequiredMixin, CreateView):
    permission_required = 'core.add_blogpost'
    permission_denied_message = 'Permission Denied'


class MyUpdateViewBlogPost(LoginRequiredMixin, PermissionRequiredMixin, UpdateView):
    permission_required = 'core.change_blogpost'
    permission_denied_message = 'Permission Denied'


class BlogPostListView(MyListViewBlogPost):
    template_name = 'modulos/blog_post/list_view.html'
    model = BlogPost
    paginate_by = 10

    def get_queryset(self):
        qs = super().get_queryset()
        return qs.filter()
    
    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(BlogPostListView, self).get_context_data(**kwargs)
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
            list = BlogPost.objects.filter(
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
            searchCount = BlogPost.objects.all().count()
            context['count'] = searchCount
            return context


class BlogPostCreateView(MyCreateViewBlogPost):
    template_name = 'modulos/blog_post/create_view.html'
    form_class = BlogPostForm
    success_url = reverse_lazy('core:pages:blog_post:list_view')
    initial = {'capacidade_do_tanque': 0.00, }

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(BlogPostCreateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(BlogPostCreateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context

class BlogPostUpdateView(MyUpdateViewBlogPost):
    template_name = 'modulos/blog_post/create_view.html'
    model = BlogPost
    form_class = BlogPostForm
    success_url = reverse_lazy('core:pages:blog_post:list_view')

    def form_invalid(self, form):
        print(form.errors, len(form.errors))
        return super(BlogPostUpdateView, self).form_invalid(form)

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(BlogPostUpdateView, self).get_context_data(**kwargs)
        try:
            profissional = Professional.objects.get(user=self.request.user)
            context['profissional'] = profissional
        except Professional.DoesNotExist:
            pass
        return context
