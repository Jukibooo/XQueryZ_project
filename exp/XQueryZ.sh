#java -Xmx"$1" -Xss"$2" -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result.xml" -q:"../XQueryZ/main.xq"

java -Xmx1g -Xss1g -cp saxon9he.jar net.sf.saxon.Query -t -o:"../result/result3.xml" -q:"../XQueryZ/main.xq"