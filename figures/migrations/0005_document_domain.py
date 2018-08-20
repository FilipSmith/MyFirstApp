# Generated by Django 2.0.5 on 2018-08-14 20:45

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('figures', '0004_auto_20180813_0947'),
    ]

    operations = [
        migrations.AddField(
            model_name='document',
            name='domain',
            field=models.CharField(choices=[('ADAE', 'ADAE'), ('ADSL', 'ADSL'), ('ADVS', 'ADVS'), ('ADLB', 'ADLB'), ('ADEG', 'ADEG')], default='ADSL', max_length=20),
        ),
    ]