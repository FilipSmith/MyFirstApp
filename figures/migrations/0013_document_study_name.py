# Generated by Django 2.0.5 on 2018-10-11 11:44

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('figures', '0012_document_variables'),
    ]

    operations = [
        migrations.AddField(
            model_name='document',
            name='study_name',
            field=models.TextField(default='', max_length=30),
            preserve_default=False,
        ),
    ]