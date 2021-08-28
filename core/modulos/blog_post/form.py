from django import forms
from core.models import BlogPost, Professional, HealthCenter
from core.util_manager import adiciona_form_control


class BlogPostForm(forms.ModelForm):
    class Meta:
        model = BlogPost
        fields = '__all__'
        exclude = ('postDate',)

    def __init__(self, *args, **kwargs):
        super(BlogPostForm, self).__init__(*args, **kwargs)
        adiciona_form_control(self)

    def clean(self):
        cleaned_data = super(BlogPostForm, self).clean()
