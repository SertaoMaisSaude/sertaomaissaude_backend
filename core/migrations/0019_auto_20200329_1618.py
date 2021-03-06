# Generated by Django 3.0.4 on 2020-03-29 19:18

import core.util_manager
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0018_auto_20200327_1807'),
    ]

    operations = [
        migrations.RenameField(
            model_name='citizen',
            old_name='phoneMumber',
            new_name='phoneNumber',
        ),
        migrations.AlterField(
            model_name='citizen',
            name='otherRiskGroup',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
        migrations.AlterField(
            model_name='city',
            name='name',
            field=models.CharField(max_length=255, verbose_name='Nome'),
        ),
        migrations.AlterField(
            model_name='dailynewsletter',
            name='city',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='dailyNewsletters', to='core.City', verbose_name='Cidade'),
        ),
        migrations.AlterField(
            model_name='dailynewsletter',
            name='confirmed',
            field=models.IntegerField(verbose_name='Casos Confirmados'),
        ),
        migrations.AlterField(
            model_name='dailynewsletter',
            name='deaths',
            field=models.IntegerField(verbose_name='Óbitos'),
        ),
        migrations.AlterField(
            model_name='dailynewsletter',
            name='recovered',
            field=models.IntegerField(verbose_name='Casos Recuperados'),
        ),
        migrations.AlterField(
            model_name='dailynewsletter',
            name='underInvestigation',
            field=models.IntegerField(verbose_name='Casos Notificados'),
        ),
        migrations.AlterField(
            model_name='dailynewsletter',
            name='waiting_exam',
            field=models.IntegerField(verbose_name='Casos Aguardando Exame'),
        ),
        migrations.AlterField(
            model_name='healthtips',
            name='body',
            field=models.TextField(verbose_name='Conteúdo'),
        ),
        migrations.AlterField(
            model_name='healthtips',
            name='photo',
            field=models.FileField(blank=True, null=True, upload_to=core.util_manager.createPathPhotoHealthTips, verbose_name='Foto'),
        ),
        migrations.AlterField(
            model_name='healthtips',
            name='title',
            field=models.CharField(max_length=255, verbose_name='Tìtulo'),
        ),
        migrations.AlterField(
            model_name='professional',
            name='name',
            field=models.CharField(max_length=255, verbose_name='Nome'),
        ),
        migrations.AlterField(
            model_name='professional',
            name='typeProfessional',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='professional', to='core.TypeProfessional', verbose_name='Tipo de Profissional'),
        ),
    ]
