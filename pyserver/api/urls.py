from django.urls import path

from . import views

urlpatterns = [
    path('ticket/<str:uid>', views.ticket_info, name='ticket_info'),
    path('ticket/check/<str:uid>', views.check_ticket, name='check_ticket'),
    path('ticket/create/<str:phone_number>', views.create_ticket, name='create_ticket'),
    path('ticket/img/<str:uid>', views.ticket_image, name='ticket_image'),
    path('login', views.api_login, name='login'),
    path('ticket/used_count', views.used_count, name='used_count')
    path('ticket/used', views.used, name='used')
]