# Generated by Django 2.2.2 on 2019-06-13 01:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='ticket',
            name='bought_date',
            field=models.DateTimeField(auto_now=True),
        ),
        migrations.AlterField(
            model_name='ticket',
            name='uid',
            field=models.CharField(max_length=200),
        ),
        migrations.AlterField(
            model_name='ticket',
            name='used_date',
            field=models.DateTimeField(null=True),
        ),
    ]
