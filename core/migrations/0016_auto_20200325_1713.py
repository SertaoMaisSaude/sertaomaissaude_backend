# Generated by Django 3.0.4 on 2020-03-25 17:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0015_auto_20200325_1316'),
    ]

    operations = [
        migrations.AlterField(
            model_name='citizen',
            name='listRiskGroup',
            field=models.ManyToManyField(blank=True, to='core.RiskGroup'),
        ),
    ]
