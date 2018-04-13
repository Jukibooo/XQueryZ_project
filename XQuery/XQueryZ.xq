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
  let $output :=
    if($current/parent::*/@type="N")
    then
      if(fn:count($current/preceding-sibling::*) = 0)
      then
        let $pointer1 := ($pointer, $current/parent::*)
        let $current1 := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]
        return
          local:go_to_up_N (($current1, $pointer1))
      else if(fn:count($current/preceding-sibling::*) = 1)
      then
        let $pointer1 := ($pointer, $current/parent::*)
        let $current1 := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]
        return
          local:go_to_up_N (($current1, $pointer1))
      else if(fn:count($current/preceding-sibling::*) = 2)
      then
        let $pointer1 := ($pointer, $current/parent::*)
        let $current1 := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]
        return
          local:go_to_up_N (($current1, $pointer1))
      else if(fn:count($current/preceding-sibling::*) = 3)
      then
        let $pointer1 := ($pointer, $current/parent::*)
        let $current1 := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]
        return
          local:go_to_up_N (($current1, $pointer1))
      else ()
    else if($current/parent::*/@type="N_root")
    then
      let $current1 := $pointer[fn:count($pointer)]
      let $pointer1 := fn:remove($pointer, fn:count($pointer))
      return
        local:go_to_up_N (($current1, $pointer1))
    else 
      if($current is $current/parent::*/*[1])
      then
        ($current/parent::*, $pointer)
      else
        local:go_to_up_N(($current/parent::*, $pointer))
  return $output
};

declare variable $s := element {"separator"} {};  (:separator:)
   
(:ポインタの集合の先頭を取得:)
declare function local:head ($x as node()*)
as node()* {
  if ($x[1] is $s)  (:separatorかどうかチェック:) 
  then ()
  else ($x[1],local:head($x[1 < position()]))
};

declare function local:head-tr($x as node()*, $output as node()*)
as node()*
{
  if ($x[1] is $s)
  then $output
  else local:head-tr($x[1 < fn:position()], ($output, $x[1]))
};

   
(:ポインタの集合の先頭以外を取得:)
declare function local:tail ($x as node()*)
as node()* {
  if ($x[1] is $s)  (:separatorかどうかチェック:) 
  then $x[1 < position()]
  else local:tail($x[1 < position()])
};

(:カレントノードのポインタを取得:)
declare function local:current ($x as node()*)
as node()
{
  $x[1]
};

declare function local:pointer($x as node()*)
as node()*
{
  $x[1 < position()]
};


(:child軸の関数:)
declare function local:child ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if (fn:empty($x))
  then $output
  else let $head := local:type-check(local:head-tr($x,()))  (:ノードタイプをチェック:)
       let $current := local:current($head) 
       let $pointer := local:pointer($head)
       let $output1 := ($output, if ($current/*[1])
                                 then local:child-main($current/*[1], $pointer, $label, ())
                                 else ())
       return local:child(local:tail($x), $label, $output1)
};

declare function local:child-main ($current as node(), $pointer as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $head := local:type-check(($current, $pointer))
   (:ポインタを分離:)
  let $current := local:current($head)
  let $pointer := local:pointer($head)
  let $output1 := ($output, if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
                            then ($current, $pointer, $s) (:返り値:)
                            else ())
  return if ($current/*[2])
          then local:child-main($current/*[2], $pointer, $label, $output1)
         else $output1
};

(:descendant軸の関数:)
declare function local:descendant ($x as node()*, $label as xs:string, $output as node()*)
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
        return local:descendant(local:tail($x), $label, $output1)
       )
};

declare function local:descendant-main ($current as node(), $pointer as node()*, $label as xs:string)
as node()*
{
  if ($current/@type = "T")
  then if (fn:name($current) = $label or ($label = "*" and fn:name($current) != "_"))
       then ($current, $pointer, $s)  (:返り値:)
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

declare function local:self ($x as node()*, $label as xs:string, $output as node()*)
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
     return local:self(local:tail($x), $label, $output1)
     )
};

declare function local:descendant-or-self ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else (
      let $head := local:head-tr($x,())  (:ここではtype-checkしないことにしてみた:)
        let $current := local:current($head)  
        let $pointer := local:pointer($head)
    return if($current/@type="root")
         then (
               let $output1 := local:descendant(($head,$s), $label, $output)
                 return local:descendant-or-self(local:tail($x), $label, $output1)
          )
           else (
               let $output1 := local:self($head, $label, $output)
                   let $output2 := local:descendant(($head,$s), $label, $output1)
                 return local:descendant-or-self(local:tail($x), $label, $output2)
          )
    )
};

declare function local:parent ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else (let $head := local:go_to_up_N(local:type-check(local:head($x))) (:ノードタイプをチェック:)
       let $current := local:current($head) 
       let $pointer := local:pointer($head)
       return let $output1 := ($output, if(fn:name($current) = $label or $label = "*")
                            then ($current, $pointer, $s)
                          else ()
                )
            return local:parent(local:tail($x), $label, $output1)
    )
};

declare function local:following-sibling ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
 if (fn:empty($x))
  then $output
  else let $head := local:type-check(local:head-tr($x,()))  (:ノードタイプをチェック:)
       let $current := local:current($head) 
       let $pointer := local:pointer($head)
     let $output1 := ($output, if($current/*[2])
                   then local:child-main($current/*[2], $pointer, $label, ())
                 else ()
             )
     return local:following-sibling(local:tail($x), $label, $output1)
    
};

(:
declare function local:ancestor ($x as node()*, $label as xs:string, $output as node()*)
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
         return local:ancestor(local:tail($x), $label, $output1)
};
:)

declare function local:ancestor-main-tr ($current as node(), $pointer as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $head := local:go_to_up_N(local:type-check(($current, $pointer)))
   (:ポインタを分離:)
  let $current1 := local:current($head)
  let $pointer1 := local:pointer($head)
  let $output1 := ($output, if (fn:name($current1) = $label or ($label = "*" and fn:name($current1) != "_"))
                            then ($current1, $pointer1, $s) (:返り値:)
                            else ()
          )
  let $parent := local:go_to_up_N($head)
  return if ($parent[1]/@type="root")
     then $output1
         else local:ancestor-main-tr($current1, $pointer1, $label, $output1)
};

declare function local:ancestor ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else let $head := local:type-check(local:head-tr($x, ()))
       return let $output1 := (local:ancestor-main($head, $label, ()), $output)
        return local:ancestor(local:tail($x), $label, $output1)
};

declare function local:ancestor-main ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $head := local:go_to_up_N(local:type-check($x))
  let $current := local:current($head)
  let $pointer := local:pointer($head)
  return if($current/@type="root")
         then $output
     else let $output1 := (
                               if(fn:name($current) = $label or $label = "*")
                               then ($head, $s)
                   else ()
                 ,
                 $output
                )
          return local:ancestor-main($head, $label, $output1)
};

declare function local:preceding-sibling ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  let $head := local:type-check(local:head($x))
  let $current := local:current($head)
  let $pointer := local:pointer($head)
  return
  (:親が非終端記号の場合:)
  (:自身が何番目の子か確認して対応する変数に移動:)
    if($current/parent::*/@type="N")  
    then
      if($current is $current/parent::*/*[1])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]
        return
          local:preceding-sibling (($current, $pointer, $s), $label, ())
      else if($current is $current/parent::*/*[2])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]
        return
          local:preceding-sibling (($current, $pointer, $s), $label, ())
      else if($current is $current/parent::*/*[3])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]
        return
          local:preceding-sibling (($current, $pointer, $s), $label, ())
      else if($current is $current/parent::*/*[4])
      then
        let $pointer := ($pointer, $current/parent::*)
        let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]
        return
          local:preceding-sibling (($current, $pointer, $s), $label, ())
      else ()
  (:親が非終端記号のサブツリーの頂点:)
  (:メモリから辿ってきた非終端記号に戻る:)
    else if($current/parent::*/@type="N_root")  
    then
      let $current := $pointer[fn:count($pointer)]
      let $pointer := fn:remove($pointer, fn:count($pointer))
      return
        local:preceding-sibling (($current, $pointer, $s), $label, ())
  (:親が終端記号かつ自身がfirst-childの場合:)
  (:関数終了:)
    else if($current is $current/parent::*/*[1])
    then
        ()
  (:親が終端記号の場合:)
  (:labelと比較:)
    else
      (local:preceding-sibling (($current/parent::*, $pointer, $s), $label, ())
      ,
      if(fn:name($current/parent::*) = $label or $label = "*")
      then
        ($current/parent::*, $pointer, $s)
      else
        ()
      )
     ,
  (:ポインタがまだ残っていたら再帰:)
  let $tail := local:tail($x)
  return
    if($tail)
  then
    local:preceding-sibling($tail, $label, ())
    else
      () 
};

declare function local:preceding-sibling-tr ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else let $head := local:type-check(local:head($x))
       let $current := local:current($head)
       let $pointer := local:pointer($head)
       let $output1 := (
                (:親が非終端記号の場合:)
              (:自身が何番目の子か確認して対応する変数に移動:)
                if($current/parent::*/@type="N")  
                then
                    if($current is $current/parent::*/*[1])
                    then
                      let $pointer := ($pointer, $current/parent::*)
                      let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y0[@type="V"]
                      return
                          local:preceding-sibling (($current, $pointer, $s), $label, ())
                    else if($current is $current/parent::*/*[2])
                    then
                      let $pointer := ($pointer, $current/parent::*)
                      let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y1[@type="V"]
                      return
                          local:preceding-sibling (($current, $pointer, $s), $label, ())
                    else if($current is $current/parent::*/*[3])
                    then
                      let $pointer := ($pointer, $current/parent::*)
                      let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y2[@type="V"]
                      return
                          local:preceding-sibling (($current, $pointer, $s), $label, ())
                    else if($current is $current/parent::*/*[4])
                    then
                      let $pointer := ($pointer, $current/parent::*)
                      let $current := fn:root($current)/*/*[name()=fn:name($current/parent::*)]/*[2]//y3[@type="V"]
                      return
                          local:preceding-sibling (($current, $pointer, $s), $label, ())
                    else ()
              (:親が非終端記号のサブツリーの頂点:)
              (:メモリから辿ってきた非終端記号に戻る:)
                else if($current/parent::*/@type="N_root")  
                then
                  let $current := $pointer[fn:count($pointer)]
                    let $pointer := fn:remove($pointer, fn:count($pointer))
                    return
                      local:preceding-sibling (($current, $pointer, $s), $label, ())
              (:親が終端記号かつ自身がfirst-childの場合:)
              (:関数終了:)
                else if($current is $current/parent::*/*[1])
                then
                    ()
              (:親が終端記号の場合:)
              (:labelと比較:)
                else
                    (local:preceding-sibling (($current/parent::*, $pointer, $s), $label, ())
                    ,
                    if(fn:name($current/parent::*) = $label or $label = "*")
                    then
                      ($current/parent::*, $pointer, $s)
                    else
                      ()
                    )
            )
        return local:preceding-sibling(local:tail($x), $label, $output1)
       
};

(:
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
        local:following-sibling(($current, $pointer), $label, ())
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
:)

declare function local:following ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else let $head := local:head($x)
     let $parent := local:go_to_up_N($head)
     let $output1 := (if($parent[1]/@type="root") (:親がドキュメントノードなら:)
              then ()
              else local:following(($parent,$s), $label, ())  (:再帰:)
              , 
              local:following-sibling(($head, $s), $label, ())
              ,
              $output
             )
     return local:following(local:tail($x), $label, $output1)
};

(:
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
:)

declare function local:preceding ($x as node()*, $label as xs:string, $output as node()*)
as node()*
{
  if(fn:empty($x))
  then $output
  else let $head := local:head($x)
     let $parent := local:go_to_up_N($head)
     let $output1 := (if($parent[1]/@type="root") (:親がドキュメントノードなら:)
              then ()
              else local:preceding(($parent,$s), $label, ())  (:再帰:)
              , 
              local:preceding-sibling(($head, $s), $label, ())
              ,
              $output
             )
     return local:preceding(local:tail($x), $label, $output1) 
};

declare function local:output($x as node()*) 
as node()*
{
  if(fn:empty($x))
  then ()
  else element {"root"} { local:start_output($x,()) }
};


declare function local:start_output ($x as node()*, $start)
as node()*
{
  let $head := local:type-check(local:head-tr($x, ()))
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
                 local:create_N($starttree, ())/self::*)))
            )   
  return $output       
};

(:非終端記号のサブツリーを作成する関数:)
declare function local:create_N($start as node()*, $list as node()*)
as node()*
{
  if($start)
  then
    let $list := local:N_list($start[1], $list)
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
      let $tree := element {fn:name($current)} {
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
    ,
    if($current/*[3])
    then
          local:variable_replace2($current/*[3], $pointer)
        else ()
    ,
    if($current/*[4])
    then
          local:variable_replace2($current/*[4], $pointer)
        else ()
      }
    return $tree
};

declare function local:N_list($node as node(), $list as node()*)
as node()*
{
  let $N_list := for $non in $node/descendant::*[@type="N"]
                 return $original/*/*[name()=fn:name($non)]
  return (
         $list, $N_list,
     if(fn:empty($N_list))
         then ()
     else for $N_list1 in $N_list
          return local:N_list-sub($N_list1)
     )
};

