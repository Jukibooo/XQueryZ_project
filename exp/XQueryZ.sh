#java -Xmx"$1" -Xss"$2" -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result.xml" -q:"../XQuery/XQueryZ-new1.xq"

java -Xmx1g -Xss1g -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result2.xml" -q:"../XQuery/XQueryZ-new1.xq"