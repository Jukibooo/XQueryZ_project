(: TRIE木を用いた手法 :)



declare function local:type-check-new ($list as node()*)
as node()*
{
  (: 非終端記号の場合 :)
  if ($list[fn:last()]/@type = "N")
  then
    local:type-check-new(($list, $original/*/*[name()=fn:name($list[fn:last()])]/*[2]))
  (: 変数の場合 :)
  else if ($list[fn:last()]/@type = "V")
  then
    if (fn:name($list[fn:last()]) = "y0")
    then
      local:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[1]))
    else if (fn:name($list[fn:last()]) = "y1")
    then
      local:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[2]))
    else if (fn:name($list[fn:last()]) = "y2")
    then
      local:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[3]))
    else
      local:type-check-new(($list[(fn:last() - 1) > fn:position()], $list[fn:last() - 1]/*[4]))
  (: 終端記号の場合 :)
  else if ($list[fn:last()]/@type = "T")
  then
    $list
  else ()
};



declare variable $left := <left_separator/>; (: ( :) (: new :)

declare variable $right := <right_separator/>; (: ) :) (: new :)

(:
(: カレントノードが()の中かどうか確認 :)
declare function local:check-branch ($list as node()*, $num as xs:integer)
as xs:boolean
{
  let $result := (
    if ($num = 0)  
    then
      fn:false()
    else if ($list[$num] is $left)  (: "("が見つかればカッコの中 :)
    then
      fn:true()
    else
      let $fun := local:check-branch ($list, $num - 1)  (: 左をみていく :)
      return $fun
  )
  return $result

};
:)

(: 各リストを作成 :)
declare function local:getList ($list as node()*, $num as xs:integer, $output as node()*)
as node()*
{
  if (fn:empty($list[$num]))
  then
    $output
  else
    if ($list[$num] is $left)
    then
      local:getList($list, local:exitParantheses($list, $num - 1, 1), $output)
    else
      local:getList($list, $num - 1, ($list[$num], $output))
};

(:
declare function local:getNode ($list as node()*, $num as xs:integer, $output as node()*)
as node()*
{
  if($list[$num]/@type = "T" and fn:empty($output)) (: 関数を再帰していない状態 :)
  then
    let $output1 := local:getNode($list, $num - 1, $list[$num])
    return $output1
  else if($list[$num] is $left) (: "("，つまりカッコ終了 :)
  then
    $output
  else if($list[$num] is $right) (: ()の外に移動 :)
  then
    $output
  else if($list[$num]/@type = "N")
  then
    let $output1 := local:getNode($list, $num - 1, ($list[$num], $output))
    return $output1
  else
    $output
};
:)

(: ()から出る場所を調べる関数 :)
declare function local:exitParantheses ($list as node()*, $num as xs:integer, $level as xs:integer)
as xs:integer
{
  let $result := (
    if($num = 0)
    then
      0
    else if ($list[$num] is $left)  (: "("が見つかればカッコの中 :)
    then
      local:exitParantheses($list, $num - 1, $level - 1)
    else if ($list[$num] is $right)
    then
      let $exitNum := local:exitParantheses ($list, $num - 1, $level + 1)
      return $exitNum
    else if ($list[$num]/@type = "N" and $level = 0)
    then
      $num
    else
      local:exitParantheses($list, $num - 1, $level)
  )
  return $result
};

declare function local:searchTerminal ($list as node()*, $num as xs:integer)
as xs:integer
{
  if (fn:empty($list[$num]))
  then
    0
  else
    let $num1 := (
                  if ($list[$num]/@type = "T")
                  then
                    $num
                  else
                    let $num2 := local:searchTerminal($list, $num + 1)
                    return
                      $num2
                  )
    return $num1
};

(: ポインタを親に移動するための関数 :)
declare function local:gotoparent ($list as node()*)
as node()*
{
  let $current := $list[fn:last()]
  let $output := (
                  if ($current/parent::*/@type = "N") (: 親が非終端記号の場合 :)(: rankがいくつの非終端記号によって変わる :)
                  then
                    if(fn:count($current/preceding-sibling::*) = 0)
                    then  local:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]))
                    else if(fn:count($current/preceding-sibling::*) = 1)
                    then  local:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]))
                    else if(fn:count($current/preceding-sibling::*) = 2)
                    then  local:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]))
                    else if(fn:count($current/preceding-sibling::*) = 3)
                    then  local:gotoparent(($list[fn:position() < fn:last()], $current/parent::*, fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]))
                    else ()
                  else if($current/parent::*/@type="N_root")  (: 親が非終端記号の部分木の頂点の場合 :)
                  then
                    let $current1 := $list[fn:last() - 1]
                    return  local:gotoparent($list[fn:position() < fn:last()])
                  else  (: 親が終端記号の場合 :)
                    if($current is $current/parent::*/*[1]) (: first child or next sibling:)
                    then  ($list[fn:position() < fn:last()], $current/parent::*)
                    else  local:gotoparent(($list[fn:position() < fn:last()], $current/parent::*))
      )
  return $output
};


(:child軸の関数:)
(: $listはtrie木 :)
declare function local:child ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  return  let $resultList := local:SearchChild(local:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しchildを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return
                  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:child-next($list, $newNum, $label, $resultList)
                    return $output1
};

(: 2個目以降のchild軸 :)
(: $listはtrie木 :)
declare function local:child-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $resultList := local:SearchChild(local:getList($list, $num, ()), $label, $output) (: getListでリストを作成しchildを探す :)
  let $newNum := local:searchTerminal($list, $num + 1)
  return
    if ($newNum = 0)
    then
      $resultList
    else
      let $output1 := local:child-next($list, $newNum, $label, $resultList)
      return $output1
};

(: 実際にchildを探す関数 :)
(: $listはtrie木から一つの経路を抽出したもの :)
declare function local:SearchChild ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if (fn:empty($current/*[1]))
          then $output
          else local:SearchChild-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output)

};

declare function local:SearchChild-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  let $output1 := ( 
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  local:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                    else  $output
                  )
  return  if (fn:empty($current/*[2]))
          then $output1
          else local:SearchChild-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output1)
};

declare function local:descendant ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  return  let $resultList := local:SearchDescendant(local:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しdescendantを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:descendant-next($list, $newNum, $label, $resultList)
                    return $output1
};

declare function local:descendant-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  fn:trace((),"=================================="),
  let $resultList := local:SearchDescendant(local:getList($list, $num, ()), $label, $output) (: getListでリストを作成しchildを探す :)
  let $newNum := local:searchTerminal($list, $num + 1)
  return
    if ($newNum = 0)
    then
      $resultList
    else
      let $output1 := local:descendant-next($list, $newNum, $label, $resultList)
      return $output1
};

declare function local:SearchDescendant ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list) (: 非終端か変数　-> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if (fn:empty($current/*[1]))
          then $output
          else local:SearchDescendant-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output)  (: last > position は、カレントノードだけ置き換えるため :)
};

declare function local:SearchDescendant-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list) (: 非終端か変数　-> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  let $output1 := ( 
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  (fn:trace((),"get descendant"),local:setDDOlist($output, $newList, 1, 1)) (: TRIE木に登録 :)
                    else  $output
                  )
  return  (
          let $output-left := (if (fn:empty($current/*[1])) (: 深さ優先 :)
                               then $output1
                               else local:SearchDescendant-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output1)  (: last > position は、カレントノードだけ置き換えるため :)
                              )
          return  if (fn:empty($current/*[2]))
                  then $output-left
                  else local:SearchDescendant-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output-left)  (: last > position は、カレントノードだけ置き換えるため :)
          )
};

(: self軸 :)
declare function local:self ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  return  let $resultList := local:SearchSelf(local:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しchildを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return
                  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:self-next($list, $newNum, $label, $resultList)
                    return $output1
};

declare function local:self-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $resultList := local:SearchSelf(local:getList($list, $num, ()), $label, $output) (: getListでリストを作成しchildを探す :)
  let $newNum := local:searchTerminal($list, $num + 1)
  return
    if ($newNum = 0)
    then
      $resultList
    else
      let $output1 := local:self-next($list, $newNum, $label, $resultList)
      return $output1
};

declare function local:SearchSelf ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list) (: 非終端か変数　-> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
          then  local:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
          else  $output
};

(: descentdant-or-self軸 :)
declare function local:descendant-or-self ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  return  let $resultList := local:SearchDescendant(local:getList($list, $startNum, ()), $label, local:self($list, $label)) (: getListでリストを作成しdescendantを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:descendant-next($list, $newNum, $label, $resultList)
                    return $output1
};

(: parent軸 :)

declare function local:parent ($list as node()*, $label as xs:string)
as node()*
{
    let $startNum := local:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
    return  let $resultList := local:SearchParent(local:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しparentを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return
                  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:parent-next($list, $newNum, $label, $resultList)
                    return $output1
};

declare function local:parent-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $resultList := local:SearchParent(local:getList($list, $num, ()), $label, $output) (: getListでリストを作成しparentを探す :)
  let $newNum := local:searchTerminal($list, $num + 1)
  return
    if ($newNum = 0)
    then
      $resultList
    else
      let $output1 := local:parent-next($list, $newNum, $label, $resultList)
      return $output1
};

declare function local:SearchParent ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:gotoparent($list) (: 非終端か変数　-> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if ($current/@type = "root")
          then  if ($label = "*")
                then local:setDDOlist($output, $current/*[2], 1, 1)
                else $output
          else  if (fn:name($current) = $label or $label = "*")
                then local:setDDOlist($output, $newList, 1, 1)
                else $output
};

(: ancestor軸 :)
declare function local:ancestor ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  return  let $resultList := local:SearchAncestor(local:getList($list, $startNum, ()), $label, ()) (: getListでリストを作成しchildを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return
                  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:ancestor-next($list, $newNum, $label, $resultList)
                    return $output1
};

declare function local:ancestor-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $resultList := local:SearchAncestor(local:getList($list, $num, ()), $label, $output) (: getListでリストを作成しparentを探す :)
  let $newNum := local:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then
            $resultList
          else
            let $output1 := local:ancestor-next($list, $newNum, $label, $resultList)
            return $output1
};

declare function local:SearchAncestor ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:gotoparent($list) (: 非終端か変数　-> 終端 :)
  let $current := $newList[fn:last()] (: カレントノード :)
  return  if ($current/@type = "root")
          then  $output
          else  let $output1 := (
                                 if (fn:name($current) = $label or $label = "*")
                                 then local:setDDOlist($output, $newList, 1, 1)
                                 else $output
                                )
                return local:SearchAncestor($newList, $label, $output1)
                
};

(: ancestor-or-self軸 :)
declare function local:ancestor-or-self ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1) (:最初に対象とするノードを記憶:)
  return  let $resultList := local:SearchAncestor(local:getList($list, $startNum, ()), $label, local:self($list, $label)) (: getListでリストを作成しchildを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return
                  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:ancestor-next($list, $newNum, $label, $resultList)
                    return $output1
};

(: following-sibling軸 :)
declare function local:following-sibling ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1)
  return  let $resultList := local:SearchFollowingSibling(local:getList($list, $startNum, ()), $label, ())
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return  if ($newNum = 0)
                  then  $resultList
                  else  let $output1 := local:following-sibling-next($list, $newNum, $label, $resultList)
                  return $output1
};

declare function local:following-sibling-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $resultList := local:SearchFollowingSibling(local:getList($list, $num, ()), $label, $output)
  let $newNum := local:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  let $output1 := local:following-sibling-next($list, $newNum, $label, $resultList)
                return $output1
};

declare function local:SearchFollowingSibling ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if (fn:empty($current/*[2]))
          then $output
          else local:SearchFollowingSibling-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output)

};

declare function local:SearchFollowingSibling-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  let $output1 := ( 
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  local:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                    else  $output
                  )
  return  if (fn:empty($current/*[2]))
          then $output1
          else local:SearchFollowingSibling-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output1)
};

(: following軸 :)
declare function local:following ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1)
  return  let $resultList := local:SearchFollowing(local:getList($list, $startNum, ()), $label, ())
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return  if ($newNum = 0)
                  then  $resultList
                  else  let $output1 := local:following-next($list, $newNum, $label, $resultList)
                  return $output1
};

declare function local:following-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $resultList := local:SearchFollowing(local:getList($list, $num, ()), $label, $output)
  let $newNum := local:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)
          then  $resultList
          else  let $output1 := local:following-next($list, $newNum, $label, $resultList)
                return $output1
};

declare function local:SearchFollowing ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $current := $list[fn:last()]
  let $output1 := local:SearchDescendant($list, $label, $output)
  return  if (fn:empty($current/*[2]))
          then local:SearchFollowing-parent(local:gotoparent($list), $label, $output1)
          else local:SearchFollowing-main(($list[fn:last() > fn:position()], $current/*[2]), $label, $output1)
};

declare function local:SearchFollowing-parent ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $current := $list[fn:last()]
  return  if ($current/@type = "root")
          then  $output
          else  if (fn:empty($current/*[2]))
                then local:SearchFollowing-parent(local:gotoparent($list), $label, $output)
                else local:SearchFollowing-main(($list[fn:last() > fn:position()], $current/*[2]), $label, $output)
};

declare function local:SearchFollowing-main ($list as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  let $output1 := (
                    if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                    then  local:setDDOlist($output, $newList, 1, 1)
                    else  $output
                  )
  let $output2 := local:SearchDescendant($newList, $label, $output1)
  return  if (fn:empty($current/*[2]))
          then  local:SearchFollowing-parent(local:gotoparent($newList), $label, $output2)
          else  local:SearchFollowing-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output2)
};

(: preceding-sibling軸 :)
declare function local:preceding-sibling ($list as node()*, $label as xs:string)
as node()*
{
  let $startNum := local:searchTerminal($list, 1)  (: 最初に対象とするノードを記憶 :)
  let $newList := local:getList($list, $startNum, ())
  let $parentlist := local:gotoparent($newList)
  return  let $resultList := local:SearchPrecedingSibling($parentlist, $label, (), $newList[fn:last()]) (: getListでリストを作成しchildを探す :)
          let $newNum := local:searchTerminal($list, $startNum + 1)
          return
                  if ($newNum = 0)
                  then
                    $resultList
                  else
                    let $output1 := local:preceding-sibling-next($list, $newNum, $label, $resultList)
                    return $output1
};

(: 2個目以降のchild軸 :)
(: $listはtrie木 :)
declare function local:preceding-sibling-next ($list as node()*, $num as xs:integer, $label as xs:string, $output as node()*)
as node()*
{
  let $newList := local:getList($list, $num, ())
  let $parentlist := local:gotoparent($newList)
  let $resultList := local:SearchPrecedingSibling($parentlist, $label, $output, $newList[fn:last()]) (: getListでリストを作成しchildを探す :)
  let $newNum := local:searchTerminal($list, $num + 1)
  return
    if ($newNum = 0)
    then
      $resultList
    else
      let $output1 := local:preceding-sibling-next($list, $newNum, $label, $resultList)
      return $output1
};

(: 実際にchildを探す関数 :)
(: $listはtrie木から一つの経路を抽出したもの :)
declare function local:SearchPrecedingSibling ($list as node()*, $label as xs:string, $output as node()*, $newNode as node())
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if ($current/*[1] is $newNode)
          then $output
          else local:SearchPrecedingSibling-main(($newList[fn:last() > fn:position()], $current/*[1]), $label, $output, $newNode)

};

declare function local:SearchPrecedingSibling-main ($list as node()*, $label as xs:string, $output as node()*, $newNode as node())
as node()*
{
  let $newList := local:type-check-new($list)
  let $current := $newList[fn:last()]
  return  if ($current is $newNode)
          then $output
          else  let $output1 := ( 
                                  if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                                  then  local:setDDOlist($output, $newList, 1, 1) (: TRIE木に登録 :)
                                  else  $output
                                )
                return  if (fn:empty($current/*[2]))
                        then $output1
                        else local:SearchPrecedingSibling-main(($newList[fn:last() > fn:position()], $current/*[2]), $label, $output1, $newNode)
};

(: 全体のリストに登録 :)
declare function local:setDDOlist($output as node()*, $list as node()*, $outputNum as xs:integer, $listNum as xs:integer)
as node()*  (: 返り値は登録後のリスト :)
{
  if (fn:empty($output))
  then $list
  else if (fn:empty($list[$listNum]))
  then  (fn:trace((),"DDO check"),$output)
  else
  let $output1 := ( if ($output[$outputNum] is $list[$listNum]) (: 同じノードの場合 :)
                    then  
                      local:setDDOlist($output, $list, $outputNum + 1, $listNum + 1)
                    else  if ($output[$outputNum] is $left) (: "("の場合，()内の処理に移行 :)
                    then  
                      local:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum, fn:false())
                    else    (: ノードが違う場合，分岐を作成 :)
                      if ($output[$outputNum] << $list[$listNum]) (: 文書順かどうかの確認 :)
                      then
                        ($output[$outputNum > fn:position()], $left, $left, $output[$outputNum <= fn:position()], $right, $left, $list[$listNum <= fn:position()], $right, $right)  (: result :)
                      else
                        ($output[$outputNum > fn:position()], $left, $left, $list[$listNum <= fn:position()], $right, $left, $output[$outputNum <= fn:position()], $right, $right)  (: result :)
                  )
  return $output1
};






(: ()内の処理 :)
(: flagは()内に分岐できるノードがあるときtrueに :)
declare function local:setDDOlist-Parantheses($output as node()*, $list as node()*, $outputNum as xs:integer, $listNum as xs:integer, $flag as xs:boolean)
as node()*
{
  if (fn:empty($list[$listNum]))
  then  (fn:trace((),"DDO check"),$output)
  else
    let $output1 := (
                        if($output[$outputNum] is $list[$listNum])  (: 同じノードの場合 :)
                        then
                          local:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum + 1, fn:true())
                        else if ($output[$outputNum] is $left)  (: "("の場合 :)
                        then
                          local:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum, fn:false())
                        else if ($output[$outputNum] is $right)
                        then
                        	$output
                        else if($flag)    (: ()内に新たに()の分岐が必要な場合 :)
                        then
                          let $nextoutputNum := local:nextBranch($output, $outputNum + 1, 0)
                          return
                            if ($output[$outputNum] << $list[$listNum])
                            then
                              ($output[$outputNum > fn:position()], $left, $left, $output[$outputNum <= fn:position() and fn:position() < $nextoutputNum - 1], $right, $left, $list[$listNum <= fn:position()], $right, $right, $output[$nextoutputNum - 1 <= fn:position()])  (: result :)
                            else
                              ($output[$outputNum > fn:position()], $left, $left, $list[$listNum <= fn:position()], $right, $left,  $output[$outputNum <= fn:position() and fn:position() < $nextoutputNum - 1],$right, $right, $output[$nextoutputNum - 1 <= fn:position()])  (: result :)
                        else  (: 次の分岐を検索 :)
                          if ($output[$outputNum] >> $list[$listNum])
                          then
                            ($output[$outputNum - 1 > fn:position()], $left, $list[$listNum <= fn:position()], $right, $output[$outputNum - 1 <= fn:position()])  (: result :)
                          else
                          let $outputNum1 := local:nextBranch($output, $outputNum + 1, 0)
                          return  if ($output[$outputNum1] is $right or fn:empty($output[$outputNum1])) (: 分岐終了の場合 :)
                                  then
                                    ($output[$outputNum1 > fn:position()], $left, $list[$listNum <= fn:position()], $right, $output[$outputNum1 <= fn:position()])  (: result :)
                                  else  (: 分岐が残っている場合 :)
                                    local:setDDOlist-Parantheses($output, $list, $outputNum1, $listNum, fn:false())
                    )
    return $output1
};

(: 次の分岐を検索する関数 :)
declare function local:nextBranch ($output as node()*, $outputNum as xs:integer, $level as xs:integer)
as xs:integer
{
  (:if ($level = 0)
  then
    if ($output[$outputNum] is $left)
    then
      local:nextBranch($output, $outputNum + 1, $level + 1)
    else if ($output[$outputNum] is $right)
    then
      if ($output[$outputNum + 1] is $right)
      then
        $outputNum + 1
      else
        $outputNum + 2
    else  (: 非終端記号の場合 :)
      local:nextBranch($output, $outputNum + 1, $level)
  else  if ($output[$outputNum] is $right)
        then
          if ($level = 1) (: level1の)の後は次の分岐になる :)
          then
            if ($output[$outputNum + 1] is $right)
            then
              $outputNum + 2
            else
              $outputNum + 3
          else
            local:nextBranch($output, $outputNum + 1, $level - 1)
        else
          local:nextBranch($output, $outputNum + 1, $level)
          :)
  if (fn:empty($output[$outputNum]))
  then
    $outputNum
  else if ($output[$outputNum] is $right)
  then
    if($level = 0)
    then
      $outputNum + 1
    else
      local:nextBranch($output, $outputNum + 1, $level - 1)
  else if ($output[$outputNum] is $left)
  then
    local:nextBranch($output, $outputNum + 1, $level + 1)
  else
    local:nextBranch($output, $outputNum + 1, $level)
};

declare function local:output ($list as node()*, $num as xs:integer, $output as xs:string)
as xs:string
{
  let $output1 := (
    if (fn:empty($list[$num]))
    then
      $output
    else
      if (fn:name($list[$num]) = "left_separator")
      then
        let $output2 := local:output($list, $num + 1, fn:concat($output, "("))
        return $output2
      else if (fn:name($list[$num]) = "right_separator")
      then
        if (fn:name($list[$num + 1]) = "right_separator")
        then
          let $output2 := local:output($list, $num + 1, fn:concat($output, ")"))
          return $output2
        else
          let $output2 := local:output($list, $num + 1, fn:concat($output, "),"))
          return $output2
      else
        if (fn:name($list[$num + 1]) = "left_separator" or fn:name($list[$num + 1]) = "right_separator")
        then
          let $output2 := local:output($list, $num + 1, fn:concat($output, fn:name($list[$num])))
          return $output2
        else
          let $output2 := local:output($list, $num + 1, fn:concat($output, fn:name($list[$num]), ", "))
          return $output2
    )
  return $output1

};


(:ここにファイル名を入力:)
(:declare variable $original := doc("../ex/Nasa/Nasa-r.xml");:)
declare variable $original := doc("../ex/BaseBall/BaseBall-r.xml");
(:declare variable $original := doc("../ex/Treebank/Treebank-r.xml");:)
(:declare variable $original := doc("../ex/DBLP/DBLP-r.xml");:)
      
(: //reference/source :)


(:
for $v in $original/root/S/child::*[2]/*[1]
return local:child($v,"*")
:)



local:output(
for $v in $original/root/S/child::*[2]/*[1]
return local:preceding-sibling(local:descendant($v, "TEAM"),"*")
,
1,
"START -> "
)



(: /* :)
(:
prof:time(
prof:mem(
for $v in $original/root/S/child::*[2]
return local:output(local:child(local:child(local:child(($v, $s),"*", ()),"*", ()),"_PERIOD_", ()))
)
)
:)

(:
for $v in $original/root/S/child::*[2]
return local:output(local:descendant(($v, $s), "lastName", ()))
:)



(: //○○/ancestor::○○ :)
(:
prof:time(
prof:mem(
for $v in $original/root/S/child::*[2]
return local:output(local:ancestor(local:descendant-or-self(($v, $s),"reference", ()),"dataset", ()))
)
)
:)

(: //○○/following-sibling::○○ :)
(:
prof:time(
prof:mem(
for $v in $original/root/S/child::*[2]
return local:output(local:following::sibling(local:descendant-or-self(($v, $s),"lastName", ()),"keyword", ()))
)
)
:)

(: for重ねがけ :)
(:
prof:time(
prof:mem(
for $v in $original/root/S/child::*[2]
return if 
)
)
:)