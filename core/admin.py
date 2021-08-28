from django.contrib import admin


# Register your models here.
from core.models import *

admin.site.register(City)
admin.site.register(UserProfile)
admin.site.register(DailyNewsLetter)
admin.site.register(TypeProfessional)
admin.site.register(Professional)
admin.site.register(HealthCenter)
admin.site.register(RiskGroup)

class CitizenAdmin(admin.ModelAdmin):
    list_display = ("name", "healthCenter")

admin.site.register(Citizen, CitizenAdmin)

admin.site.register(CovidContact)

admin.site.register(CategorySympton)
admin.site.register(Sympton)

class AnalisyAdmin(admin.ModelAdmin):
    list_display = ("citizen", "covidContact", "has_faver", "symptons")
    
    list_filter = ["covidContact", "has_faver" , "listSympton"]

    def symptons(self, obj):
        return "\n".join([obj.name for obj in obj.listSympton.all()])


admin.site.register(Analisy, AnalisyAdmin)


admin.site.register(Disease)
admin.site.register(HealthTips)
admin.site.register(RiskAnalisy)
admin.site.register(LatLng)
admin.site.register(BlogPost)


