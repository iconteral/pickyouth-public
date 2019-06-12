import uuid

import qrcode

def uid():
    return ''.join([str(f) for f in uuid.uuid4().fields])

def generate_qr_code(uid):
    img = qrcode.make(uid)