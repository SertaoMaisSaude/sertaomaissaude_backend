from django import forms

STATUS = [
    ('Não Iniciado', 'Não Iniciado'),
    ('Em Análise', 'Em Análise'),
    ('Atendimento Realizado', 'Atendimento Realizado'),
]
SITUACOES = [
    ('Sem Situação', 'Sem Situação'),
    ('Bem de saúde', 'Bem de saúde'),
    ('Recuperando em Casa', 'Recuperando em Casa'),
    ('Recuperando em Hospital', 'Recuperando em Hospital'),
    ('Recuperada', 'Recuperada'),
    ('Óbito', 'Óbito'),
]


class StatusForm(forms.Form):
    status = forms.MultipleChoiceField(
        required=True,
        widget=forms.Select,
        choices=STATUS,
    )
    status.widget.attrs["class"] = "form-control w-100 mb-0"

class SituacoesForm(forms.Form):
    situacao = forms.MultipleChoiceField(
        required=True,
        widget=forms.Select,
        choices=SITUACOES,
    )
    situacao.widget.attrs["class"] = "form-control w-100 mb-0"