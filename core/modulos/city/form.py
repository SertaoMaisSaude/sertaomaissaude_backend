from django import forms
from core.models import City
from core.util_manager import adiciona_form_control


class CityForm(forms.ModelForm):
    class Meta:
        model = City
        fields = '__all__'
        exclude =('latLng', )

    def __init__(self, *args, **kwargs):
        super(CityForm, self).__init__(*args, **kwargs)
        adiciona_form_control(self)

    def clean(self):
        cleaned_data = super(CityForm, self).clean()

        # capacidade_do_tanque = cleaned_data.get('capacidade_do_tanque')
        # if capacidade_do_tanque == 0:
        #     self.add_error('capacidade_do_tanque', u'Capacidade do tanque inválida')