# Generated by Django 3.0.4 on 2020-05-07 05:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0056_auto_20200506_1056'),
    ]

    operations = [
        migrations.AlterField(
            model_name='typeprofessional',
            name='codeDocumentType',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
    ]
