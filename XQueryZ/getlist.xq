(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace getlist = "http://xqueryz/getlist";

(: カッコをimport :)
declare namespace separater = "http://xqueryz/separater";
import module "http://xqueryz/separater" at "separater.xq";

(: 各リストを作成 :)
declare function getlist:getList ($list as node()*, $num as xs:integer, $output as node()*)
as node()*
{
(:  fn:trace((), "getlist:getList"),:)
  if (fn:empty($list[$num]))
  then  $output
  else  if ($list[$num] is $separater:left)
  then  getlist:getList($list, getlist:exitParantheses($list, $num - 1, 1), $output)
  else  getlist:getList($list, $num - 1, ($list[$num], $output))
};

(:
declare function axis:getNode ($list as node()*, $num as xs:integer, $output as node()*)
as node()*
{
  if($list[$num]/@type = "T" and fn:empty($output)) (: 関数を再帰していない状態 :)
  then
    let $output1 := axis:getNode($list, $num - 1, $list[$num])
    return $output1
  else if($list[$num] is $separater:left) (: "("，つまりカッコ終了 :)
  then
    $output
  else if($list[$num] is $separater:right) (: ()の外に移動 :)
  then
    $output
  else if($list[$num]/@type = "N")
  then
    let $output1 := axis:getNode($list, $num - 1, ($list[$num], $output))
    return $output1
  else
    $output
};
:)

(: ()から出る場所を調べる関数 :)
declare function getlist:exitParantheses ($list as node()*, $num as xs:integer, $level as xs:integer)
as xs:integer
{
(:  fn:trace((), "getlist:exitParantheses"),:)
    if($num = 0)
    then  0
    else if ($list[$num] is $separater:left)  (: "("が見つかればカッコの中 :)
    then  getlist:exitParantheses($list, $num - 1, $level - 1)
    else if ($list[$num] is $separater:right) (: ")"のとき :)
    then  getlist:exitParantheses($list, $num - 1, $level + 1)
    else if ($list[$num]/@type = "N" and $level = 0) (: 非終端記号かつ分岐前である場合 :)
    then  $num
    else  getlist:exitParantheses($list, $num - 1, $level)
};

declare function getlist:searchTerminal ($list as node()*, $num as xs:integer)
as xs:integer
{
(:  fn:trace((), "getlist:searchTerminal"),:)
  if (fn:empty($list[$num]))
  then  0
  else  if ($list[$num]/@type = "T")
        then  $num
        else  getlist:searchTerminal($list, $num + 1)
};

declare function getlist:lastsearchTerminal ($list as node()*, $num as xs:integer)
as xs:integer
{
(:  fn:trace((), "getlist:searchTerminal"),:)
  if (fn:empty($list[$num]))
  then  0
  else  if ($list[$num]/@type = "T")
        then  $num
        else  getlist:searchTerminal($list, $num - 1)
};
