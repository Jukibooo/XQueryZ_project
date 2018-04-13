(:非終端記号か変数であればポインタの処理を行う関数:)
declare function local:type-check ($x as node()*)
as node()*
{
  let $current := local:current($x)	(:カレントノードのポインタ:)
  let $pointer := local:pointer($x)	(:辿ってきた非終端記号へのポインタ:)
  return
    if($current/@type="nonterminal")
    then	(:非終端記号の場合:)
      let $pointer := ($pointer, $current)	(:辿ってきた非終端記号へのポインタへ追加:)
      let $current := fn:root($current)/*/*[name()=fn:name($current)]/*[2]	(:カレントノードを非終端記号の部分木の頂点に変更:)
      return
        local:type-check(($current, $pointer))	(:変更先が非終端記号か変数の場合のため:)
    else if($current/@type="variable")	(:変数の場合:)
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

(::)
declare function local:go_to_up_nonterminal ($x as node()*)
as node()*
{
  let $current := local:current($x)	(:カレントノードのポインタ:)
  let $pointer := local:pointer($x)	(:辿ってきた非終端記号へのポインタ:)
  return
    if($current/parent::*/@type="nonterminal")
    then
      if($current is $current/parent::*/*[1])
      then
        let $current := $pointer[fn:count($pointer)]//*[name="y0"]
        let $pointer := fn:remove($pointer, fn:count($pointer))
        return
          local:go_to_up_nonterminal (($current, $pointer))
      else if($current is $current/parent::*/*[2])
      then
        let $current := $pointer[fn:count($pointer)]//*[name="y1"]
        let $pointer := fn:remove($pointer, fn:count($pointer))
        return
          local:go_to_up_nonterminal (($current, $pointer))
      else if($current is $current/parent::*/*[3])
      then
        let $current := $pointer[fn:count($pointer)]//*[name="y2"]
        let $pointer := fn:remove($pointer, fn:count($pointer))
        return
          local:go_to_up_nonterminal (($current, $pointer))
      else ()
    else if($current/parent::*/@type="nonterminal_root")
    then
      let $current := $pointer[fn:count($pointer)]
      let $pointer := fn:remove($pointer, fn:count($pointer))
      return
        local:go_to_up_nonterminal (($current, $pointer))
    else
      if($current is $current/parent::*/*[1])
      then
        ($current/parent::*, $pointer)
      else
        local:go_to_up_nonterminal(($current/parent::*, $pointer))
};

declare function local:parent ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(local:head($x))	(:ノードタイプをチェック:)
  return
    (if(fn:name(local:go_to_up_nonterminal($head)[1]) = $label or $label = "*")
    then
      local:go_to_up_nonterminal($head)
    else
      ()
    ,
      (:ポインタがまだ残っていたら再帰:)
    let $x := local:tail($x)
    return
      if($x)
	    then
	    	local:parent($x, $label)
      else
        ()
    )
};

declare variable $s := element {"separator"} {};	(:separator:)
	 
(:ポインタの集合の先頭を取得:)
declare function local:head ($x as node()*)
as node()* {
  if ($x[1] is $s)	(:separatorかどうかチェック:) 
  then ()
  else ($x[1],local:head($x[1<position()]))
};
	 
(:ポインタの集合の先頭以外を取得:)
declare function local:tail ($x as node()*)
as node()* {
  if ($x[1] is $s)	(:separatorかどうかチェック:) 
  then $x[1<position()]
  else local:tail($x[1<position()])
};
	 
(:カレントノードのポインタを取得:)
declare function local:current ($x as node()*)
as node()
{
  $x[1]
};
	 
(:辿ってきた非終端記号のポインタを取得:)
declare function local:pointer($x as node()*) as node()*
{
  $x[1<position()]
};
	 
(:child軸の関数:)
declare function local:child ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(local:head($x))	(:ノードタイプをチェック:)
  return
	 (:ポインタを分離:)
    let $current := local:current($head)	
    let $pointer := local:pointer($head)
    return
      local:child-main($current/*[1], $pointer, $label)
	 ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	 then
		local:child($x, $label)
    else
      ()
};

declare function local:child-main ($current as node(), $pointer as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(($current, $pointer))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return 
      if(fn:name($current) = "_")
      then
        ()
		else (
		  if(fn:name($current) = $label or $label = "*")
		  then
          ($current, $pointer, $s)	(:返り値:)
        else
          ()
        ,
        local:child-main($current/*[2], $pointer, $label)
    )
};

(:descendant軸の関数:)
declare function local:descendant ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(local:head($x))	(:ノードタイプをチェック:)
  return
	 (:ポインタを分離:)
    let $current := local:current($head)	
    let $pointer := local:pointer($head)
    return
      local:descendant-main($current/*[1], $pointer, $label)
	 ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	 then
		local:descendant($x, $label)
    else
      ()
};

declare function local:descendant-main ($current as node(), $pointer as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(($current, $pointer))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return 
      if(fn:name($current) = "_")
      then
        ()
		else (
		  if(fn:name($current) = $label or $label = "*")
		  then
          ($current, $pointer, $s)	(:返り値:)
        else
          ()
        ,
        local:descendant-main($current/*[1], $pointer, $label)
        ,
        local:descendant-main($current/*[2], $pointer, $label)
    )
};

declare function local:self ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(local:head($x))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return
      if(fn:name($current) = $label or $label = "*")
      then
        ($current, $pointer, $s)
      else
        ()
  ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	 then
		local:self($x, $label)
    else
      ()
};

declare function local:output($x as node()*) 
as node()*
{
  element {"root"} {
    local:start_output($x,())
  }
};

declare function local:start_output ($x as node()*, $start)
as node()*
{
    let $head := local:type-check(local:head($x))
  return
	 (:ポインタを分離:) 
    let $current := local:current($head)
    let $pointer := local:pointer($head) 
    return 
     (if($current/@type = "root")
      then
        local:output(($current/*[1], $pointer, $s))
      else
          let $starttree := ($start, element {"S"} {
            element {"S"} {
              attribute {"type"} {"start"}
            },
            element {"S"} {
              attribute {"type"} {"root"}, 
              element {fn:name($current)}{
                local:variable_replace2($current/*[1], $pointer)
                ,
                <_/>
              } 
            }
          })
          return
             (  (:ポインタがまだ残っていれば再帰:)
               if(local:tail($x))
               then
                 local:start_output(local:tail($x), $starttree)
               else
                (:starttreeをすべて登録できたら:)
                 ($starttree,
                 local:create_nonterminal($starttree, ())))
            )      
};

(:非終端記号のサブツリーを作成する関数:)
declare function local:create_nonterminal($start as node()*, $list as node()*)
as node()*
{
  if($start)
  then
    let $list := local:nonterminal_list($start[1]/descendant::*[@type="nonterminal"][1], $list)
    return
      local:create_nonterminal(fn:remove($start, 1), $list)
  else
    $list
};

declare function local:variable_replace2($current as node(), $pointer as node()*)
as node()
{
    if(fn:name($current) = "y0")
    then
      local:variable_replace2($pointer[fn:count($pointer)]/*[1], fn:remove($pointer, fn:count($pointer)))
    else if(fn:name($current) = "y1")
    then
      local:variable_replace2($pointer[fn:count($pointer)]/*[2], fn:remove($pointer, fn:count($pointer)))
    else if(fn:name($current) = "y2")
    then
      local:variable_replace2($pointer[fn:count($pointer)]/*[3], fn:remove($pointer, fn:count($pointer)))
    else if(fn:name($current) = "y3")
    then
      local:variable_replace2($pointer[fn:count($pointer)]/*[4], fn:remove($pointer, fn:count($pointer)))
    else
      element {fn:name($current)} {
        if($current/@type = "nonterminal")
        then
          attribute {"type"} {"nonterminal"}
        else if($current/@type = "terminal")
        then
          attribute {"type"} {"terminal"}
        else ()
        ,
        if($current/*[1])
        then
          local:variable_replace2($current/*[1], $pointer)
        else ()
        ,
        if($current/*[2])
        then
          local:variable_replace2($current/*[2], $pointer)
        else ()
      }
};


(:非終端記号のリストを作成する関数:)
declare function local:nonterminal_list($node as node(), $list as node()*)
as node()*
{
  let $list := local:check_duplication($node, $list, $list) (:重複のチェックかつ登録:)
  return
    if($node/descendant::*/@type="nonterminal") (:同じサブツリー内に非終端記号が存在すれば:)
    then
      let $list := local:nonterminal_list($node/descendant::*[@type="nonterminal"][1], $list) (:再帰:)
      return
        $list
    else
      if($node/following-sibling::*[1]/descendant-or-self::*/@type="nonterminal") (:同じサブツリー内に非終端記号が存在すれば:)
      then
        let $list := local:nonterminal_list($node/following-sibling::*[1]/descendant-or-self::*[@type="nonterminal"][1], $list) (:再帰:)
        return
          $list
      else
        $list
};

(:重複をチェックして登録する関数:)
declare function local:check_duplication($node as node(), $list as node()*, $current_list as node()*)
as node()*
{
  if($current_list) (:リストに残りがあれば:)
  then
    if(fn:name($current_list[1]) =  fn:name($node))
    then
      $list  (:リストに存在していれば登録しない:)
    else
      local:check_duplication($node, $list, fn:remove($current_list, 1))  (:リストの一つ後ろを検索:)
  else  (:リストをすべて検索し終わったら:)
    let $list := ($list, $original/*/*[name()=fn:name($node)])  (:リストに登録:)
    return
       if($original/*/*[name()=fn:name($node)]/*[2]/descendant-or-self::*/@type="nonterminal")  (:登録した非終端のサブツリーに非終端が出現したら:)
       then
         let $list := local:nonterminal_list($original/*/*[name()=fn:name($node)]/*[2]/descendant-or-self::*[@type="nonterminal"][1], $list)  (:サブツリー内で再帰:)
         return
           $list
       else
         $list
};

(:ここにファイル名を入力:)
declare variable $original := doc("DBLP-r.xml");

for $v in $original/root/S/child::*[2]
return local:output(local:descendant(($v,$s),"article"))