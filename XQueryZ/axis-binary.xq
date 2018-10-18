(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace axis-binary = "http://xqueryz/axis-binary";

(: DDO処理するためのモジュール :)
declare namespace ddo = "http://xqueryz/ddo";
import module "http://xqueryz/ddo" at "ddo.xq";


declare function axis-binary:descendant ($list as node()*, $label as xs:string)
as node()*
{
	if (fn:empty($list))
	then ()
	else let $resultList := axis-binary:searchDescendant($list[1], $label, ())
			 return if (fn:empty($list[2]))
			 				then $resultList
			 				else axis-binary:descendant-next($list, $label, $resultList, 2)
};

declare function axis-binary:descendant-next ($list as node()*, $label as xs:string, $output as node()*, $num as xs:integer)
as node()*
{
	let $resultList := axis-binary:searchDescendant($list[$num], $label, $output)
	return if (fn:empty($list[$num + 1]))
				 then $resultList
				 else axis-binary:descendant-next($list, $label, $resultList, $num + 1)
};

declare function axis-binary:searchDescendant ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
	if (fn:empty($list/*[1]))
  then $output
  else axis-binary:searchDescendant-main($list, $label, $output)
};

declare function axis-binary:searchDescendant-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
	let $output1 := (
										if (fn:name($list) = $label or ($label = "*" and fn:name($list) != "_"))
                    then  ($output, $list)
                    else  $output
									)
	return  (
          let $output-left := (if (fn:empty($list/*[1])) (: 深さ優先 :)
                               then $output1
                               else axis-binary:searchDescendant-main($list/*[1], $label, $output1)  (: last > position は、カレントノードだけ置き換えるため :)
                              )
          return  if (fn:empty($list/*[2]))
                  then $output-left
                  else axis-binary:searchDescendant-main($list/*[2], $label, $output-left)  (: last > position は、カレントノードだけ置き換えるため :)
          )
};

declare function axis-binary:ancestor ($list as node()*, $label as xs:string)
as node()*
{
	if (fn:empty($list))
	then ()
	else let $resultList := axis-binary:searchAncestor($list[1], $label, ())
			 return if (fn:empty($list[2]))
			 				then $resultList
			 				else axis-binary:ancestor-next($list, $label, $resultList, 2)
};

declare function axis-binary:ancestor-next ($list as node()*, $label as xs:string, $output as node()*, $num as xs:integer)
as node()*
{
	let $resultList := axis-binary:searchAncestor($list[$num], $label, $output)
	return if (fn:empty($list[$num + 1]))
				 then $resultList
				 else axis-binary:ancestor-next($list, $label, $resultList, $num + 1)
};

declare function axis-binary:searchAncestor ($list as node(), $label as xs:string, $output as node()*)
as node()*
{
	if (fn:name($list) = "root")
	then $output
	else (:let $output1 := (if (fn:name($list) = $label or $label = "*")
			 									then axis-binary:ddo($output, $list, fn:count($output))
			 									else $output
			 								 )
				return axis-binary:searchAncestor(axis-binary:gotoparent($list), $label, $output1):)
				if (fn:name($list) = $label or $label = "*")
				then axis-binary:ddo($output, $list, fn:count($output))
				else axis-binary:searchAncestor(axis-binary:gotoparent($list), $label, $output)
};

declare function axis-binary:gotoparent ($list as node())
as node()
{
	if ($list/parent::*/*[1] is $list)
	then $list/parent::*
	else axis-binary:gotoparent($list/parent::*)
};

declare function axis-binary:ddo ($list as node()*, $node as node(), $num as xs:integer)
as node()*
{
	if ($num = 0)
	then ($list, $node)
	else  if ($list[$num] is $node)
				then $list
				else axis-binary:ddo($list, $node, $num - 1)
};

