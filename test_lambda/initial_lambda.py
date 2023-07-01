import json


def os_config_initialise():
    return "Hello, world, from terraform"


def handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(os_config_initialise())
    }
