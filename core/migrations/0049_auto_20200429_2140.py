# Generated by Django 3.0.4 on 2020-04-30 00:40

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0048_auto_20200429_2135'),
    ]

    operations = [
        migrations.RenameField(
            model_name='typeprofessional',
            old_name='listGroups',
            new_name='userGroup',
        ),
    ]
