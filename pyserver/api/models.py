from django.db import models


class Ticket(models.Model):

    id = models.AutoField(primary_key=True)
    phone_number = models.BigIntegerField(max_length=20)
    password = models.BigIntegerField(max_length=20)
    number = models.IntegerField(max_length=11)
    t-1 = models.TextField()
    t-2 = models.TextField()
    checktime = models.TextField()
    ypzt = models.IntegerField(max_length=11)

    def __str__(self):
        return self.uid
