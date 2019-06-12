from django.db import models

class Ticket(models.Model):

    id = models.IntegerField(primary_key=True)
    uid = models.IntegerField()
    image_id = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=11)
    bought_date = models.DateTimeField(auto_now=True)
    used = models.BooleanField(default=False)
    used_date = models.DateTimeField(null=True)

    def __str__(self):
        return self.uid