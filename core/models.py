import os
from datetime import datetime

from django.contrib.auth.models import User, Group
from django.db import models

# ****
from core.util_manager import createPathPhotoHealthTips, createPathPhotoLogPost, createPathAppVersion, createPathPhotoTeamMember

SEX_CHOICES = [
    ["F", "Feminino"],
    ["M", "Masculino"],

]


class LatLng(models.Model):
    lat = models.CharField(max_length=255, verbose_name='Latitude')
    lng = models.CharField(max_length=255, verbose_name='Longitude')

    def __str__(self):
        return 'LAT: ${} - LNG: {}'.format(self.lat, self.lng)

    def getJson(self):
        return dict(
            id=self.pk,
            lat=self.lat,
            lng=self.lng,
        )


# ****
class City(models.Model):
    name = models.CharField(max_length=255, verbose_name='Cidade')
    latLng = models.ForeignKey(LatLng, on_delete=models.PROTECT, null=True, blank=True, related_name='cities')
    
    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")

    def __str__(self):
        return self.name

    def getJson(self):
        return dict(
            id=self.pk,
            name=self.name,
        )


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.PROTECT, related_name='userProfile', null=True)
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='usersProfile', null=True)

    def __str__(self):
        return self.user.username


# ****
class DailyNewsLetter(models.Model):
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='dailyNewsletters', verbose_name='Cidade')
    date = models.DateTimeField(default=datetime.now, verbose_name='Data')
    date_publication = models.DateTimeField(verbose_name='Data de Publicação', null=True, blank=True)
    discarded = models.IntegerField(verbose_name='Casos Descartados')
    underInvestigation = models.IntegerField(verbose_name='Casos em Investigação')
    waiting_exam = models.IntegerField(verbose_name='Casos Aguardando Exame')
    confirmed = models.IntegerField(verbose_name='Casos Confirmados')
    recovered = models.IntegerField(verbose_name='Casos Curados')
    deaths = models.IntegerField(verbose_name='Óbitos')

    homeIsolation = models.IntegerField(default=0, verbose_name="Isolamento Domiciliar")
    hospitalStay = models.IntegerField(default=0, verbose_name="Internamento Hospitalar")

    testsCounty = models.IntegerField(default=0, verbose_name="Exames - Laboratório Municipal")
    testsLacen = models.IntegerField(default=0, verbose_name="Exames - Lacen Pernambuco")
    testsPrivate = models.IntegerField(default=0, verbose_name="Exames - Particulares")
    
    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")

    class Meta:
        ordering = ['-date_publication', '-date']


# ****
class TypeProfessional(models.Model):
    name = models.CharField(max_length=255)
    codeDocumentType = models.CharField(max_length=50, null=True, blank=True)
    userGroup = models.ForeignKey(Group, verbose_name='Grupos', on_delete=models.PROTECT)

    def __str__(self):
        return '{} - {}'.format(self.name, self.codeDocumentType)


# ****
class Professional(models.Model):
    user = models.OneToOneField(User, on_delete=models.PROTECT, related_name='professional', blank=True, null=True)
    typeProfessional = models.ForeignKey(TypeProfessional, on_delete=models.PROTECT, related_name='professional', verbose_name='Tipo de Profissional')
    name = models.CharField(max_length=255, verbose_name='Nome')
    phoneNumber = models.CharField(max_length=20, blank=False, null=False, verbose_name='Telefone')
    email = models.CharField(max_length=100, blank=True, null=True, verbose_name='E-mail')
    firstAccess = models.BooleanField(default=True)
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='city', blank=False, null=True, verbose_name='Cidade')
    
    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")

    def __str__(self):
        return self.name

    @property
    def login(self):
        return self.user.username

    @property
    def senha(self):
        return ''


