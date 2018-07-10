from __future__ import print_function

import httplib2
import os
import time
import sys

from apiclient import discovery

from oauth2client import tools, client
from oauth2client.file import Storage

import datetime

# try:
#     import argparse
#     flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
# except ImportError:
#     flags = None

# If modifying these scopes, delete your previously saved credentials
# at ~/.credentials/calendar-python-quickstart.json
SCOPES = 'https://www.googleapis.com/auth/calendar'
CLIENT_SECRET_FILE = 'client_id.json'
APPLICATION_NAME = 'Google Calendar API Python Quickstart'

def get_credentials():
    """Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    credential_path = os.path.join(credential_dir,
                                   'calendar.json')

    store = Storage(credential_path)
    credentials = store.get()

    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
        
        flow.user_agent = APPLICATION_NAME
        if flags:
            credentials = tools.run_flow(flow, store, flags)
        else: # Needed only for compatibility with Python 2.6
            credentials = tools.run(flow, store)
        print('Storing credentials to ' + credential_path)
    return credentials

def search_event(LONG_VER, COMMENT):
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('calendar', 'v3', http=http)
    # First retrieve the event from the API.

    now = (datetime.datetime.utcnow() - datetime.timedelta(days=2)).isoformat() + 'Z' # 'Z' indicates UTC time
    # print('Searching the recent events from 2day ago')
    eventsResult = service.events().list(
        calendarId='mn01riqketee7iojqjmnn4kl78@group.calendar.google.com', timeMin=now, maxResults=20, singleEvents=True,
        orderBy='startTime').execute()
    events = eventsResult.get('items', [])

    if not events:
        print('No upcoming events found.')
    
    SHORT_VER=LONG_VER.split('.')
    del SHORT_VER[2:4]
    SHORT_VER='.'.join(SHORT_VER)
    WRITTEN_ONE=0
    for event in events:
        if SHORT_VER == event['summary'] or LONG_VER == event['summary']:
            WRITTEN_ONE=1
            update_event(event['id'], COMMENT)
    
    if WRITTEN_ONE != 1:
        create_event(LONG_VER, COMMENT)

def update_event(EVENT_ID, COMMENT):
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('calendar', 'v3', http=http)
    # First retrieve the event from the API.
    event = service.events().get(calendarId='mn01riqketee7iojqjmnn4kl78@group.calendar.google.com', eventId=EVENT_ID).execute()
    if 'description' in event :
        event['description'] = event['description'] + '\n' + COMMENT
    else :
        event['description'] = COMMENT
    updated_event = service.events().update(calendarId='mn01riqketee7iojqjmnn4kl78@group.calendar.google.com', eventId=event['id'], body=event).execute()
    # Print the updated date
    # print (updated_event['summary'] + ' updated at ' +  updated_event['updated'] )


def create_event(VERS, COMMENT):
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('calendar', 'v3', http=http)
    CURR_TIME = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+09:00')
    CURR_TIME_PLUS_1_HOUR=(datetime.datetime.now() + datetime.timedelta(hours=1)).strftime('%Y-%m-%dT%H:%M:%S+09:00')
    event = {
    'summary': VERS,
    'description': COMMENT,
    'start': {
        'dateTime': CURR_TIME,
        'timeZone': 'Asia/Seoul',
    },
    'end': {
        'dateTime': CURR_TIME_PLUS_1_HOUR,
        'timeZone': 'Asia/Seoul',
    },
    }

    event = service.events().insert(calendarId='mn01riqketee7iojqjmnn4kl78@group.calendar.google.com', body=event).execute()
    print ('Event created: %s' % (event.get('htmlLink')))

def main():
    search_event(sys.argv[1], sys.argv[2])

if __name__ == '__main__':
    main()