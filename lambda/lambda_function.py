import json
import boto3
from datetime import datetime
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('AIManagerState')

def lambda_handler(event, context):
    try:
        user_id = event['requestContext']['identity']['cognitoIdentityId']
        command = json.loads(event['body']) if isinstance(event['body'], str) else event['body']
        
        response = table.get_item(Key={'user_id': user_id})
        state = response.get('Item', {}).get('state', {})
        
        if command == "reset":
            table.delete_item(Key={'user_id': user_id})
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'State reset!'})
            }
        
        # Update state with the new command
        state['last_command'] = command
        state['last_interaction'] = datetime.utcnow().isoformat()
        
        table.put_item(Item={
            'user_id': user_id,
            'state': state
        })
        
        response_message = handle_command(command, state)
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': response_message})
        }
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def handle_command(command, state):
    if command == "hi":
        return "Hello! How can I assist you today?"
    elif command == "status":
        return f"Your last command was: {state.get('last_command', 'None')}"
    else:
        return f"Command '{command}' received and stored."
