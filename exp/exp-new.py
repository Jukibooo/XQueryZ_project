#!/usr/bin/python

import subprocess
import json
import requests
import sys
import time

#辞書に登録（ファイル）
filenames = ['../ex/Nasa/Nasa.xml']

#辞書に登録（問合せ）
queries = {
					'$v/descendant::publisher': 'axis:descendant($v, "publisher")',
					'$v/descendant::reference': 'axis:descendant($v, "reference")',
					'$v/descendant::dataset': 'axis:descendant($v, "dataset")',
					'$v/descendant::title': 'axis:descendant($v, "title")',
					'$v/descendant::tableHead': 'axis:descendant($v, "tableHead")',
					'$v/descendant::history': 'axis:descendant($v, "publisher")',
					'$v/descendant::field': 'axis:descendant($v, "field")',
					'$v/descendant::title/following-sibling::publisher': 'axis:following-sibling(axis:descendant($v, "title"), "publisher")',
					'$v/descendant::author/ancestor::reference': 'axis:ancestor(axis:descendant($v, "author"), "reference")',
					'$v/descendant::reference/parent::dataset': 'axis:parent(axis:descendant($v, "reference"), "dataset")',
					'$v/descendant::dataset/following::title': 'axis:following(axis:descendant($v, "dataset"), "title")',
					'$v/descendant::units/parent::field': 'axis:parent(axis:descendant($v, "units"), "field")',
					'$v/descendant::creator/ancestor::history': 'axis:ancestor(axis:descendant($v, "creator"), "history")',
					'$v/descendant::creator': 'axis:descendant($v, "creator")',
					'$v/descendant::date/preceding-sibling::creator': 'axis:preceding-sibling(axis:descendant($v, "date"), "creator")',
					'$v/descendant::altname': 'axis:descendant($v, "altname")',
					'$v/descendant::reference/preceding::altname': 'axis:preceding(axis:descendant($v, "reference"), "altname")',
					'$v/descendant::fields/parent::tableHead': 'axis:parent(axis:descendant($v, "fields"), "tableHead")',



			}

def main ():
	count = 0

	for filename in filenames:
		#辞書をループ
		for query in queries:
			count += 1

			
			###圧縮文書に対する問い合わせ

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
			#Signal(filename, query)
			#path = '../result/commandoutput' + str(count)
			#result = subprocess.check_output(['/usr/bin/time -f "%M KB" ./XQueryZ.sh'])
			#file = open(path, 'w')
			#file.write(str(query) + '\n\n' + str(result))
			#file.close()
			cmd = '/usr/bin/time -f "%MKB" ./XQueryZ.sh'
			start = time.time()
			res = subprocess.run(cmd.split(' ') , stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
			#result = subprocess.Popen(cmd, stdout=subprocess.PIPE,shell=True).communicate()[0]
			result = sys.stdout.buffer.write(res.stdout)
			print(result)
			elapsed_time = time.time() - start
			Signal(str(query)+' (compressed)', str(result) + "\n" + str(elapsed_time))
			
			
			###非圧縮文書に対する問い合わせ
			#ファイルの更新
			file = open('../XQuery/XQuery.xq', 'r')
			strings = file.read()
			file.close()
			string = strings.split('(:===///===:)')
			string[1] = str('doc("' + filename + '")')
			string[3] = str(query)
			strings = string[0] + '(:===///===:)\n' + string[1] + '\n(:===///===:)' + string[2] + '(:===///===:)\n' + string[3] + '\n(:===///===:)'
			file = open('../XQuery/XQuery.xq', 'w')
			file.write(strings)
			file.close()

			#実験
			#Signal(filename, query)
			#path = '../result/commandoutput-original' + str(count)
			#result = subprocess.check_output(['/usr/bin/time -f "%M KB" ./XQuery.sh'])
			#file = open(path, 'w')
			#file.write(str(query) + '\n\n' + str(result))
			#file.close()
			cmd = '/usr/bin/time -f "%MKB" ./XQuery.sh'
			start = time.time()
			res = subprocess.run(cmd.split(' ') , stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
			#result = subprocess.Popen(cmd, stdout=subprocess.PIPE,shell=True).communicate()[0]
			result = sys.stdout.buffer.write(res.stdout)
			print(result)
			elapsed_time = time.time() - start
			Signal(str(query)+' (uncompressed)', str(result) + "\n" + str(elapsed_time))
		
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