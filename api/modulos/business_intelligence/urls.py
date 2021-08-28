from django.urls import path, re_path

from api.modulos.business_intelligence.views import MapeamentoBI

urlpatterns = [
    re_path("smart_data_mapping_bi_date_range/(?P<data>\d{2}-\d{2}-\d{4})", MapeamentoBI.as_view(), name="smart_data_mapping_bi_date_range"),
]
