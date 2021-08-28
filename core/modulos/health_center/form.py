from django import forms
from django.contrib.auth.models import User

from core.models import HealthCenter, Professional
from core.util_manager import adiciona_form_control


class HealthCenterForm(forms.ModelForm):

    lat = forms.CharField(label="Latitude", widget=forms.TextInput(attrs={'class': 'form-control'}))
    lng = forms.CharField(label="Longitude", widget=forms.TextInput(attrs={'class': 'form-control'}))
    
    
   
    class Meta:
        model = HealthCenter
        fields = '__all__'
        exclude = ('latLng',)
        

    def __init__(self, *args, **kwargs):
        super(HealthCenterForm, self).__init__(*args, **kwargs)   

        instance = self.instance

        
        self.fields['listProfessional'].queryset = Professional.objects.filter(active = True)

        if instance.id != None:
            self.fields['lat'].initial = instance.latLng.lat
            self.fields['lng'].initial = instance.latLng.lng

        adiciona_form_control(self)

    def clean(self):
        cleaned_data = super(HealthCenterForm, self).clean()
            