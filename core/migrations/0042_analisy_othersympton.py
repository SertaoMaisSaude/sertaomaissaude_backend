# Generated by Django 3.0.4 on 2020-04-25 17:04

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0041_auto_20200424_1039'),
    ]

    operations = [
        migrations.AddField(
            model_name='analisy',
            name='otherSympton',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]