# Generated by Django 3.0.4 on 2020-03-25 03:58

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0011_auto_20200325_0344'),
    ]

    operations = [
        migrations.AlterField(
            model_name='healthcenter',
            name='latLng',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.PROTECT, to='core.LatLng'),
            preserve_default=False,
        ),
    ]