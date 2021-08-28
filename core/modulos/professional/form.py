from django import forms
from django.contrib.auth.models import User

from core.models import Professional
from core.util_manager import adiciona_form_control


class ProfessionalForm(forms.ModelForm):
    username = forms.CharField(label="Usuário", widget=forms.TextInput(attrs={'class': 'form-control'}))
    # password = forms.CharField(label="Senha", widget=forms.PasswordInput(attrs={'class': 'form-control'}))
    # confirmePassword = forms.CharField(label="Confirme Senha", widget=forms.PasswordInput(attrs={'class': 'form-control'}))
    class Meta:
        model = Professional
        fields = '__all__'
        exclude = ('user',)
 
    def __init__(self, *args, **kwargs):
        super(ProfessionalForm, self).__init__(*args, **kwargs)
        print(kwargs)

        instance = self.instance
        print('instance', instance.id)
        if instance.id != None:
            self.fields['username'].initial = instance.user.username
            # self.fields['password'].required = False
            # self.fields['confirmePassword'].required = False
        adiciona_form_control(self)

    def clean(self):
        if self.is_valid():
            instance = self.instance
            cleaned_data = super(ProfessionalForm, self).clean()
            username = cleaned_data.get('username')
            phoneNumber = cleaned_data.get('phoneNumber')

            if len(phoneNumber) < 8:
                self.add_error('phoneNumber', u'Número de telefone inválido')
            # password = cleaned_data.get('password')
            # confirmePassword = cleaned_data.get('confirmePassword')
            # if instance.id != None:
            #     if instance.user.username != username:
            #         if User.objects.filter(username=username.strip()).exists():
            #             self.add_error('username', u'Nome de Usuário já existe')
            #     if (len(password) > 0 or len(confirmePassword) > 0):
            #         if password.strip() != confirmePassword.strip():
            #             self.add_error('confirmePassword', u'Senhas diferentes')
            # else:
            #     if User.objects.filter(username=username.strip()).exists():
            #         self.add_error('username', u'Nome de Usuário já existe')
            #     if password.strip() != confirmePassword.strip():
            #         self.add_error('confirmePassword', u'Senhas diferentes')

            