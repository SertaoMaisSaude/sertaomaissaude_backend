# Generated by Django 3.0.4 on 2020-03-27 21:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0017_healthtips'),
    ]

    operations = [
        migrations.AlterField(
            model_name='analisy',
            name='listSympton',
            field=models.ManyToManyField(blank=True, to='core.Sympton'),
        ),
    ]
