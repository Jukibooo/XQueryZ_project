# coding: UTF-8
import sys	#引数を取得

args = sys.argv	#引数を得るため

sys.setrecursionlimit(2000000000)


print ('start symbol is ?')
input_start_symbol = input()

f = open(args[1])	#第1引数のファイルを読み込み
linesall = f.readlines() # 1行毎にファイル終端まで全て読む(改行文字も含まれる)
f.close()
# linesall: リスト。要素は1行の文字列データ

w = open(args[2],'w')	#第2引数のファイルに書き込み
w.write('')
w.write('<root>\n')	#rootノードの作成

num = 0	#右辺の文字番号
count = 0

node_id = 0

'''
###右辺をXML文書に変換する関数###
'''
def right_hand_side(right_str):
	temp_str = ""	#記号の一時保存用変数
	right_list = []

	global num
	global node_id


	#placeholder，または右辺の要素が1つのみの場合は個別に処理する
	if len(right_str) == 2:
		w.write('<'+right_str[0]+' type="'+type_check(right_str[0])+'" id="'+ str(node_id) + '"/>\n')
		node_id += 1
		return

	while num < len(right_str)-1:	#"("か")"か","がくるまでループ，1文字ずつ文字列を読み込む

		
		if (right_str[num] == "("):
			w.write('<'+temp_str+' type="'+type_check(temp_str)+'" id="'+str(node_id)+'">\n')
			node_id += 1
			right_list.append(temp_str)
			temp_str = ""
			num += 1

		elif (right_str[num] == ")"):
			if right_str[num-1] != ")":	#")"の前に")"が存在しない場合，ノードは葉になる
				w.write('<'+temp_str+' type="'+type_check(temp_str)+'" id="'+ str(node_id) +'"/>\n')
				node_id += 1
			w.write('</'+right_list[-1]+'>\n')
			temp_str = ""
			right_list.pop()
			num += 1

		elif (right_str[num] == ","):
			if right_str[num-1] != ')':	#","の前に")"がない場合
				w.write('<'+temp_str+' type="'+type_check(temp_str)+'" id="'+ str(node_id) +'"/>\n')
				node_id += 1
			temp_str = ""
			num += 2

		else:
			temp_str = temp_str + right_str[num]	#記号が複数文字にわたる場合，1文字ずつ連結していく
			num += 1
	else:	
		return

'''
def right_hand_side(str):	#str: 入力文字列
	#左辺
	temp_str = ""	#記号の一時保存用変数
	global num
	global count

	#placeholder，または右辺の要素が1つのみの場合は個別に処理する
	if len(str) == 2:
		w.write('<'+str[0]+' type="'+type_check(str[0])+'"/>\n')
		return

	while num < len(str)-1:	#"("か")"か","がくるまでループ，1文字ずつ文字列を読み込む
		if (str[num] == "(") or (str[num] == ")") or (str[num] == ","):
			break
		else:
			temp_str = temp_str + str[num]	#記号が複数文字にわたる場合，1文字ずつ連結していく
			num += 1
	else:	
		return

	#"("のとき
	if str[num] == "(":	
		w.write('<'+temp_str+' type="'+type_check(temp_str)+'">\n')
		num += 1
		count += 1
		print count
		right_hand_side(str)
		count -= 1
		print count
		w.write('</'+temp_str+'>\n')
		count += 1
		print count
		right_hand_side(str)
		count -= 1
		print count
		return

	#")"のとき
	elif str[num] == ")":
		if str[num-1] != ")":	#")"の前に")"が存在しない場合，ノードは葉になる
			w.write('<'+temp_str+' type="'+type_check(temp_str)+'"/>\n')
		num += 1	#")"の前に")"が存在する場合は親ノードに戻るだけ
		return

	#","のとき
	elif str[num] == ",":
		if str[num-1] != ')':	#","の前に")"がある場合
			w.write('<'+temp_str+' type="'+type_check(temp_str)+'"/>\n')
		num += 2	#","の後は空白なのでnumを2進める
		count += 1
		print count
		right_hand_side(str)
		count -= 1
		print count
		return
'''

