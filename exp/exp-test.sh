#!/bin/sh

minus_heap () {	# ヒープサイズを引く関数
	heap=`expr $heap - $1`

	./XQueryZ-test.sh "$heap"m 100m

	while [ "$?" -eq "0" ]
	do
		heap=`expr $heap - $1`
		echo "$heap , $stack"
		./XQueryZ-test.sh "$heap"m 100m
	done
}

minus_stack () {	# スタックサイズを引く関数
	stack=`expr $stack - $1`

	./XQueryZ-test.sh "$heap"m 100m

	while [ "$?" -eq "0" ]
	do
		stack=`expr $stack - $1`
		echo "$heap , $stack"
		./XQueryZ-test.sh "$heap"m "stack"m
	done
}

plus_heap () {	# ヒープサイズを足す関数
	heap=`expr $heap + $1`

	./XQueryZ-test.sh "$heap"m 100m

	while [ "$?" -eq "1" ]
	do
		heap=`expr $heap + $1`
		echo "$heap , $stack"
		./XQueryZ-test.sh "$heap"m "$stack"m
	done
}

plus_stack () {	# スタックサイズを足す関数
	stack=`expr $stack + $1`

	./XQueryZ-test.sh "$heap"m "$stack"m

	while [ "$?" -eq "1" ]
	do
		stack=`expr $stack + $1`
		echo "$heap , $stack"
		./XQueryZ-test.sh "$heap"m "$stack"m
	done
}

filename="$1"
query="$2"

heap=120	# 初期ヒープサイズ指定
stack=0	# 初期スタックサイズ指定

./XQueryZ-test.sh "$heap"m 100m

if [ "$?" -eq "1" ]	# 実行失敗(1)したら
then
	plus_heap 100

	minus_heap 10

	plus_heap 1

	plus_stack 1

	python3 finish_signal.py "${filename}" "${query}" "$heap" "$stack"

else	# 実行成功(0)したら
	
	minus_heap 100

	plus_heap 10

	minus_heap 1

	heap=`expr $heap + 1`

	plus_stack 1


	python3 finish_signal.py "${filename}" "${query}" "$heap" "$stack"

fi

