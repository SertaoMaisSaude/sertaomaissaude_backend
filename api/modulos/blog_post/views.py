from api.modulos.basicApiView import *
from api.modulos.blog_post.serializers import *


class BlogPostListViewTrue(IsAutenticatedListApiView):
    queryset = BlogPost.objects.all()
    serializer_class = BlogPostListSerializer

    def get_queryset(self):
        query = super().get_queryset().filter(active=True)
        return query



class BlogPostCreateView(IsAutenticatedCreateAPIView):
    serializer_class = BlogPostCreateSerializer


class BlogPostUpdateView(IsAutenticatedUpdateAPIView):
    serializer_class = BlogPostCreateSerializer
