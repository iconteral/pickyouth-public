import datetime
import hashlib
import pytz
import re

import qrcode

from django.utils import timezone
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login
from django.db import connection
from api.models import Ticket

SEAT_REGEX = r'(\w+)(\d+_\d+)'


def check_seat(section, seat):
    with connection.cursor() as cursor:
        cursor.execute("UPDATE tableq{s} SET ypzt=1 WHERE tables='{seat}'".format(
            s=section, seat=seat))


def count_section(section):
    with connection.cursor() as cursor:
        result = cursor.execute(
            "SELECT COUNT(id) FROM tableq{s} WHERE ypzt=1".format(s=section))
        return cursor.fetchone()[0]


def now():
    return datetime.datetime.utcnow().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('Asia/Shanghai')).strftime("%Y-%m-%d %H:%M:%S")


@login_required
def ticket_info(request, password):
    '''
    Return ticket info. but not check in.
    Password allows both password and phone number.
    '''
    data = {}
    if len(password) == 8:
        try:
            ticket = Ticket.objects.get(password=password)
        except:
            data['status'] = 'failed'
            data['message'] = 'password not found.'
            return JsonResponse(data)
    elif len(password) == 11:
        try:
            ticket = Ticket.objects.get(phone_number=password)
        except:
            data['status'] = 'failed'
            data['message'] = 'phone number not found.'
            return JsonResponse(data)
    else:
        data['status'] = 'failed'
        data['message'] = 'given value is not valid'
        return JsonResponse(data)

    data['status'] = 'ok'
    data['message'] = 'ok'
    data['data'] = {
        'password': ticket.password,
        'used_date': ticket.checktime,
        'phone_number': ticket.phone_number,
        'seat1': ticket.t1,
        'seat2': ticket.t2,
        'number': ticket.number,
        'used': 1 if ticket.ypzt == 1 else 0,
    }
    return JsonResponse(data)


@login_required
def check_ticket(request, password):
    '''Check in and mark as checked'''
    data = {}
    try:
        ticket = Ticket.objects.get(password=password)
    except:
        data['status'] = 'failed'
        data['message'] = 'password not found.'
        return JsonResponse(data)

    if ticket.ypzt == 1:
        data['status'] = 'failed'
        data['message'] = 'ticket has already been used.'
    else:
        ticket.ypzt = 1
        ticket.checktime = now()
        ticket.save()
        for i in range(ticket.number):
            t = re.findall(SEAT_REGEX, ticket.__dict__['t'+str(i+1)])[0]
            check_seat(t[0], t[1])
        data['status'] = 'ok'
        data['message'] = 'ticket has been checked successfully.'
    data['data'] = {
        'password': ticket.password,
        'used_date': ticket.checktime,
        'used': 1 if ticket.ypzt == 1 else 0,
        'phone_number': ticket.phone_number,
        'seat1': ticket.t1,
        'seat2': ticket.t2,
        'number': ticket.number,
    }
    return JsonResponse(data)


# @login_required
# def create_ticket(request, phone_number):
#     # 验重
#     while True:
#         password = generate_password()
#         try:
#             Ticket.objects.get(password=password)
#         except:
#             break

#     ticket = Ticket(password=password,
#                     phone_number=phone_number, bought_date=now())
#     ticket.save()
#     data = {
#         'status': 'ok',
#         'message': 'ticked generated.',
#         'data': {
#             'password': password,
#         }
#     }
#     return JsonResponse(data)


# def ticket_image(request, password):

#     try:
#         ticket = Ticket.objects.get(password=password)
#     except:
#         return HttpResponse('ticket not found.')

#     img = qrcode.make(password)

#     response = HttpResponse(content_type="image/jpeg")
#     img.save(response, 'JPEG')
#     return response


def api_login(request):
    username = request.POST['username']
    password = request.POST['password']
    user = authenticate(request, username=username, password=password)
    if user is not None:
        login(request, user)
        return HttpResponse('ok')
    else:
        return HttpResponse('wrong.')


@login_required
def used_count(request):
    '''return entry people number'''
    data = {}
    for section in ['vip', 'b', 'c', 'd', 'e', 'f']:
        data[section] = count_section(section)
    return JsonResponse(data)


# @login_required
# def used(request):
#     '''post back used ticket list and sort by date'''
#     tickets = Ticket.objects.all().filter(used=1)
#     data = []
#     times = []
#     for ticket in tickets:
#         times.append(ticket.used_date)
#     times.sort()
#     for t in times:
#         data.append(tickets.filter(used_date=t).get().password)
#     return JsonResponse(data, safe=False)
