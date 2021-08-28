# Generated by Django 3.0.4 on 2020-05-06 12:35

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0052_auto_20200506_0927'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='blogpost',
            name='active',
        ),
        migrations.RemoveField(
            model_name='city',
            name='active',
        ),
        migrations.RemoveField(
            model_name='dailynewsletter',
            name='active',
        ),
        migrations.RemoveField(
            model_name='healthcenter',
            name='active',
        ),
        migrations.RemoveField(
            model_name='healthtips',
            name='active',
        ),
        migrations.RemoveField(
            model_name='professional',
            name='active',
        ),
        migrations.AddField(
            model_name='blogpost',
            name='activeStatus',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
        migrations.AddField(
            model_name='city',
            name='activeStatus',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
        migrations.AddField(
            model_name='dailynewsletter',
            name='activeStatus',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
        migrations.AddField(
            model_name='healthcenter',
            name='activeStatus',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
        migrations.AddField(
            model_name='healthtips',
            name='activeStatus',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
        migrations.AddField(
            model_name='professional',
            name='activeStatus',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
        migrations.AlterField(
            model_name='appversion',
            name='active',
            field=models.BooleanField(default=True, verbose_name='Ativo'),
        ),
    ]