'''
###属性を付加する関数###
'''
def type_check(str):
	#開始記号
	if str == "xml_collapse_start":
		return 'start'
	#非終端
	for x in nonterminal_list:
		if x == str:
			return 'N'
	#変数
	for x in variable_list:
		if x == str:
			return 'V'
	#終端記号
	else:
		return 'T'

'''
###変数がリストに存在するか調べて登録する関数###
'''
def variable_reg(str):
	for x in variable_list:
		if str == x:
			return
	else:
		variable_list.append(str)


'''
###ここからメインの処理の開始###
'''

if __name__ == '__main__':

	nonterminal_list = []	#非終端記号のリスト
	variable_list = []	#変数のリスト
	#まずリストに登録する
	for line in linesall:
		splitline = line.split(' -> ')	#左辺(0)と右辺(1)を分割
		for num in range(0, len(splitline[0])-1):	#左辺に引数が存在するか確認
			if splitline[0][num] == "(":	#存在している場合
				#まず分割する
				splitline1 = splitline[0].split('(')	#"("で分割:非終端(0),引数(1)
				split_args = splitline1[1].split(', ')	#引数を", "で分割
				split_args[len(split_args)-1] = split_args[len(split_args)-1][:-1] 	#最後の")"を消す
				nonterminal_list.append(splitline1[0])	#非終端記号をリストに登録
				for split_args_num in split_args:	#変数をリストに登録
					variable_reg(split_args_num)
				break
		else:	#存在しない場合
			nonterminal_list.append(splitline[0])	#非終端記号をリストに登録

	for line in linesall:
	#ここに各行に関する処理を書く
		splitline = line.split(' -> ')	#左辺(0)と右辺(1)を分割
		line_right = list(splitline[1])	#右辺を一文字ずつに分割

		#左辺について
		for num in range(0, len(splitline[0])-1):	#左辺に引数が存在するか確認
			if splitline[0][num] == "(":	#存在している場合
				#まず分割する
				splitline1 = splitline[0].split('(')	#"("で分割:非終端(0),引数(1)
				split_args = splitline1[1].split(', ')	#引数を", "で分割
				split_args[len(split_args)-1] = split_args[len(split_args)-1][:-1] 	#最後の")"を消す

				w.write('<'+splitline1[0]+' type="nonterminal_root" id="'+ str(node_id) +'">\n')	
				node_id += 1
				w.write('<'+splitline1[0]+' type="'+type_check(splitline[0])+'" id="'+ str(node_id) +'">\n')	#左辺開始
				node_id += 1
				for split_args_num in split_args:	#左辺の引数を子に持つ
					w.write('<'+split_args_num+' type="'+type_check(split_args_num)+'" id="'+ str(node_id) +'"/>\n')
					node_id += 1
				w.write('</'+splitline1[0]+'>\n')	#左辺終了
				#右辺について
				num = 0
				right_hand_side(line_right)

				w.write('</'+splitline1[0]+'>\n')
				break
		else:	#存在していない場合
			if splitline[0] == "xml_collapse_start":
				w.write('<'+input_start_symbol+'>\n')
				w.write('<'+input_start_symbol+' type="'+type_check(splitline[0])+'" id="'+ str(node_id) +'"/>\n')
				node_id += 1
			else:
				w.write('<'+splitline[0]+' type="nonterminal_root">\n')
				w.write('<'+splitline[0]+' type="'+type_check(splitline[0])+'" id="'+ str(node_id) +'"/>\n')	#左辺
				node_id += 1
			#右辺について
			num = 0

			#開始記号にはrootノードをつける
			if splitline[0] == "xml_collapse_start":
				w.write('<'+input_start_symbol+' type="root" id="'+ str(node_id) +'">\n')
				node_id += 1
				right_hand_side(line_right)
				w.write('</'+input_start_symbol+'>\n')
			else:
				right_hand_side(line_right)

			if splitline[0] == "xml_collapse_start":
				w.write('</'+input_start_symbol+'>\n')
			else:
				w.write('</'+splitline[0]+'>\n')

	else:
		w.write('</root>')
		w.close()	#書き込み終了

		print ("completed")
