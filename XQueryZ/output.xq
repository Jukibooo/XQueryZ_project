(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace output = "http://xqueryz/output";

declare function output:output ($list as node()*, $num as xs:integer, $output as xs:string)
as xs:string
{
  let $output1 := (
    if (fn:empty($list[$num]))
    then
      $output
    else
      if (fn:name($list[$num]) = "left_separator")
      then
        let $output2 := output:output($list, $num + 1, fn:concat($output, "("))
        return $output2
      else if (fn:name($list[$num]) = "right_separator")
      then
        if (fn:name($list[$num + 1]) = "right_separator")
        then
          let $output2 := output:output($list, $num + 1, fn:concat($output, ")"))
          return $output2
        else
          let $output2 := output:output($list, $num + 1, fn:concat($output, "),"))
          return $output2
      else
        if (fn:name($list[$num + 1]) = "left_separator" or fn:name($list[$num + 1]) = "right_separator")
        then
          let $output2 := output:output($list, $num + 1, fn:concat($output, fn:name($list[$num])))
          return $output2
        else
          let $output2 := output:output($list, $num + 1, fn:concat($output, fn:name($list[$num]), ", "))
          return $output2
    )
  return $output1

};