import datetime

def lambda_handler(event, context):
    now = datetime.datetime.now()
    print(now.strftime('%m-%d-%y %H:%M:%S'))
    return "Lambda Ejecutado Correctamente"