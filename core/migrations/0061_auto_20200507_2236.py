# Generated by Django 3.0.4 on 2020-05-08 01:36

import core.util_manager
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0060_auto_20200507_1734'),
    ]

    operations = [
        migrations.CreateModel(
            name='Partner',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100, verbose_name='Nome')),
                ('email', models.CharField(max_length=100, verbose_name='E-mail')),
                ('phoneNumber', models.CharField(max_length=15, verbose_name='Telefone')),
                ('resume', models.CharField(max_length=1000, verbose_name='Resumo')),
                ('photo', models.FileField(blank=True, null=True, upload_to=core.util_manager.createPathPhotoTeamMember, verbose_name='Imagem')),
            ],
        ),
        migrations.CreateModel(
            name='TeamMember',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100, verbose_name='Nome')),
                ('email', models.CharField(max_length=100, verbose_name='E-mail')),
                ('phoneNumber', models.CharField(max_length=15, verbose_name='Telefone')),
                ('resume', models.CharField(max_length=1000, verbose_name='Resumo')),
                ('photo', models.FileField(blank=True, null=True, upload_to=core.util_manager.createPathPhotoTeamMember, verbose_name='Imagem')),
            ],
        ),
        migrations.AddField(
            model_name='blogpost',
            name='city',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='city_blog', to='core.City', verbose_name='Cidade'),
        ),
        migrations.AddField(
            model_name='healthtips',
            name='city',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='city_tips', to='core.City', verbose_name='Cidade'),
        ),
        migrations.CreateModel(
            name='Team',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('partners', models.ManyToManyField(blank=True, related_name='partners', to='core.Partner', verbose_name='Parceiros')),
                ('teamMembers', models.ManyToManyField(blank=True, related_name='team_members', to='core.TeamMember', verbose_name='Membros da equipe')),
            ],
        ),
    ]