# *****
class HealthCenter(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['neighborhood']),
        ]

    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='healthsCenter', verbose_name='Cidade')
    latLng = models.ForeignKey(LatLng, on_delete=models.PROTECT, null=True, blank=True)
    name = models.CharField(max_length=255, verbose_name='Nome')
    street = models.CharField(max_length=255, verbose_name='Rua')
    street_number = models.CharField(max_length=255, verbose_name='Número')
    neighborhood = models.CharField(max_length=255, verbose_name='Bairro')
    phone_number = models.CharField(max_length=255, verbose_name='Telefone', blank=True, null = True)
    listProfessional = models.ManyToManyField(Professional, verbose_name='Profissionais')
    coverage = models.CharField(max_length=255, verbose_name='Cobertura', blank=True, null = True)

    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")


    def getJsonCustom(self):
        return dict(
            id=self.pk,
            name=self.name,
        )
    
    def __str__(self):
        return self.name


# ****
class RiskGroup(models.Model):
    name = models.CharField(max_length=255)

    def __str__(self):
        return self.name

    def getJson(self):
        return dict(
            id=self.pk,
            name=self.name,
        )


# ***
class Citizen(models.Model):
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='citizens')
    userProfile = models.OneToOneField(UserProfile, on_delete=models.PROTECT, null=True, blank=True, related_name='citizen')
    listRiskGroup = models.ManyToManyField(RiskGroup, blank=True, related_name='citizens')
    otherRiskGroup = models.CharField(max_length=255, null=True, blank=True)
    name = models.CharField(max_length=255, null=True, blank=True)
    age = models.IntegerField(null=True, blank=True)
    sex = models.CharField(max_length=1, null=True, blank=True, choices=SEX_CHOICES)
    phoneNumber = models.CharField(max_length=20)
    cep = models.CharField(max_length=8, null=True, blank=True)
    street = models.CharField(max_length=255, verbose_name='Rua', null=True, blank=True)
    street_number = models.CharField(max_length=255, verbose_name='Número', null=True, blank=True)
    neighborhood = models.CharField(max_length=255, verbose_name='Bairro', null=True, blank=True)
    healthCenter = models.ForeignKey(HealthCenter, verbose_name='Centro de Saúde', null=True, blank=True, on_delete=models.PROTECT)

    def __str__(self):
        return self.name
    def getJson(self):
        return dict(
            id=self.pk,
            city_id=self.city.id,
            listRiskGroup_ids=[dado.id for dado in self.listRiskGroup.all()],
            otherRiskGroup=self.otherRiskGroup,
            name=self.name,
            age=self.age,
            sex=self.sex,
            phoneNumber=self.phoneNumber,
            cep=self.cep,
            street=self.street,
            street_number=self.street_number,
            neighborhood=self.neighborhood,

        )


# ***
class CovidContact(models.Model):
    description = models.CharField(max_length=255, blank=True, null=True)
    typeContactCode = models.CharField(max_length=10, null=True)
    active = models.BooleanField(default=True)

    def __str__(self):
        return self.description

    def getJson(self):
        return dict(
            id=self.pk,
            description=self.description,
            typeContactCode=self.typeContactCode,
            active=self.active,
        )


# ****
class CategorySympton(models.Model):
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, null=True)

    def __str__(self):
        return self.name

    def getJson(self):
        return dict(
            id=self.pk,
            name=self.name,
            description=self.description,
        )


# ***
class Sympton(models.Model):
    category = models.ForeignKey(CategorySympton, on_delete=models.PROTECT, related_name='symptoms')
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.name

    def getJson(self):
        return dict(
            id=self.pk,
            category_id=self.category.id,
            name=self.name,
            description=self.description,
        )


