import uuid
import datetime
import hashlib

import qrcode

from django.utils import timezone
from django.http import HttpResponse, JsonResponse

from api.models import Ticket

def generate_uid():
    u = ''.join([str(f) for f in uuid.uuid4().fields])
    u += str(timezone.now())
    u += 'pickyouth'
    return hashlib.sha224(u.encode('utf-8')).hexdigest()

def ticket_info(request, uid):
    data = {}
    try:
        ticket = Ticket.objects.get(uid=uid)
    except DoesNotExist:
        data['status'] = 'failed'
        data['message'] = 'uid not found.'
        return JsonResponse(data)
    
    data['status'], data['message'] = 'ok'
    data['data'] = {
        'uid': ticket.uid,
        'bought_date': ticket.bought_date,
        'phone_number': ticket.phone_number,
        'used': ticket.used,
        'used_date': ticket.used_date,
    }

    return JsonResponse(data)

def check_ticket(request, uid):
    data = {}
    try:
        ticket = Ticket.objects.get(uid=uid)
    except DoesNotExist:
        data['status'] = 'failed'
        data['message'] = 'uid not found'
        return JsonResponse(data)
    
    if ticket.used:
        data['status'] = 'failed'
        data['message'] = 'ticket has already been used.'
    else:
        ticket.used = True
        ticket.used_date = timezone.now()
        ticket.save()
        data['status'] = 'ok'
        data['message'] = 'ticket has been checked successfully.'
    return JsonResponse

def create_ticket(request, phone_number):
    # 验重
    while True:
        uid = generate_uid()
        if Ticket.objects.get(uid=uid).length == 0:
            break
    
    ticket = Ticket(uid=uid, phone_number=phone_number)
    ticket.save()
    data = {
        'status': 'ok',
        'message': 'ticked generated.',
        'data': {
            'uid': uid
        }
    }

def ticket_image(request, uid):
    
    try:
        ticket = Ticket.objects.get(uid=uid)
    except DoesNotExist:
        return HttpResponse('ticket not found.')
    
    img = qrcode.make(uid)

    return HttpResponse(img, content_type="image/jpeg")
    