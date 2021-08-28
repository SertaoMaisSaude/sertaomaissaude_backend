from django.db import models
from datetime import datetime

# Create your models here.
from core.models import Citizen, City, Professional
from core.util_manager import createPathPhotoHealthTips, createPathMessageFile


class Timestampable(models.Model):
    date = models.DateTimeField(auto_now_add=True)
    date_last_modification = models.DateTimeField(auto_now=True, null=True)

    class Meta:
        abstract = True


class Chat(models.Model):
    citizen = models.ForeignKey(Citizen, on_delete=models.PROTECT, related_name='chats')
    professional = models.ForeignKey(Professional, on_delete=models.PROTECT, related_name='chats')
    active = models.BooleanField(default=True)
    date = models.DateTimeField(auto_now_add=True)


class Message(Timestampable):
    chat = models.ForeignKey(Chat, on_delete=models.PROTECT, related_name='messages')
    message = models.TextField()
    file = models.FileField(upload_to=createPathMessageFile, blank=True, null=True, verbose_name='File')
    received = models.BooleanField(default=False)
    is_professional = models.BooleanField(default=False)


class Patient(Timestampable):
    citizen = models.OneToOneField(Citizen, on_delete=models.PROTECT, related_name='patient')
    cpf = models.CharField('CPF', max_length=50, null=True, blank=True)
    sus_code = models.CharField('CPF', max_length=50, null=True, blank=True)
    status = models.CharField('CPF', max_length=50, null=True, blank=True)


class Prontuario(Timestampable):
    citizen = models.OneToOneField(Citizen, on_delete=models.PROTECT, related_name='prontuarios')
    professional = models.ForeignKey(Professional, on_delete=models.PROTECT, related_name='prontuarios')
