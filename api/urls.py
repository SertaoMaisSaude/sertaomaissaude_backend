from django.urls import path, include

urlpatterns = [
    path("types-professional/", include('api.modulos.type_professional.urls'), name="apiTypesProfessional"),
    path("professional/", include('api.modulos.professional.urls'), name="apiProfessional"),
    path("city/", include('api.modulos.city.urls'), name="apiCity"),
    path("daily-news-letter/", include('api.modulos.daily_news_letter.urls'), name="apiDailyNewsLetter"),
    path("health-center/", include('api.modulos.health_center.urls'), name="apiHealthCenter"),
    path("risk-group/", include('api.modulos.risk_group.urls'), name="apiRiskGroup"),
    path("covid-contact/", include('api.modulos.covid_contact.urls'), name="apiCovidContact"),
    path("category-sympton/", include('api.modulos.category_sympton.urls'), name="apiCategorySympton"),
    path("sympton/", include('api.modulos.sympton.urls'), name="apiSympton"),
    path("citizen/", include('api.modulos.citizen.urls'), name="apiCitizen"),
    path("analisy/", include('api.modulos.analisy.urls'), name="apiAnalisy"),
    path("disease/", include('api.modulos.disease.urls'), name="apiDisease"),
    path("risk-analisy/", include('api.modulos.risk_analisy.urls'), name="apiRiskAnalisy"),
    path("health-tips/", include('api.modulos.health_tips.urls'), name="apiHealthTips"),
    path("blog-post/", include('api.modulos.blog_post.urls'), name="apiBlogPost"),
    path("bi/", include('api.modulos.business_intelligence.urls'), name="apiBI"),
]
