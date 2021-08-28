from django import forms
from core.models import DailyNewsLetter, City
from core.util_manager import adiciona_form_control




class DailyNewsLetterForm(forms.ModelForm):
    
    
    
    class Meta:
        model = DailyNewsLetter
        fields = '__all__'
        exclude = ('date',)
        

    def __init__(self, *args, **kwargs):   
           
        super(DailyNewsLetterForm, self).__init__(*args, **kwargs)

        adiciona_form_control(self)

    def clean(self):
        
        cleaned_data = super(DailyNewsLetterForm, self).clean()
        print(self)
        # capacidade_do_tanque = cleaned_data.get('capacidade_do_tanque')
        # if capacidade_do_tanque == 0:
        #     self.add_error('capacidade_do_tanque', u'Capacidade do tanque inválida')