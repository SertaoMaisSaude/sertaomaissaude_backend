# Generated by Django 3.0.4 on 2020-04-28 12:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0044_healthcenter_coverage'),
    ]

    operations = [
        migrations.AlterField(
            model_name='citizen',
            name='listHealthCenter',
            field=models.ManyToManyField(blank=True, null=True, to='core.HealthCenter', verbose_name='Centros de Saúde'),
        ),
    ]
