# Generated by Django 3.0.4 on 2020-04-02 00:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0025_auto_20200401_1421'),
    ]

    operations = [
        migrations.AddField(
            model_name='covidcontact',
            name='typeContactCode',
            field=models.CharField(max_length=10, null=True),
        ),
    ]