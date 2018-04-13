(:非終端記号か変数であればポインタの処理を行う関数:)
declare function local:type-check ($x as node()*)
as node()*
{
    if($x[1]/@type="N")
	 then	(:非終端記号の場合:)
		local:type-check((fn:root($x[1])/*/*[name()=fn:name($x[1])]/*[2], $x))	(:変更先が非終端記号か変数の場合のため:)
    else if($x[1]/@type="V")	(:変数の場合:)
    then	(:カレントノードを移動まえのノードに変更し，辿ってきた非終端記号のポインタから削除:)
      if(fn:name($x[1]) = "y0")	(:変数名y0の場合:)
      then	
        local:type-check(($x[2]/*[1], $x[2<position()]))	(:変更先が非終端記号か変数の場合のため:)
      else if(fn:name($x[1]) = "y1")	(:変数名y1の場合:)
      then	
        local:type-check(($x[2]/*[2], $x[2<position()]))	(:変更先が非終端記号か変数の場合のため:)
      else if(fn:name($x[1]) = "y2")	(:変数名y2の場合:)
      then	
        local:type-check(($x[2]/*[3], $x[2<position()]))	(:変更先が非終端記号か変数の場合のため:)
      else	(:変数名y3の場合:)
        local:type-check(($x[2]/*[4], $x[2<position()]))	(:変更先が非終端記号か変数の場合のため:)
    else
      $x
};

(::)
declare function local:go_to_up_N ($x as node()*)
as node()*
{
  let $current := local:current($x)	(:カレントノードのポインタ:)
  let $pointer := local:pointer($x)	(:辿ってきた非終端記号へのポインタ:)
  return
    if($current/parent::*/@type="N")
    then
      if($current is $current/parent::*/*[1])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]
        return
          local:go_to_up_N (($current, $pointer))
      else if($current is $current/parent::*/*[2])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]
        return
          local:go_to_up_N (($current, $pointer))
      else if($current is $current/parent::*/*[3])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]
        return
          local:go_to_up_N (($current, $pointer))
      else if($current is $current/parent::*/*[4])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]
        return
          local:go_to_up_N (($current, $pointer))
      else ()
    else if($current/parent::*/@type="N_root")
    then
      let $current := $pointer[fn:count($pointer)]
      let $pointer := fn:remove($pointer, fn:count($pointer))
      return
        local:go_to_up_N (($current, $pointer))
    else 
      if($current is $current/parent::*/*[1])
      then
        ($current/parent::*, $pointer)
      else
        local:go_to_up_N(($current/parent::*, $pointer))
};

declare function local:parent ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:go_to_up_N(local:type-check(local:head($x)))	(:ノードタイプをチェック:)
  return
    let $current := local:current($head)	
    let $pointer := local:pointer($head)
    return
    (if(fn:name($current) = $label)
    then
      ($current, $pointer, $s)
    else if ($label = "*")
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
    local:descendant-main($head[1]/*[1], $head[1<position()], $label)
	 ,
  (:ポインタがまだ残っていたら再帰:)
  let $tail := local:tail($x)
  return
    if(fn:empty($x))
	 then
		()
    else
      local:descendant($tail, $label)
};

declare function local:descendant-main ($current as node(), $pointer as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(($current, $pointer))
  return
    if(fn:name($head[1]) = "_")
    then
      ()
	 else (
		if(fn:name($head[1]) = $label or $label = "*")
	   then
        ($head, $s)	(:返り値:)
      else
        ()
      ,
      local:descendant-main($head[1]/*[1], $head[1<position()], $label)
      ,
      local:descendant-main($head[1]/*[2], $head[1<position()], $label)
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

declare function local:descendant-or-self ($x as node()*, $label as xs:string)
as node()*
{
  local:self(local:head($x), $label)
  ,
  local:descendant(local:head($x), $label)
  ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	 then
		local:descendant-or-self($x, $label)
    else
      ()  
};

declare function local:following-sibling ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(local:head($x))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return
      local:following-sibling-main($current/*[2], $pointer, $label)
  ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	 then
		local:following-sibling($x, $label)
    else
      ()
    
};

declare function local:following-sibling-main ($current as node(), $pointer as node()*, $label as xs:string)
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
      else 
        (if(fn:name($current) = $label or $label = "*")
        then
          ($current, $pointer, $s)
        else
          ()
          ,
          local:following-sibling-main($current/*[2], $pointer, $label)
      )
      
};

declare function local:ancestor ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:go_to_up_N(local:type-check(local:head($x)))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return
      if($current/@type="root")
      then
        ()
      else(
        if(fn:name($current) = $label or $label = "*")
        then
          ($current, $pointer, $s)
        else
          ()
      )
   ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	 then
		local:ancestor($x, $label)
    else
      ()  
      
};

declare function local:preceding-sibling ($x as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(local:head($x))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return
    if($current/parent::*/@type="N")
    then
      if($current is $current/parent::*/*[1])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]
        return
          local:preceding-sibling (($current, $pointer), $label)
      else if($current is $current/parent::*/*[2])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]
        return
          local:preceding-sibling (($current, $pointer), $label)
      else if($current is $current/parent::*/*[3])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]
        return
          local:preceding-sibling (($current, $pointer), $label)
      else if($current is $current/parent::*/*[4])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]
        return
          local:preceding-sibling (($current, $pointer), $label)
      else ()
    else if($current/parent::*/@type="N_root")
    then
      let $current := $pointer[fn:count($pointer)]
      let $pointer := fn:remove($pointer, fn:count($pointer))
      return
        local:preceding-sibling (($current, $pointer), $label)
    else 
      if($current is $current/parent::*/*[1])
      then
        ()
      else
        (local:preceding-sibling (($current/parent::*, $pointer), $label)
        ,
        if(fn:name($current/parent::*) = $label or $label = "*")
        then
          ($current/parent::*, $pointer, $s)
        else
          ()
       )
     ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	  then
		  local:preceding-sibling($x, $label)
    else
      () 
};

declare function local:following ($x as node()*, $label as xs:string)
as node()*
{
  let $head := (local:type-check(local:head($x)))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return
      (
       
       let $parent := local:go_to_up_N(local:type-check(($current, $pointer)))
       return
        if ($parent[1]/@type = "root")
        then
          ()
        else
          local:following-par($parent, $label)
        ,
        local:following-sibling(($current, $pointer), $label)
        )
   ,
  (:ポインタがまだ残っていたら再帰:)
  let $x := local:tail($x)
  return
    if($x)
	  then
		  local:following($x, $label)
    else
      () 
     
};

declare function local:following-par ($x as node()*, $label as xs:string)
as node()*
{
  let $head := (local:type-check(local:head($x)))
  return
	 (:ポインタを分離:)
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return
      if($current/@type="root")
      then
        ()
      else
       let $parent := local:go_to_up_N(local:type-check(($current, $pointer)))
       return
        (if ($parent[1]/@type = "root")
        then
          ()
        else
          local:following-par($parent, $label)
        ,
        local:following-sibling(($current,$pointer), $label)
      )
};

declare function local:preceding ($x as node()*, $label as xs:string)
as node()*
{
  
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
     (if($head[1]/@type = "root")
      then
        local:output(($head[1]/*[1], $head[1<position()], $s))
      else
          let $starttree := ($start, element {"S"} {
            element {"S"} {
              attribute {"type"} {"start"}
            },
            element {"S"} {
              attribute {"type"} {"root"}, 
              element {fn:name($head[1])}{
                (local:variable_replace2($head[1]/*[1], $head[1<position()]))
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
                 (($starttree,
                 local:create_N($starttree, ()))))
            )      
};

(:非終端記号のサブツリーを作成する関数:)
declare function local:create_N($start as node()*, $list as node()*)
as node()*
{
  if($start)
  then
    let $list := local:N_list($start[1]/descendant::*[@type="N"][1], $list)
    return
      local:create_N(fn:remove($start, 1), $list)
  else
    $list
};

declare function local:variable_replace2($current as node(), $pointer as node()*)
as node()
{
    if(fn:name($current) = "y0")
    then
      local:variable_replace2($pointer[1]/*[1], $pointer[1<position()])
    else if(fn:name($current) = "y1")
    then
      local:variable_replace2($pointer[1]/*[2], $pointer[1<position()])
    else if(fn:name($current) = "y2")
    then
      local:variable_replace2($pointer[1]/*[3], $pointer[1<position()])
    else if(fn:name($current) = "y3")
    then
      local:variable_replace2($pointer[1]/*[4], $pointer[1<position()])
    else
      element {fn:name($current)} {
        if($current/@type = "N")
        then
          attribute {"type"} {"N"}
        else if($current/@type = "T")
        then
          attribute {"type"} {"T"}
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
declare function local:N_list($node as node(), $list as node()*)
as node()*
{
  let $list := local:check_duplication($node, $list, $list) (:重複のチェックかつ登録:)
  return
    if($node/descendant::*/@type="N") (:同じサブツリー内に非終端記号が存在すれば:)
    then
      let $list := local:N_list($node/descendant::*[@type="N"][1], $list) (:再帰:)
      return
        $list
    else
      if($node/following-sibling::*[1]/descendant-or-self::*/@type="N") (:同じサブツリー内に非終端記号が存在すれば:)
      then
        let $list := local:N_list($node/following-sibling::*[1]/descendant-or-self::*[@type="N"][1], $list) (:再帰:)
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
       if($original/*/*[name()=fn:name($node)]/*[2]/descendant-or-self::*/@type="N")  (:登録した非終端のサブツリーに非終端が出現したら:)
       then
         let $list := local:N_list($original/*/*[name()=fn:name($node)]/*[2]/descendant-or-self::*[@type="N"][1], $list)  (:サブツリー内で再帰:)
         return
           $list
       else
         $list
};

declare function local:result-check($x as node()*, $list as node()*)
as node()*
{
  let $head := local:head($x)
  return
    if($list)
    then
      let $list := ($list, local:loop-check($head, $list))
      return
        if(local:tail($x))
        then
          local:result-check(local:tail($x), $list)
        else
          $list
    else
      let $list := ($head, $s)
      return
       (:ポインタがまだ残っていたら再帰:)
        let $x := local:tail($x)
        return
          if($x)
	        then
		        local:result-check($x, $list)
          else
            $list
};

declare function local:loop-check($x as node()*, $list as node()*)
as node()*
{
  if($x[1] is local:head($list)[1])
  then
    ()
  else
    (
      if(local:tail($list))
      then
        local:loop-check($x, local:tail($list))
      else
        ($x, $s)
    )
};

(:ここにファイル名を入力:)
declare variable $original := doc("ex/BaseBall/BaseBall-r.xml");
		  
(: //reference/source :)
for $v in $original/root/S/child::*[2]
return local:output(local:descendant(($v,$s),"PLAYER"))