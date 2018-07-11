(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace compressed = "http://xqueryz/compressed";

(: トライ木からひとつのノードのリストを取得するためのモジュール :)
declare namespace getlist = "http://xqueryz/getlist";
import module "http://xqueryz/getlist" at "getlist.xq";

(: 対象にする文書をimport :)
declare namespace file = "http://xqueryz/file";
import module "http://xqueryz/file" at "file.xq";

(: $list: トライ木 :)
declare function compressed:output($list as node()*) 
as node()*
{
  fn:trace((), "compressed:output"),
  if(fn:empty($list))
  then ()
  else element {"root"} { compressed:start_output($list,(), 0) }
};


declare function compressed:start_output ($list as node()*, $start as node()*, $num as xs:integer)
as node()*
{
  fn:trace((), "compressed:start_output"),
  let $newNum := getlist:searchTerminal($list, $num + 1)
  return  if ($newNum = 0)  (: 0はこれ以上終端記号がないことを示す :)
          then  (:starttreeをすべて登録できたら:)
                 ($start, compressed:create_N($start, ())/self::*)
          else  let $newlist := getlist:getList($list, $newNum, ())
                let $current := $newlist[fn:last()]
                let $starttree := ($start, element {"S"} {
                                    element {"S"} {attribute {"type"} {"start"}},
                                    element {"S"} {attribute {"type"} {"root"}, 
                                      element {fn:name($current)}{
                                        compressed:variable_replace2($current/*[1], $newlist[fn:position() < fn:last()])
                                          ,
                                        <_/>
                                      }
                                    }
                                  })
                return  compressed:start_output($list, $starttree, $newNum)
};

(:非終端記号のサブツリーを作成する関数:)
declare function compressed:create_N($start as node()*, $list as node()*)
as node()*
{
  fn:trace((), "compressed:create_N"),
  if($start)
  then
    let $list := compressed:N_list($start[1], $list)
    return
      compressed:create_N(fn:remove($start, 1), $list)
  
  else
    $list
};

declare function compressed:variable_replace2($current as node(), $pointer as node()*)
as node()
{
  fn:trace((), "compressed:variable_replace2"),
    if(fn:name($current) = "y0")
    then
      compressed:variable_replace2($pointer[fn:count($pointer)]/*[1], fn:remove($pointer, fn:count($pointer)))
    else if(fn:name($current) = "y1")
    then
      compressed:variable_replace2($pointer[fn:count($pointer)]/*[2], fn:remove($pointer, fn:count($pointer)))
    else if(fn:name($current) = "y2")
    then
      compressed:variable_replace2($pointer[fn:count($pointer)]/*[3], fn:remove($pointer, fn:count($pointer)))
    else if(fn:name($current) = "y3")
    then
      compressed:variable_replace2($pointer[fn:count($pointer)]/*[4], fn:remove($pointer, fn:count($pointer)))
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
          compressed:variable_replace2($current/*[1], $pointer)
        else ()
        ,
        if($current/*[2])
        then
          compressed:variable_replace2($current/*[2], $pointer)
        else ()
    ,
    if($current/*[3])
    then
          compressed:variable_replace2($current/*[3], $pointer)
        else ()
    ,
    if($current/*[4])
    then
          compressed:variable_replace2($current/*[4], $pointer)
        else ()
      }
    return $tree
};

declare function compressed:N_list($node as node(), $list as node()*)
as node()*
{
  fn:trace((), "compressed:N_list"),
  let $N_list := for $non in $node/descendant::*[@type="N"]
                 return $file:original/*/*[name()=fn:name($non)]
  return (
         $list, $N_list,
     if(fn:empty($N_list))
         then ()
     else for $N_list1 in $N_list
          return compressed:N_list-sub($N_list1)
     )
};

declare function compressed:N_list-sub($node as node())
as node()*
{
  fn:trace((), "compressed:N_list-sub"),
  let $N_list := for $non in $node/*[2]/descendant-or-self::*[@type="N"]
                 return $file:original/*/*[name()=fn:name($non)]
  return if(fn:empty($N_list))
         then ()
     else for $N_list1 in $N_list
          return ($N_list, compressed:N_list-sub($N_list1))
};