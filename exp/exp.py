#!/usr/bin/python

import subprocess
import json
import requests
import sys

#辞書に登録（ファイル）
filenames = ['Nasa.xml']

#辞書に登録（問合せ）
queries = {
					'//reference/parent::*': 'axis:parent(axis:descendant($v, "reference"), "*")',
					'//reference/follwing::tableHead': 'axis:following(axis:descendant($v, "reference"), "tableHead")',
					'//author/ancestor::dataset': 'axis:ancestor(axis:descendant($v, "author"), "dataset")',
					'//reference/child::source/child::other/child::title': 'axis:child(axis:child(axis:child(axis:descendant($v, "reference"), "source"), "other"), "title")',
					'//field': 'axis:descendant($v, "field")'
}

def main ():
	count = 0

	for filename in filenames:
		#辞書をループ
		for query in queries:
			count += 1

			#ファイルの更新
			file = open('../XQueryZ/main.xq', 'r')
			strings = file.read()
			file.close()
			string = strings.split('(:===///===:)')
			string[1] = queries[query]
			strings = string[0] + '(:===///===:)\n' + string[1] + '\n(:===///===:)' + string[2]
			file = open('../XQueryZ/main.xq', 'w')
			file.write(strings)
			file.close()

			#実験
			Signal(filename, query)
			path = '../result/commandoutput' + str(count)
			result = subprocess.check_output("./exp.sh")
			file = open(path, 'w')
			file.write(str(query) + '\n\n' + str(result))
			file.close()
	else:
		Signal('Finish', '')

def Signal(file, query):

	# Webhooks URL
	url = "https://hooks.slack.com/services/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"

	payload_dic = {
    	"attachments": [
    		{
    			"title": file,
   				"text": query
    		}
    	]
	}

	r = requests.post(url, data=json.dumps(payload_dic))



if __name__ == '__main__':
	main()