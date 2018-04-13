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

declare function local:type-check-no-recursion ($x as node()*) (:1段階しかtype-checkしない:)
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
        ($current, $pointer)
    else if($current/@type="V")	(:変数の場合:)
    then
      if(fn:name($current) = "y0")	(:変数名y0の場合:)
      then
        let $current := $pointer[fn:count($pointer)]/*[1]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            ($current, $pointer)
      else if(fn:name($current) = "y1")	(:変数名y1の場合:)
      then
        let $current := $pointer[fn:count($pointer)]/*[2]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            ($current, $pointer)
      else if(fn:name($current) = "y2")	(:変数名y2の場合:)
      then
        let $current := $pointer[fn:count($pointer)]/*[3]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            ($current, $pointer)
      else
        let $current := $pointer[fn:count($pointer)]/*[4]	(:カレントノードを移動まえのノードに変更:)
        return
          let $pointer := fn:remove($pointer, fn:count($pointer))	(:辿ってきた非終端記号のポインタから削除:)
          return
            ($current, $pointer)
    else
      ($current, $pointer)
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

declare function local:parent-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else (let $head := local:go_to_up_N(local:type-check(local:head($x)))	(:ノードタイプをチェック:)
  	   let $current := local:current($head)	
       let $pointer := local:pointer($head)
       return let $output1 := ($output, if(fn:name($current) = $label or $label = "*")
    	  						        then ($current, $pointer, $s)
							            else ()
							  )
    	      return local:parent-tr(local:tail($x), $label, $output1)
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
	 
declare function local:head-tr ($x as node()*, $output as node()*)
as node()* {
  if ($x[1] is $s)	(:separatorかどうかチェック:) 
  then $output
  else local:head-tr($x[1<position()], ($output, $x[1]))
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
  if (fn:empty($x))
  then ()
  else (
        let $head := local:type-check(local:head($x))	(:ノードタイプをチェック:)
        let $current := local:current($head)	
        let $pointer := local:pointer($head)
        return if ($current/*[1])
               then local:child-main($current/*[1], $pointer, $label)
               else ()
        ,
        local:child(local:tail($x), $label)
       )
};

declare function local:child-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if (fn:empty($x))
  then $output
  else let $head := local:type-check(local:head-tr($x,()))	(:ノードタイプをチェック:)
       let $current := local:current($head)	
       let $pointer := local:pointer($head)
       let $output1 := ($output, if ($current/*[1])
                                 then local:child-main-tr($current/*[1], $pointer, $label, ())
                                 else ())
       return local:child-tr(local:tail($x), $label, $output1)
};

declare function local:child-main ($current as node(), $pointer as node()*, $label as xs:string)
as node()*
{
  let $head := local:type-check(($current, $pointer))
	 (:ポインタを分離:)
  let $current := local:current($head)
  let $pointer := local:pointer($head)
  return (if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
          then ($current, $pointer, $s)	(:返り値:)
          else ()
         ,
          if ($current/*[2])
	  	  then local:child-main($current/*[2], $pointer, $label)
          else ()
         )
};

declare function local:child-main-tr ($current as node(), $pointer as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $head := local:type-check(($current, $pointer))
	 (:ポインタを分離:)
  let $current := local:current($head)
  let $pointer := local:pointer($head)
  let $output1 := ($output, if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                            then ($current, $pointer, $s)	(:返り値:)
                            else ())
  return if ($current/*[2])
	 then local:child-main-tr($current/*[2], $pointer, $label, $output1)
         else $output1
};

(:descendant軸の関数:)
declare function local:descendant ($x as node()*, $label as xs:string)
as node()*
{
  if (fn:empty($x))
  then ()
  else (
        let $head := local:head($x)  (:ここではtype-checkしないことにしてみた:)
        let $current := local:current($head)	
        let $pointer := local:pointer($head)
        let $descendants := $current/*[1]/descendant-or-self::*  (:fncsでfirst child以下:)
        return for $descendant in $descendants
               return local:descendant-main($descendant, $pointer, $label)
        ,
        local:descendant(local:tail($x), $label)
       )
};

declare function local:descendant-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if (fn:empty($x))
  then $output
  else (
        let $head := local:head-tr($x,())  (:ここではtype-checkしないことにしてみた:)
        let $current := local:current($head)	
        let $pointer := local:pointer($head)
        let $descendants := $current/*[1]/descendant-or-self::*  (:fncsでfirst child以下:)
        let $output1 := ($output, for $descendant in $descendants
                                  return local:descendant-main($descendant, $pointer, $label))
        return local:descendant-tr(local:tail($x), $label, $output1)
       )
};

declare function local:descendant-main ($current as node(), $pointer as node()*, $label as xs:string)
as node()*
{
  if ($current/@type = "T")
  then if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
       then ($current, $pointer, $s)	(:返り値:)
       else ()
  else let $head := local:type-check-no-recursion(($current, $pointer)) (:終端記号以外だったら1ステップだけ展開してcurrentとpointerを計算しなおす:)
       let $current1 := local:current($head)
       let $pointer1 := local:pointer($head)
       let $descendants := if ($current/@type = "V")
                           then $current1/descendant-or-self::*
                           else $current1/descendant-or-self::*[@type!="V"]
       return for $descendant in $descendants
              return local:descendant-main($descendant, $pointer1, $label)
};

(:
declare function local:descendant-main-tr ($current as node(), $pointer as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $output1 := ($output, if ($current/@type = "T")
                            then if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                                 then ($current, $pointer, $s)	(:返り値:)
                                 else ()
                            (:終端記号以外だったら1ステップだけ展開してcurrentとpointerを計算しなおす:)
                            else let $head := local:type-check-no-recursion(($current, $pointer))
                                 let $current1 := local:current($head)
                                 let $pointer1 := local:pointer($head)
                                 let $descendants := if ($current/@type = "V")
                                                     then $current1/descendant-or-self::*
                                                     else $current1/descendant-or-self::*[@type!="V"]
                                 return for $descendant in $descendants
                                        return local:descendant-main-tr($descendant, $pointer1, $label, $output1))
};
:)

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

declare function local:self-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if (fn:empty($x))
  then $output
  else (
       let $head := local:head-tr($x,())  (:ここではtype-checkしないことにしてみた:)
       let $current := local:current($head)	
       let $pointer := local:pointer($head)
	   let $output1 := ($output, if(fn:name($current) = $label or $label = "*")
	   							 then ($current, $pointer, $s)
								 else ()
					   )
	   return local:self-tr(local:tail($x), $label, $output1)
	   )
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

declare function local:descendant-or-self-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else (
  		let $head := local:head-tr($x,())  (:ここではtype-checkしないことにしてみた:)
        let $current := local:current($head)	
        let $pointer := local:pointer($head)
		return if($current/@type="root")
			   then ()
		       else let $output1 := local:self-tr($head, $label, $output)
  		            let $output2 := local:descendant-tr($head, $label, $output1)
		            return local:descendant-or-self-tr(local:tail($x), $label, $output2)
		)
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

declare function local:following-sibling-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if (fn:empty($x))
  then $output
  else let $head := local:type-check(local:head-tr($x,()))	(:ノードタイプをチェック:)
       let $current := local:current($head)	
       let $pointer := local:pointer($head)
	   let $output1 := ($output, if($current/*[2])
	   							 then local:child-main-tr($current/*[2], $pointer, $label, ())
								 else ()
					   )
	   return local:following-sibling-tr(local:tail($x), $label, $output1)
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

declare function local:ancestor-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else let $head := local:go_to_up_N(local:type-check(local:head-tr($x, ())))
    let $current := local:current($head)
    let $pointer := local:pointer($head)
    return let $output1 := ($output, if($current/@type="root")
      								 then ()
      								 else local:ancestor-main-tr($current, $pointer, $label, ())
						   )
   		   return local:ancestor-tr(local:tail($x), $label, $output1)
};

declare function local:ancestor-main-tr ($current as node(), $pointer as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $head := local:go_to_up_N(local:type-check(($current, $pointer)))
	 (:ポインタを分離:)
  let $current1 := local:current($head)
  let $pointer1 := local:pointer($head)
  let $output1 := ($output, if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                            then ($current, $pointer, $s)	(:返り値:)
                            else ()
				  )
  let $parent := local:go_to_up_N($head)
  return if ($head[1]/@type="root")
	 	 then $output1
         else local:ancestor-main-tr($current1, $pointer1, $label, $output1)
};

declare function local:ancestor-or-self-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else (
  		if($x[1]/@type="root")
		then ()
		else let $output1 := local:self-tr($x, $label, $output)
  		let $output2 := local:ancestor-tr($x, $label, $output1)
		return $output2
		)
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
  let $head := local:type-check(local:head-tr($x,()))
  let $current := local:current($head)
  let $pointer := local:pointer($head) 
  let $output := 
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
                (local:variable_replace2($current/*[1], $pointer))
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
  return $output   
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
declare variable $original := doc("ex/Nasa/Nasa-r.xml");
(:declare variable $original := doc("ex/BaseBall/BaseBall-r.xml");:)
(:declare variable $original := doc("ex1-r.xml");:)
		  
(: //reference/source :)
(:for $v in $original/root/S/child::*[2]:)
(:return local:output(local:child-tr(local:descendant-tr(($v,$s),"reference",()),"source",())):)
(:return local:child(local:child(($v,$s),"*"),"*"):)
(:return local:child-tr(local:child-tr(($v,$s),"*",()),"*",()):)
(:return local:output(local:child(local:child(($v,$s),"*"),"*")):)
(:return local:output(local:child-tr(local:child-tr(($v,$s),"*",()),"*",())):)

(:
prof:mem(
for $v in $original/root/S/child::*[2]
return local:output(local:descendant(($v,$s),"PLAYER"))
)
:)

(:
for $v in doc("ex/BaseBall/BaseBall.xml")
return $v//HITS
:)

(:
prof:mem(
for $v in $original/root/S/child::*[2]
return local:output(local:descendant(($v,$s),"a"))
)
:)

(:
for $v in $original/root/S/child::*[2]
return local:output((local:descendant(($v,$s),"PLAYER"), local:descendant(($v,$s),"LEAGUE")))
:)

prof:time(
prof:mem(
for $v in $original/root/S/child::*[2]
return local:output(local:descendant(($v,$s),"reference"))
)
)

(:
for $v in $original/root/S/child::*[2]
return for $x in local:descendant-tr(($v,$s),"PLAYER")
       return local:output(local:child-tr(($x,$s),"HITS"))
:)