(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace pointer = "http://xqueryz/pointer";

declare namespace file = "http://xqueryz/file";
import module "http://xqueryz/file" at "file.xq";




declare function pointer:type-check-new ($list as node()*)
as node()*
{
(:  fn:trace((), "pointer:type-check-new"),:)
  (: 非終端記号の場合 :)
  if ($list[fn:last()]/@type = "N")
  then
    pointer:type-check-new(($list, $file:original/*/*[name()=fn:name($list[fn:last()])]/*[2]))
  (: 変数の場合 :)
  else if ($list[fn:last()]/@type = "V")
  then
    if (fn:name($list[fn:last()]) = "y0")
    then
      pointer:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[1]))
    else if (fn:name($list[fn:last()]) = "y1")
    then
      pointer:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[2]))
    else if (fn:name($list[fn:last()]) = "y2")
    then
      pointer:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[3]))
    else
      pointer:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[4]))
  (: 終端記号の場合 :)
  else 
    $list
};

(: ポインタを親に移動するための関数 :)
declare function pointer:gotoparent ($list as node()*)
as node()*
{
(:  fn:trace((), "pointer:gotoparent"),:)
  let $current := $list[fn:last()]
  let $output := (
                  if ($current/parent::*/@type = "N") (: 親が非終端記号の場合 :)(: rankがいくつの非終端記号によって変わる :)
                  then
                    if(fn:count($current/preceding-sibling::*) = 0)
                    then  pointer:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]))
                    else if(fn:count($current/preceding-sibling::*) = 1)
                    then  pointer:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]))
                    else if(fn:count($current/preceding-sibling::*) = 2)
                    then  pointer:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]))
                    else if(fn:count($current/preceding-sibling::*) = 3)
                    then  pointer:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]))
                    else ()
                  else if($current/parent::*/@type="N_root")  (: 親が非終端記号の部分木の頂点の場合 :)
                  then
                    let $current1 := $list[fn:last() - 1]
                    return  pointer:gotoparent($list[fn:position() < fn:last()])
                  else  (: 親が終端記号の場合 :)
                    if($current is $current/parent::*/*[1]) (: first child or next sibling:)
                    then  ($list[fn:position() < fn:last()], $current/parent::*)
                    else  pointer:gotoparent(($list[fn:position() < fn:last()], $current/parent::*))

      )
  return $output
};

