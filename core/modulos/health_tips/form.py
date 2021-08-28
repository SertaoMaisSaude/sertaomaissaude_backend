from django import forms
from core.models import HealthTips
from core.util_manager import adiciona_form_control


class HealthTipsForm(forms.ModelForm):

    class Meta:
        model = HealthTips
        fields = '__all__'

    def __init__(self, *args, **kwargs):        
        
        super(HealthTipsForm, self).__init__(*args, **kwargs)
        adiciona_form_control(self)

    def clean(self):
        cleaned_data = super(HealthTipsForm, self).clean()

        # capacidade_do_tanque = cleaned_data.get('capacidade_do_tanque')
        # if capacidade_do_tanque == 0:
        #     self.add_error('capacidade_do_tanque', u'Capacidade do tanque inválida')