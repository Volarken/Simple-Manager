import requests #dependency
import sys
from webhook import *

if __name__ == "__main__":
    a = str(sys.argv[1])
    b = str(sys.argv[2])
    c = str(sys.argv[3])
    
#for all params, see https://discordapp.com/developers/docs/resources/webhook#execute-webhook
    data = {
        "content" : "@everyone",
        "username" : "Web Server Console!"
    }

#leave this out if you dont want an embed
#for all params, see https://discordapp.com/developers/docs/resources/channel#embed-object
    data["embeds"] = [
        {
            "color" : "{}".format(a),
            "description" : "Activity: {}\n\n Time of Log: {}".format(b, c),
            "title" : "Event Logged!"
        }
    ]

    result = requests.post(url, json = data)

    try:
        result.raise_for_status()
    except requests.exceptions.HTTPError as err:
        print(err)
    else:
        print("Payload delivered successfully, code {}.".format(result.status_code))

#result: https://i.imgur.com/DRqXQzA.png