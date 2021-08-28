# Generated by Django 3.0.4 on 2020-04-30 00:35

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('auth', '0011_update_proxy_permissions'),
        ('core', '0047_typeprofessional_listgroups'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='typeprofessional',
            name='listGroups',
        ),
        migrations.AddField(
            model_name='typeprofessional',
            name='listGroups',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.PROTECT, to='auth.Group', verbose_name='Grupos'),
            preserve_default=False,
        ),
    ]