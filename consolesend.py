import requests #dependency
import sys
from webhook.py import

if __name__ == "__main__":
    a = str(sys.argv[1])
    b = str(sys.argv[2])
    url = "https://discord.com/api/webhooks/862807958231711754/xclV0iIlpWNeZK-6yzL974AzG1VUdg6xu9d-WV6IQEpBKydM15iFQ-h7zn_MXWGt0Wo5" #webhook url, from here: https://i.imgur.com/f9XnAew.png

#for all params, see https://discordapp.com/developers/docs/resources/webhook#execute-webhook
    data = {
        "content" : "@everyone",
        "username" : "Web Server Console!"
    }

#leave this out if you dont want an embed
#for all params, see https://discordapp.com/developers/docs/resources/channel#embed-object
    data["embeds"] = [
        {
            "description" : "Command: {}\n\n Output Satus: {}".format(a, b),
            "title" : "Console Command Executed!"
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