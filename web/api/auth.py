def auth(request):
    data = {}
    if request.user.is_authenticated:
        return check_ticket(request, uid)
    else:
        data['Error'] = 'permission denied'
        return JsonResponse(data)