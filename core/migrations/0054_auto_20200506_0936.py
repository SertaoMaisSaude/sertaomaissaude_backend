# Generated by Django 3.0.4 on 2020-05-06 12:36

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0053_auto_20200506_0935'),
    ]

    operations = [
        migrations.RenameField(
            model_name='blogpost',
            old_name='activeStatus',
            new_name='active',
        ),
        migrations.RenameField(
            model_name='city',
            old_name='activeStatus',
            new_name='active',
        ),
        migrations.RenameField(
            model_name='healthcenter',
            old_name='activeStatus',
            new_name='active',
        ),
        migrations.RenameField(
            model_name='healthtips',
            old_name='activeStatus',
            new_name='active',
        ),
        migrations.RenameField(
            model_name='professional',
            old_name='activeStatus',
            new_name='active',
        ),
    ]
