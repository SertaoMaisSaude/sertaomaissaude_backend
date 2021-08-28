# Generated by Django 3.0.4 on 2020-05-07 20:32

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0058_professional_city'),
    ]

    operations = [
        migrations.AlterField(
            model_name='professional',
            name='city',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.PROTECT, related_name='Cidade', to='core.City'),
        ),
    ]
