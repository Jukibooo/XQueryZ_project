(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace output = "http://xqueryz/output";

declare function output:output ($list as node()*, $num as xs:integer, $output as xs:string)
as xs:string
{
(:  fn:trace((), "output:output"),:)
    if (fn:empty($list[$num]))
    then  $output
    else  if (fn:name($list[$num]) = "left_separator")
    then  output:output($list, $num + 1, fn:concat($output, "("))
    else if (fn:name($list[$num]) = "right_separator")
    then  if (fn:name($list[$num + 1]) = "right_separator")
          then  output:output($list, $num + 1, fn:concat($output, ")"))
          else  output:output($list, $num + 1, fn:concat($output, "),"))
    else  if (fn:name($list[$num + 1]) = "left_separator" or fn:name($list[$num + 1]) = "right_separator")
          then  output:output($list, $num + 1, fn:concat($output, fn:name($list[$num])))
          else  output:output($list, $num + 1, fn:concat($output, fn:name($list[$num]), ", "))
};