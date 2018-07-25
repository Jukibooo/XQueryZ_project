(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace axis = "http://xqueryz/axis";

(: 非終端記号にあるポインタを終端記号に移動するためのモジュール :)
declare namespace pointer = "http://xqueryz/pointer";
import module "http://xqueryz/pointer" at "pointer.xq";


(: カッコをimport :)
declare namespace separater = "http://xqueryz/separater";
import module "http://xqueryz/separater" at "separater.xq";

(: DDO処理するためのモジュール :)
declare namespace ddo = "http://xqueryz/ddo";
import module "http://xqueryz/ddo" at "ddo.xq";

(: トライ木からひとつのノードのリストを取得するためのモジュール :)
declare namespace getlist = "http://xqueryz/getlist";
import module "http://xqueryz/getlist" at "getlist.xq";


(:child軸の関数:)
(: $listはtrie木 :)
declare function axis:child ($list as node()*, $label as xs:string)
as node()*
{
(:  fn:trace((), "axis:child"),:)
  let $startNum := getlist:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  return  let $resultList := axis:SearchChild(getlist:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しchildを探す :)
          let $newNum := getlist:searchTerminal($list, $startNum + 1)
          return  if ($newNum = 0)
                  then  $resultList
                  else  axis:child-next($list, $newNum, $label, $resultList)
};

(: 2個目以降のchild軸 :)
(: $listはtrie木 :)
declare function axis:child-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
(:  fn:trace((), "axis:child-next"),:)
  let $resultList := axis:SearchChild(getlist:getList($list, $num, ()), $label, $output) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:child-next($list, $newNum, $label, $resultList)
};

