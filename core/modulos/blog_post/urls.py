from django.urls import path

from core.modulos.blog_post import views

app_name = 'blog_post'
urlpatterns = [
    path('', views.BlogPostListView.as_view(), name='list_view'),
    path('create', views.BlogPostCreateView.as_view(), name='create_view'),
    path('update/<int:pk>', views.BlogPostUpdateView.as_view(), name='update_view'),
]
