# Generated by Django 4.2.10 on 2024-03-13 14:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('documents', '0008_alter_orders_number_alter_orders_site_status'),
    ]

    operations = [
        migrations.AlterField(
            model_name='orders',
            name='number',
            field=models.CharField(blank=True, default='', max_length=64, null=True, verbose_name='Номер'),
        ),
    ]
