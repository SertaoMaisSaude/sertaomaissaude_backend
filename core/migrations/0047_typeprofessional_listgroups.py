# Generated by Django 3.0.4 on 2020-04-30 00:32

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('auth', '0011_update_proxy_permissions'),
        ('core', '0046_auto_20200428_1146'),
    ]

    operations = [
        migrations.AddField(
            model_name='typeprofessional',
            name='listGroups',
            field=models.ManyToManyField(to='auth.Group', verbose_name='Grupos'),
        ),
    ]
