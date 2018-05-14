minus_heap () {	# ヒープサイズを引く関数
	heap=`expr $heap - $1`

	./XQueryZ.sh "$heap"m "$stack"m

	while [ "$?" -eq "0" ]
	do
		heap=`expr $heap - $1`
		echo "$heap , $stack"
		./XQueryZ.sh "$heap"m "$stack"m
	done
}

minus_stack () {	# スタックサイズを引く関数
	stack=`expr $stack - $1`

	./XQueryZ.sh "$heap"m "$stack"m

	while [ "$?" -eq "0" ]
	do
		stack=`expr $stack - $1`
		echo "$heap , $stack"
		./XQueryZ.sh "$heap"m "$stack"m
	done
}

plus_heap () {	# ヒープサイズを足す関数
	heap=`expr $heap + $1`

	./XQueryZ.sh "$heap"m "$stack"m

	while [ "$?" -eq "1" ]
	do
		heap=`expr $heap + $1`
		echo "$heap , $stack"
		./XQueryZ.sh "$heap"m "$stack"m
	done
}

plus_stack () {	# スタックサイズを足す関数
	stack=`expr $stack + $1`

	./XQueryZ.sh "$heap"m "$stack"m

	while [ "$?" -eq "1" ]
	do
		stack=`expr $stack + $1`
		echo "$heap , $stack"
		./XQueryZ.sh "$heap"m "$stack"m
	done
}

heap=1024	# 初期ヒープサイズ指定
stack=1024	# 初期スタックサイズ指定

./XQueryZ.sh "$heap"m "$stack"m

if [ "$?" -eq "1" ]	# 実行失敗(1)したら
then
	plus_heap 100

	minus_heap 10

	plus_heap 1

	plus_stack 100

	minus_stack 10

	plus_stack 1

	python finish_signal.py XQueryZ.xq "$heap" "$stack"

else	# 実行成功(0)したら
	
	minus_heap 100

	plus_heap 10

	minus_heap 1

	heap=`expr $heap + 1`

	minus_stack 100

	plus_stack 10

	minus_stack 1

	stack=`expr $stack + 1` 

	python finish_signal.py XQueryZ.xq "$heap" "$stack"

fi
