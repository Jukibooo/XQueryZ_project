#!/usr/bin/python

import subprocess
import json
import requests
import sys

#辞書に登録（ファイル）
filenames = ['Nasa.xml']

#辞書に登録（問合せ）
queries = {
					'$v/descendant::publisher': 'axis:descendant($v, "publisher")',
					'$v/descendant::title/following-sibling::publisher': 'axis:following-sibling(axis:descendant($v, "title"), "publisher")',
					'$v/descendant::field': 'axis:descendant($v, "field")',
					'$v/descendant::units/parent::field': 'axis:parent(axis:descendant($v, "units"), "field")',
					'$v/descendant::history': 'axis:descendant($v, "history")',
					'$v/descendant::creator/ancestor::history': 'axis:ancestor(axis:descendant($v, "creator"), "history")'
			}

def main ():
	count = 0

	for filename in filenames:
		#辞書をループ
		for query in queries:
			count += 1

			
			###圧縮文書に対する問い合わせ

			#ファイルの更新
			file = open('../XQueryZ/main-test.xq', 'r')
			strings = file.read()
			file.close()
			string = strings.split('(:===///===:)')
			string[1] = queries[query]
			strings = string[0] + '(:===///===:)\n' + string[1] + '\n(:===///===:)' + string[2]
			file = open('../XQueryZ/main-test.xq', 'w')
			file.write(strings)
			file.close()

			#実験
			#Signal(filename, query)
			path = '../result/commandoutputtest' + str(count)
			result = subprocess.check_output(["./exp-test.sh", filename, query])
			file = open(path, 'w')
			file.write(str(query) + '\n\n' + str(result))
			file.close()
			
			
			###非圧縮文書に対する問い合わせ
			'''
			#ファイルの更新
			file = open('../XQueryZ/main-original.xq', 'r')
			strings = file.read()
			file.close()
			string = strings.split('(:===///===:)')
			string[1] = str('doc("' + filename + '")')
			string[3] = str(query)
			strings = string[0] + '(:===///===:)\n' + string[1] + '\n(:===///===:)' + string[2] + '(:===///===:)\n' + string[3] + '\n(:===///===:)'
			file = open('../XQueryZ/main-original.xq', 'w')
			file.write(strings)
			file.close()

			#実験
			#Signal(filename, query)
			path = '../result/commandoutput-original' + str(count)
			result = subprocess.check_output(["./exp-test.sh", filename+'-original', query])
			file = open(path, 'w')
			file.write(str(query) + '\n\n' + str(result))
			file.close()
			'''

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