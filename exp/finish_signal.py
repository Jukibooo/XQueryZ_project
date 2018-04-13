
import json
import requests
import sys

args = sys.argv

#第一引数には通貨ペア，第二引数には売買の選択
def Signal(program, heap, stack):

	# Webhooks URL
	url = "https://hooks.slack.com/services/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"

	payload_dic = {
    	"attachments": [
    		{
    			"title": program,
   				"text": "[heap]"+heap+"(m), [stack]"+stack+"(m)"
    		}
    	]
	}

	r = requests.post(url, data=json.dumps(payload_dic))

if __name__ == '__main__':
    Signal(args[1], args[2], args[3])