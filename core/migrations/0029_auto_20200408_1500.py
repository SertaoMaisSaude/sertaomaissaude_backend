# Generated by Django 3.0.4 on 2020-04-08 18:00

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0028_auto_20200408_1126'),
    ]

    operations = [
        migrations.AlterField(
            model_name='covidcontact',
            name='description',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
        migrations.AlterField(
            model_name='disease',
            name='description',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
        migrations.AlterField(
            model_name='sympton',
            name='description',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