declare function local:N_list-sub($node as node())
as node()*
{
  let $N_list := for $non in $node/*[2]/descendant-or-self::*[@type="N"]
                 return $original/*/*[name()=fn:name($non)]
  return if(fn:empty($N_list))
         then ()
     else for $N_list1 in $N_list
          return ($N_list, local:N_list-sub($N_list1))
};

(:非終端記号のリストを作成する関数:)
(:
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
:)

(:
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
:)

declare function local:result-check($x as node()*, $list as node()*)
as node()*
{
  let $head := local:head-tr($x, ())
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
  if($x[1] is local:head-tr($list, ())[1])
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

(: doc()を処理する関数 :)
declare function local:doc($x as node())
as node()
{
  let $trietree := element C { 
                      attribute id { $x/root/S/child::*[2]/@id }
                   }
  return ($trietree/@id, fn:root($trietree))
};

declare function local:type-check-new ($x as node()*)
as node()*
{
  let $current := $x[1]
  let $history := $x[2]
  return
  if ($current/@type = "N") (:カレントノードが非終端記号の場合:)
  then
    local:type-check-new(
      (let $current1 := fn:root($current)/*/*[name()=fn:name($current)]/*[2]  (:カレントノードを非終端記号の部分木の頂点に変更:)
      return $current1
      ,
      local:id-insert($current, local:N-insert($history)) (:まずノードを挿入して，属性を付加:)
      )
    )
  else if ($current/@type = "V")  (:変数の場合:)
  then
    local:type-check-new(
    if(fn:name($current) = "y0")  (:変数名y0の場合:)
      then
        (let $current1 := $original//*[@id=$history/@id]/*[1] (:カレントノードを移動まえのノードに変更:)
        return
          $current1
        ,
        if ($history//*[name()="C"])  (:子孫に問い合わせ結果があれば消さない:)
        then
          $history/parent::*
        else
          local:node-delete($history)
        )
      else if(fn:name($current) = "y1") (:変数名y1の場合:)
      then
        (let $current1 := $original//*[@id=$history/@id]/*[2] (:カレントノードを移動まえのノードに変更:)
        return
          $current1
        ,
        if ($history//*[name()="C"])
        then
          $history/parent::*
        else
          local:node-delete($history)
        )
      else if(fn:name($current) = "y2") (:変数名y2の場合:)
      then
        (let $current1 := $original//*[@id=$history/@id]/*[3] (:カレントノードを移動まえのノードに変更:)
        return
          $current1
        ,
        if ($history//*[name()="C"])
        then
          $history/parent::*
        else
          local:node-delete($history)
        )
      else(:変数名y3の場合:)
        (let $current1 := $original//*[@id=$history/@id]/*[4] (:カレントノードを移動まえのノードに変更:)
        return
          $current1
        ,
        if ($history//*[name()="C"])
        then
          $history/parent::*
        else
          local:node-delete($history)
        )
    )
  else if ($current/@type = "T")  (:終端記号の場合:)
  then
    ($current, $history)
  else ()
};

declare function local:N-insert ($history as node())
as node()
{
  let $x := %updating function($history) {
      insert node (<N/>) into $history
      }
  return let $history1 := $history update (updating $x(.))
         return $history1/*[fn:last()]  (:返り値はtrietreeに追加した部分:)
};

declare function local:C-insert ($id as xs:integer, $history as node())
as node()
{
  let $x := %updating function($history) {
      insert node (<C/>) into $history//*[$id]
      }
  return let $history1 := $history update (updating $x(.))
         return $history1/*[fn:last()]  (:返り値はtrietreeに追加した部分:)
};

declare function local:id-insert ($current as node(), $history as node())
as node()
{
  let $x := %updating function($history) {
      insert node (attribute id { $current/@id }) into $history
      }
  return $history update (updating $x(.)) (:返り値はtrietreeに属性を追加した部分:)
};

declare function local:node-delete ($history as node())
as node()
{
  let $parent := $history/parent::*
  let $x := %updating function($parent) {
    delete node $parent/*[fn:count($history/preceding-sibling::*)+1]
  }
  return $parent update (updating $x(.))
};

(:child軸の関数:)
declare function local:child-new ($id as xs:integer, $history as node(), $label as xs:string)
as node()*
{
  let $current := $original//*[$id]
  return  if($current/*[1])
          then local:child-main-new($current/*[1], $history, $label)
          else ()
};

declare function local:child-main-new ($current as node(), $history as node(), $label as xs:string)
as node()*
{
  let $head := local:type-check-new(($current, $history))
  let $current1 := $head[1]
  let $history1 := $head[2]
  return  if (fn:name($current1) = $label or ($label = "*" and fn:name($current1) != "_"))
          then  let $history2 := local:id-insert($current1, fn:root(local:C-insert($history1/@id, fn:root($history1)))) (:返り値:)
                return  if ($current1/*[2])
                        then local:child-main-new($current1/*[2], $history2, $label)
                        else $history2
          else  if ($current1/*[2])
                then local:child-main-new($current1/*[2], $history1, $label)
                else $history1
};

(:ここにファイル名を入力:)
(:declare variable $original := doc("ex/Nasa/Nasa-r.xml");:)
(:declare variable $original := doc("../ex/BaseBall/BaseBall-r.xml");:)
(:declare variable $original := doc("ex/Treebank/Treebank-r.xml");:)
(:declare variable $original := doc("ex/DBLP/DBLP-r.xml");:)
declare variable $original := doc("../sample.xml");
      
(: //reference/source :)



for $v in local:doc($original)
return local:child-new($v[1], $v[2], "SEASON")




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