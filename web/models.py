from django.db import models

class Ticket(models.Model):

    id = models.IntegerField(primary_key=True)
    uid = models.IntegerField()
    phone_number = models.CharField()
    bought_date = models.DateField(auto_now=True)
    used = models.BooleanField(default=False)
    used_date = models.DateField()

    def __str__(self):
        return self.uid