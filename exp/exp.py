#!/usr/bin/python

import subprocess
import json
import requests
import sys

#辞書に登録（ファイル）
filenames = ['../ex/Nasa/Nasa-n.xml']

#辞書に登録（問合せ）
queries = {
					'$v/descendant::reference/child::source': 'axis:child(axis:descendant($v, "dataset"), "reference")',
					'$v/descendant::other/parent::source': 'axis:parent(axis:descendant($v, "source"), "reference")',
					#'$v/descendant::dataset/descendant::history': 'axis:descendant(axis:descendant($v, "dataset"), "history")',
					#'$v/descendant::creator/ancestor::history': 'axis:ancestor(axis:descendant($v, "creator"), "history")',
					#'$v/descendant::reference/following::tableLinks': 'axis:following(axis:descendant($v, "reference"), "tableLinks")',
					#'$v/descendant::history/preceding::tableLinks': 'axis:preceding(axis:descendant($v, "history"), "tableLinks")',
					#'$v/descendant::reference/following-sibling::tableHead': 'axis:following-sibling(axis:descendant($v, "reference"), "tableHead")',
					#'$v/descendant::history/preceding-sibling::tableHead': 'axis:preceding-sibling(axis:descendant($v, "history"), "tableHead")',
					#'$v/descendant::dataset/descendant-or-self::author': 'axis:descendant-or-self(axis:descendant($v, "dataset"), "author")',
					'$v/descendant::initial/ancestor::author': 'axis:ancestor(axis:descendant($v, "initial"), "author")'

					#'$v/descendant::PLAYER/parent::TEAM': 'axis:parent(axis:descendant($v, "PLAYER"), "TEAM")'
					#'$v/descendant::dataset/descendant::author': 'axis:descendant(axis:descendant($v, "dataset"), "author")'
					#'$v/descendant::ACT/child::TITLE': 'axis:child(axis:descendant($v, "ACT"), "TITLE")'
					#'$v/descendant::NNP': 'axis:descendant($v, "NNP")'
					#'$v/descendant::T/child::L_DISCOUNT': 'axis:child(axis:descendant($v, "T"), "L_DISCOUNT")'
					#'$v/descendant::proceedings/child::url' : 'axis:child(axis:descendant($v, "proceedings"), "url")' 
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
			path = '../result/commandoutput' + str(count)
			result = subprocess.check_output(["./exp.sh", filename, query])
			file = open(path, 'w')
			file.write(str(query) + '\n\n' + str(result))
			file.close()
			
			
			###非圧縮文書に対する問い合わせ
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
			result = subprocess.check_output(["./exp-non.sh", filename+'-original', query])
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