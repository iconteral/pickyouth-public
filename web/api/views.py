import uuid
import datetime
import hashlib
import pytz

import qrcode

from django.utils import timezone
from django.http import HttpResponse, JsonResponse

from api.models import Ticket

def now():
    return datetime.datetime.utcnow().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('Asia/Shanghai'))

def generate_uid():
    u = ''.join([str(f) for f in uuid.uuid4().fields])
    u += str(timezone.now())
    u += 'pickyouth'
    return hashlib.sha224(u.encode('utf-8')).hexdigest()

def ticket_info(request, uid):
    print(now())
    data = {}
    try:
        ticket = Ticket.objects.get(uid=uid)
    except:
        data['status'] = 'failed'
        data['message'] = 'uid not found.'
        return JsonResponse(data)
    
    data['status'] = 'ok'
    data['message'] = 'ok'
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
    except:
        data['status'] = 'failed'
        data['message'] = 'uid not found.'
        return JsonResponse(data)
    print('ok')
    
    if ticket.used:
        data['status'] = 'failed'
        data['message'] = 'ticket has already been used.'
    else:
        ticket.used = True
        ticket.used_date = now()
        ticket.save()
        data['status'] = 'ok'
        data['message'] = 'ticket has been checked successfully.'
    return JsonResponse(data)

def create_ticket(request, phone_number):
    # 验重
    while True:
        uid = generate_uid()
        try:
            Ticket.objects.get(uid=uid)
        except:
            break
    
    ticket = Ticket(uid=uid, phone_number=phone_number, bought_date=now())
    ticket.save()
    data = {
        'status': 'ok',
        'message': 'ticked generated.',
        'data': {
            'uid': uid
        }
    }

    return JsonResponse(data)

def ticket_image(request, uid):
    
    try:
        ticket = Ticket.objects.get(uid=uid)
    except:
        return HttpResponse('ticket not found.')
    
    img = qrcode.make(uid)
    
    response = HttpResponse(content_type="image/jpeg")
    img.save(response, 'JPEG')
    return response
    