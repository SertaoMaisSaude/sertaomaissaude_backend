# Generated by Django 3.0.4 on 2020-05-05 14:54

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0050_appversion'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='appversion',
            options={'ordering': ['-version']},
        ),
    ]