# ***
class Analisy(models.Model):
    citizen = models.ForeignKey(Citizen, on_delete=models.PROTECT, related_name='analyses')
    covidContact = models.ForeignKey(CovidContact, on_delete=models.PROTECT, related_name='analyses')
    date = models.DateTimeField(default=datetime.now)
    has_faver = models.BooleanField(default=False)
    fever = models.DecimalField(max_digits=3, decimal_places=1, null=True, blank=True)

    latLng = models.ForeignKey(LatLng, on_delete=models.PROTECT, null=True, blank=True, related_name='analyses')
    listSympton = models.ManyToManyField(Sympton, blank=True, related_name='analyses')
    otherSympton = models.CharField(max_length=255, null=True, blank = True)
    teleatend_status = models.CharField(max_length=255, verbose_name='Status de Teleatendimento', default='Não Iniciado')
    patient_situation = models.CharField(max_length=255, verbose_name='Situação do Paciente', default='Sem Situação')


    def getJson(self):
        return dict(
            id=self.pk,
            citizen_id=self.citizen.id,
            covid_contact_id=self.covidContact.id,
            date=self.date,
            has_faver=self.has_faver,
            fever=self.fever,
            latLng=self.latLng.id if self.latLng else "",
            listSympton_ids=[dado.id for dado in self.listSympton.all()]
        )


# ****
class Disease(models.Model):
    name = models.CharField(max_length=255)
    description = models.CharField(max_length=255, blank=True, null=True)
    listSympton = models.ManyToManyField(Sympton)

    def __str__(self):
        return self.name


# ***
class RiskAnalisy(models.Model):
    analisy = models.ForeignKey(Analisy, on_delete=models.PROTECT, related_name='risksAnalisy')
    disease = models.ForeignKey(Disease, on_delete=models.PROTECT, related_name='diseases')


class HealthTips(models.Model):
    title = models.CharField(max_length=255, verbose_name='Tìtulo')
    body = models.TextField(verbose_name='Conteúdo')
    photo = models.FileField(upload_to=createPathPhotoHealthTips, blank=True, null=True, verbose_name='Imagem')
    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='city_tips', blank=True, null=True, verbose_name='Cidade')


class BlogPost(models.Model):
    postDate = models.DateTimeField(default=datetime.now)
    title = models.CharField(max_length=255, verbose_name='Título')
    body = models.TextField(verbose_name='Conteúdo')
    photo = models.FileField(upload_to=createPathPhotoLogPost, blank=True, null=True, verbose_name='Imagem')

    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")
    city = models.ForeignKey(City, on_delete=models.PROTECT, related_name='city_blog', blank=True, null=True, verbose_name='Cidade')

    class Meta:
            ordering = ['-postDate']

class AppVersion(models.Model):
    version = models.CharField(max_length=100, verbose_name='Versão')
    active = models.BooleanField(default=True, null=False, verbose_name="Ativo")
    fileVersion = models.FileField(upload_to=createPathAppVersion, blank=False, null=False, verbose_name='App')

    class Meta:
        ordering = ['-version']


class TeamMember(models.Model):
    name = models.CharField(max_length=100, verbose_name='Nome')
    email = models.CharField(max_length=100, verbose_name='E-mail')
    phoneNumber = models.CharField(max_length=15, verbose_name='Telefone')
    resume = models.CharField(max_length=1000, verbose_name='Resumo')
    photo = models.FileField(upload_to=createPathPhotoTeamMember, blank=True, null=True, verbose_name='Imagem')
    
class Partner(models.Model):
    name = models.CharField(max_length=100, verbose_name='Nome')
    email = models.CharField(max_length=100, verbose_name='E-mail')
    phoneNumber = models.CharField(max_length=15, verbose_name='Telefone')
    resume = models.CharField(max_length=1000, verbose_name='Resumo')
    photo = models.FileField(upload_to=createPathPhotoTeamMember, blank=True, null=True, verbose_name='Imagem')

class Team(models.Model):
    teamMembers = models.ManyToManyField(TeamMember, blank=True, related_name='team_members', verbose_name='Membros da equipe')
    partners = models.ManyToManyField(Partner, blank=True, related_name='partners', verbose_name='Parceiros')