(: 実際にchildを探す関数 :)
(: $listはtrie木から一つの経路を抽出したもの :)
declare function axis:SearchChild ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
(:  fn:trace((), "axis:SearchChild"),:)
  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if (fn:empty($current/*[1]))
          then $output
          else axis:SearchChild-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output)

};

declare function axis:SearchChild-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
(:  fn:trace((), "axis:SearchChild-main"),:)
  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  let $output1 := ( 
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  ddo:lastsetDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                    else  $output
                  )
  return  if (fn:empty($current/*[2]))
          then $output1
          else axis:SearchChild-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output1)
};

declare function axis:descendant ($list as node()*, $label as xs:string)
as node()*
{
(:  fn:trace((), "axis:descendant"),:)
  let $startNum := getlist:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  return  let $resultList := axis:SearchDescendant(getlist:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しdescendantを探す :)
          let $newNum := getlist:searchTerminal($list, $startNum + 1)
          return  if ($newNum = 0)
                  then  $resultList
                  else  axis:descendant-next($list, $newNum, $label, $resultList)
};

declare function axis:descendant-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
(:  fn:trace((), "axis:descendant-next"),:)
  let $resultList := axis:SearchDescendant(getlist:getList($list, $num, ()), $label, $output) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:descendant-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchDescendant ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
(:  fn:trace((), "axis:SearchDescendant"),:)
  let $newList := pointer:type-check-new($list) (: 非終端か変数 -> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if (fn:empty($current/*[1]))
          then $output
          else axis:SearchDescendant-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output)  (: last > position は、カレントノードだけ置き換えるため :)
};

declare function axis:SearchDescendant-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
(:  fn:trace((), "axis:SearchDescendant-main"),:)
  let $newList := pointer:type-check-new($list) (: 非終端か変数 -> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  let $output1 := ( 
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  ddo:lastsetDDOlist($output, $newList, 1, 1)(: TRIE木に登録 :)
                    else  $output
                  )
  return  (
          let $output-left := (if (fn:empty($current/*[1])) (: 深さ優先 :)
                               then $output1
                               else axis:SearchDescendant-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output1)  (: last > position は、カレントノードだけ置き換えるため :)
                              )
          return  if (fn:empty($current/*[2]))
                  then $output-left
                  else axis:SearchDescendant-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output-left)  (: last > position は、カレントノードだけ置き換えるため :)
          )
};

(: self軸 :)
declare function axis:self ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:self"),:)
  let $startNum := getlist:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  let $resultList := axis:SearchSelf(getlist:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:self-next($list, $newNum, $label, $resultList)
};

declare function axis:self-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:self-next"),:)
  let $resultList := axis:SearchSelf(getlist:getList($list, $num, ()), $label, $output) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:self-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchSelf ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchSelf"),:)
  let $newList := pointer:type-check-new($list) (: 非終端か変数 -> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
          then  ddo:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
          else  $output
};

(: descentdant-or-self軸 :)
declare function axis:descendant-or-self ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:descendant-or-self"),:)
  let $startNum := getlist:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  let $resultList := axis:SearchDescendant(getlist:getList($list, $startNum, ()), $label, axis:self($list, $label)) (: getListでリストを作成しdescendantを探す :)
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:descendant-next($list, $newNum, $label, $resultList)
};

(: parent軸 :)

declare function axis:parent ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:parent"),:)
    let $startNum := getlist:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
    let $resultList := axis:SearchParent(getlist:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しparentを探す :)
    let $newNum := getlist:searchTerminal($list, $startNum + 1)
    return  if ($newNum = 0)
            then  $resultList
            else  axis:parent-next($list, $newNum, $label, $resultList)
};

declare function axis:parent-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:parent-next"),:)
  let $resultList := axis:SearchParent(getlist:getList($list, $num, ()), $label, $output) (: getListでリストを作成しparentを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:parent-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchParent ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchParent"),:)
  let $newList := pointer:gotoparent($list) (: 非終端か変数 -> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if ($current/@type = "root")
          then  if ($label = "*")
                then ddo:setDDOlist($output, $current/*[2], 1, 1)
                else $output
          else  if (fn:name($current) = $label or $label = "*")
                then ddo:setDDOlist($output, $newList, 1, 1)
                else $output
};

(: ancestor軸 :)
declare function axis:ancestor ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:ancestor"),:)
  let $startNum := getlist:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  let $resultList := axis:SearchAncestor(getlist:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:ancestor-next($list, $newNum, $label, $resultList)
};

declare function axis:ancestor-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:ancestor-next"),:)
  let $resultList := axis:SearchAncestor(getlist:getList($list, $num, ()), $label, $output) (: getListでリストを作成しparentを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:ancestor-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchAncestor ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchAncestor"),:)
  let $newList := pointer:gotoparent($list) (: 非終端か変数 -> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if ($current/@type = "root")
          then  $output
          else  let $output1 := (
                                 if (fn:name($current) = $label or $label = "*")
                                 then ddo:setDDOlist($output, $newList, 1, 1)
                                 else $output
                                )
                return axis:SearchAncestor($newList, $label, $output1)
                
};

(: ancestor-or-self軸 :)
declare function axis:ancestor-or-self ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:ancestor-or-self"),:)
  let $startNum := getlist:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  let $resultList := axis:SearchAncestor(getlist:getList($list, $startNum, ()), $label, axis:self($list, $label)) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:ancestor-next($list, $newNum, $label, $resultList)
};

(: following-sibling軸 :)
declare function axis:following-sibling ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:following-sibling"),:)
  let $startNum := getlist:searchTerminal($list, 1)
  let $resultList := axis:SearchFollowingSibling(getlist:getList($list, $startNum, ()), $label, ())
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:following-sibling-next($list, $newNum, $label, $resultList)
};

declare function axis:following-sibling-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:following-sibling-next"),:)
  let $resultList := axis:SearchFollowingSibling(getlist:getList($list, $num, ()), $label, $output)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:following-sibling-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchFollowingSibling ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchFollowingSibling"),:)
  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if (fn:empty($current/*[2]))
          then $output
          else axis:SearchFollowingSibling-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output)

};

declare function axis:SearchFollowingSibling-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchFollowingSibling-main"),:)
  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  let $output1 := ( 
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  ddo:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                    else  $output
                  )
  return  if (fn:empty($current/*[2]))
          then $output1
          else axis:SearchFollowingSibling-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output1)
};

(: following軸 :)
declare function axis:following ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:following"),:)
  let $startNum := getlist:searchTerminal($list, 1)
  let $resultList := axis:SearchFollowing(getlist:getList($list, $startNum, ()), $label, ())
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:following-next($list, $newNum, $label, $resultList)
};

declare function axis:following-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:following-next"),:)
  let $resultList := axis:SearchFollowing(getlist:getList($list, $num, ()), $label, $output)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:following-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchFollowing ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchFollowing"),:)
  let $current := $list[fn:last()]
  return  if (fn:empty($current/*[2]))
          then axis:SearchFollowing-parent(pointer:gotoparent($list), $label, $output)
          else axis:SearchFollowing-main(($list[fn:last() > fn:position()], $current/*[2]), $label, $output)
};

declare function axis:SearchFollowing-parent ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchFollowing-parent"),:)
  let $current := $list[fn:last()]
  return  if ($current/@type = "root")
          then  $output
          else  if (fn:empty($current/*[2]))
                then axis:SearchFollowing-parent(pointer:gotoparent($list), $label, $output)
                else axis:SearchFollowing-main(($list[fn:last() > fn:position()], $current/*[2]), $label, $output)
};

declare function axis:SearchFollowing-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchFollowing-main"),:)
  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  let $output1 := (
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  ddo:setDDOlist($output, $newList, 1, 1)
                    else  $output
                  )
  let $output2 := axis:SearchDescendant($newList, $label, $output1)
  return  if (fn:empty($current/*[2]))
          then  axis:SearchFollowing-parent(pointer:gotoparent($newList), $label, $output2)
          else  axis:SearchFollowing-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output2)
};

(: preceding-sibling軸 :)
declare function axis:preceding-sibling ($list as node()*, $label as xs:string)
as node()*
{
  (:fn:trace((), "axis:preceding-sibling"),:)
  let $startNum := getlist:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  let $newList := getlist:getList($list, $startNum, ())
  let $parentlist := pointer:gotoparent($newList)
  let $resultList := axis:SearchPrecedingSibling($parentlist, $label, (), $newList[fn:last()]) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:preceding-sibling-next($list, $newNum, $label, $resultList)
};

declare function axis:preceding-sibling-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:preceding-sibling-next"),:)
  let $newList := getlist:getList($list, $num, ())
  let $parentlist := pointer:gotoparent($newList)
  let $resultList := axis:SearchPrecedingSibling($parentlist, $label, $output, $newList[fn:last()]) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:preceding-sibling-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchPrecedingSibling ($list as node()*, $label as xs:string, $output as node()*, $newNode as node())
as node()*
{  
  (:fn:trace((), "axis:SearchPrecedingSibling"),:)

  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if ($current/*[1] is $newNode)
          then $output
          else axis:SearchPrecedingSibling-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output, $newNode)

};

declare function axis:SearchPrecedingSibling-main ($list as node()*, $label as xs:string, $output as node()*, $newNode as node())
as node()*
{
    (:fn:trace((), "axis:SearchPrecedingSibling-main"),:)

  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if ($current is $newNode)
          then $output
          else  let $output1 := ( 
                                  if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                                  then  ddo:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                                  else  $output
                                )
                return  if (fn:empty($current/*[2]))
                        then $output1
                        else axis:SearchPrecedingSibling-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output1, $newNode)
};


(: preceding軸 :)
declare function axis:preceding ($list as node()*, $label as xs:string)
as node()*
{
      (:fn:trace((), "axis:preceding"),:)
  let $startNum := getlist:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  let $newList := getlist:getList($list, $startNum, ())
  let $parentlist := pointer:gotoparent($newList)
  let $resultList := axis:SearchPreceding($parentlist, $label, (), $newList[fn:last()]) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $startNum + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:preceding-next($list, $newNum, $label, $resultList)
};

declare function axis:preceding-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:preceding-next"),:)
  let $newList := getlist:getList($list, $num, ())
  let $parentlist := pointer:gotoparent($newList)
  let $resultList := axis:SearchPreceding($parentlist, $label, $output, $newList[fn:last()]) (: getListでリストを作成しchildを探す :)
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  axis:preceding-next($list, $newNum, $label, $resultList)
};

declare function axis:SearchPreceding ($list as node()*, $label as xs:string, $output as node()*, $newNode as node())
as node()*
{
  (:fn:trace((), "axis:SearchPreceding"),:)
  let $current := $list[fn:last()]
  return  axis:SearchPreceding-main(($list[fn:last() > fn:position()], $current/*[1]), $label, $output, $newNode)
};

declare function axis:SearchPreceding-parent ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  (:fn:trace((), "axis:SearchPreceding-parent"),:)
  let $current := $list[fn:last()]
  let $parentlist := pointer:gotoparent($list)
  return  if ($current/@type = "root")
          then  $output
          else  axis:SearchPreceding($parentlist, $label, $output, $current)
};

declare function axis:SearchPreceding-main ($list as node()*, $label as xs:string, $output as node()*, $newNode as node())
as node()*
{
  (:fn:trace((), "axis:SearchPreceding-main"),:)
  let $newList := pointer:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if ($current is $newNode)
          then  axis:SearchPreceding-parent(pointer:gotoparent($newList), $label, $output)
          else  let $output1 := ( 
                                  if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                                  then  ddo:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                                  else  $output
                                )
                let $output2 := axis:SearchDescendant($newList, $label, $output1)
                return  axis:SearchPreceding-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output2, $newNode)
};
