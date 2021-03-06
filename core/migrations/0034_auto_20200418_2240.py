# Generated by Django 3.0.4 on 2020-04-19 01:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0033_auto_20200418_2211'),
    ]

    operations = [
        migrations.AddField(
            model_name='citizen',
            name='neighborhood',
            field=models.CharField(blank=True, max_length=255, null=True, verbose_name='Bairro'),
        ),
        migrations.AddField(
            model_name='citizen',
            name='street',
            field=models.CharField(blank=True, max_length=255, null=True, verbose_name='Rua'),
        ),
        migrations.AddField(
            model_name='citizen',
            name='street_number',
            field=models.CharField(blank=True, max_length=255, null=True, verbose_name='Número'),
        ),
    ]
