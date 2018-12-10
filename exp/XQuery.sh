#java -Xmx1g -Xss1g -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result.xml" -q:"../XQuery/XQuery.xq"

java -Xmx"$1" -Xss"$2" -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result.xml" -q:"../XQuery/XQuery.xq"

#basex -o "../result/result.xml" ../XQuery/XQuery.xq