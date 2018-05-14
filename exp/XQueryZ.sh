#java -Xmx"$1"g -Xss"$2"m -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result.xml" -q:"../XQuery/XQueryZ-new1.xq"

java -Xmx1g -Xss1g -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result1.xml" -q:"../XQuery/XQueryZ-new1.xq"