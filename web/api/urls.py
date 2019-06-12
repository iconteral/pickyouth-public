
from django.urls import path

from . import views

urlpatterns = [
    path('ticket/<int:uid>', views.ticket_info, name='ticket_info'),
    path('ticket/check/<int:uid>', views.check_ticket, name='check_ticket'),
]
