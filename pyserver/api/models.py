from django.db import models


class Ticket(models.Model):

    id = models.AutoField(primary_key=True)
    phone = models.BigIntegerField()
    password = models.BigIntegerField()
    number = models.IntegerField()
    t1 = models.TextField()
    t2 = models.TextField()
    checktime = models.TextField()
    ypzt = models.IntegerField()

    class Meta:
        db_table = 'ticket'

    def __str__(self):
        return str(self.password)
