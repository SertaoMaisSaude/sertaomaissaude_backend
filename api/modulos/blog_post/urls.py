from django.urls import path

from api.modulos.blog_post.views import *

urlpatterns = [
    path("list/", BlogPostListViewTrue.as_view(), name="types_professional_list"),
    path("create/", BlogPostCreateView.as_view(), name="types_professional_create"),
    # path("update/<int:pk>", BlogPostUpdateView.as_view(), name="types_professional_update"),
]
