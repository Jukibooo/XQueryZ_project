declare function local:output-2 ($current as node(), $pointer as node()*)
as node()*
{
  let $x := local:type-check(($current, $pointer))
  return
    let $current := local:current($x)
    let $pointer := local:pointer($x)
    return
     if(fn:name($current) = "_")
     then
       ()
     else (
	     element {fn:name($current)} {
		    (:first-child:)
          if(fn:empty($current/*[1]))
          then ()
          else local:output-2($current/*[1], $pointer)
         }
	     ,
	     (:next-sibling:)
         if(fn:empty($current/*[2]))
         then ()
         else local:output-2($current/*[2], $pointer)
         )
};

(:非終端記号か変数であればポインタの処理を行う関数:)
declare function local:type-check ($x as node()*)
as node()*
{
  let $current := local:current($x)	(:カレントノードのポインタ:)
  let $pointer := local:pointer($x)	(:辿ってきた非終端記号へのポインタ:)
  return
    if($current/@type="N")
    then	(:非終端記号の場合:)
      let $pointer := ($pointer, $current)	(:辿ってきた非終端記号へのポインタへ追加:)
      let $current := fn:root($current)/*/*[name()=fn:name($current)]/*[2]	(:カレントノードを非終端記号の部分木の頂点に変更:)
      return
        local:type-check(($current, $pointer))	(:変更先が非終端記号か変数の場合のため:)
    else if($current/@type="V")	(:変数の場合:)
    then
      if(fn:name($current) = "y0")	(:変数名y0の場合:)
      then
        let $current := $pointer[fn:count($pointer)]/*[1]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            local:type-check(($current, $pointer))	(:変更先が非終端記号か変数の場合のため:)
      else if(fn:name($current) = "y1")	(:変数名y1の場合:)
      then
        let $current := $pointer[fn:count($pointer)]/*[2]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            local:type-check(($current, $pointer))	(:変更先が非終端記号か変数の場合のため:)
      else if(fn:name($current) = "y2")	(:変数名y2の場合:)
      then
        let $current := $pointer[fn:count($pointer)]/*[3]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            local:type-check(($current, $pointer))	(:変更先が非終端記号か変数の場合のため:)
      else
        let $current := $pointer[fn:count($pointer)]/*[4]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            local:type-check(($current, $pointer))	(:変更先が非終端記号か変数の場合のため:)
    else
      ($current, $pointer)
};

declare variable $s := element {"separator"} {};	(:separator:)
	 
(:カレントノードのポインタを取得:)
declare function local:current ($x as node()*)
as node()
{
  $x[1]
};
	 
(:辿ってきた非終端記号のポインタを取得:)
declare function local:pointer($x as node()*) as node()*
{
  $x[1 < position()]
};

declare function local:unranked($x as node())
as node()*
{
  for $v in $x/*/*[name()="S"]
  return local:output-2($v/*[2]/*[1], ())
};

for $v in doc("../result/result.xml")
return local:unranked($v)