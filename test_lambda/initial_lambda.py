import json
import logging


def os_config_initialise():
    print("testing how logging works, no logging")
    logging.debug("with logging library")
    return "Hello, world, from terraform"


def handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(os_config_initialise())
    }
