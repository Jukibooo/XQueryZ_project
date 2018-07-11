(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace unranked = "http://xqueryz/unranked";

(: トライ木からひとつのノードのリストを取得するためのモジュール :)
declare namespace getlist = "http://xqueryz/getlist";
import module "http://xqueryz/getlist" at "getlist.xq";

(: 非終端記号にあるポインタを終端記号に移動するためのモジュール :)
declare namespace pointer = "http://xqueryz/pointer";
import module "http://xqueryz/pointer" at "pointer.xq";


(: $list: トライ木, $num: 終端記号の位置を得るためのノード番号, $output: これまで問合せ結果をunrankedに直したノード列 :)
declare function unranked:output ($list as node()*, $num as xs:integer, $output as node()*)
as node()*
{
	fn:trace((), "unranked:output"),
	let $newNum := getlist:searchTerminal($list, $num + 1)
	return  if ($newNum = 0)	(: 0はこれ以上終端記号がないことを示す :)
			then  $output
			else  let $newlist := getlist:getList($list, $newNum, ())
				  let $output1 := ($output, unranked:create($newlist))
				  return  unranked:output($list, $newNum, $output1)
};

declare function unranked:create ($list as node()*)
as node()*
{
	fn:trace((), "unranked:create"),
	let $newlist := pointer:type-check-new($list)
	let $current := $newlist[fn:last()]
	return  if (fn:name($current) = "_")
			then  ()
			else (
				element {fn:name($current)} { 
				(:first-child:)
          			if(fn:empty($current/*[1]))
          			then ()
          			else unranked:create(($newlist[fn:position() < fn:last()], $current/*[1]))
         		}
	     		,
	     		(:next-sibling:)
         		if(fn:empty($current/*[2]))
         		then ()
         		else unranked:create(($newlist[fn:position() < fn:last()], $current/*[2]))
         )
};


