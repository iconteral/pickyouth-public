from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import authenticate, login, logout
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def log_in(request):
    username = request.POST['username']
    password = request,POST['password']
    data = {}
    if authenticate(request, username=username, password=password):
        user = authenticate(username=username, password=password)
        login(request, user)
        data['status'] = 'ok'
        data['as'] = username
    else:
        data['Error'] = 'incorrect username/password'
    return JsonResponse(data)

@csrf_exempt
def log_out(request):
    data = {}
    if request.user.is_authenticated:
        logout(request)
        data['status'] = 'ok'
    else:
        data['Error'] = 'not yet login'
    return JsonResponse(data)