from django.urls import path

from . import views

urlpatterns = [
    path('ticket/<str:password>', views.ticket_info,
         name='ticket_info'),   # passwd or phone number
    path('ticket/check/<str:password>', views.check_ticket, name='check_ticket'),
    # path('ticket/create/<str:phone_number>', views.create_ticket, name='create_ticket'),
    # path('ticket/img/<str:password>', views.ticket_image, name='ticket_image'),
    path('login', views.api_login, name='login'),
    path('ticket/info/used_count', views.used_count, name='used_count'),
    # path('ticket/info/used', views.used, name= 'used')
    path('return', views.return_seat, name="return_seat"),
]
