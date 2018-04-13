

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

(: 全体のリストに登録 :)
declare function local:setDDOlist($output as node()*, $list as node()*, $outputNum as xs:integer, $listNum as xs:integer)
as node()*  (: 返り値は登録後のリスト :)
{
  if (fn:empty($output))
  then $list
  else if (fn:empty($list[$listNum]))
  then  $output
  else
  let $output1 := ( if ($output[$outputNum] is $list[$listNum]) (: 同じノードの場合 :)
                    then  
                      local:setDDOlist($output, $list, $outputNum + 1, $listNum + 1)
                    else  if ($output[$outputNum] is $left) (: "("の場合，()内の処理に移行 :)
                    then  
                      local:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum, fn:false())
                    else    (: ノードが違う場合，分岐を作成 :)
                      ($output[$outputNum > fn:position()], $left, $left, $output[$outputNum <= fn:position()], $right, $left, $list[$listNum <= fn:position()], $right, $right)  (: result :)
                  )
  return $output1
};

(: ()内の処理 :)
(: flagは()内に分岐できるノードがあるときtrueに :)
declare function local:setDDOlist-Parantheses($output as node()*, $list as node()*, $outputNum as xs:integer, $listNum as xs:integer, $flag as xs:boolean)
as node()*
{
  if (fn:empty($list[$listNum]))
  then  $output
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
                          ($output[$outputNum > fn:position()], $left, $left, $output[$outputNum <= fn:position() and fn:position() < $nextoutputNum - 1], $right, $left, $list[$listNum <= fn:position()], $right, $right, $output[$nextoutputNum - 1 <=
                           fn:position()])  (: result :)
                        else  (: 次の分岐を検索 :)
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
(:declare variable $original := doc("ex/Treebank/Treebank-r.xml");:)
(:declare variable $original := doc("ex/DBLP/DBLP-r.xml");:)
      
(: //reference/source :)


(:
for $v in $original/root/S/child::*[2]/*[1]
return local:child($v,"*")
:)



local:output(
for $v in $original/root/S/child::*[2]/*[1]
return local:child(local:child(local:child(local:child($v,"*"),"*"),"*"),"*")
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