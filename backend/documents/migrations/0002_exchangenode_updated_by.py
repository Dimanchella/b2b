# Generated by Django 5.0 on 2024-02-13 22:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('documents', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='exchangenode',
            name='updated_by',
            field=models.CharField(default=1234, max_length=128, verbose_name='Источник изменения'),
            preserve_default=False,
        ),
    ]
