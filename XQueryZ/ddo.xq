(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace ddo = "http://xqueryz/ddo";

declare namespace separater = "http://xqueryz/separater";
import module "http://xqueryz/separater" at "separater.xq";

(: 全体のリストに登録 :)
declare function ddo:setDDOlist($output as node()*, $list as node()*, $outputNum as xs:integer, $listNum as xs:integer)
as node()*  (: 返り値は登録後のリスト :)
{
  fn:trace((), "ddo:setDDOlist"),
  if (fn:empty($output))
  then $list
  else if (fn:empty($list[$listNum]))
  then  $output
  else  if ($output[$outputNum] is $list[$listNum]) (: 同じノードの場合 :)
        then  ddo:setDDOlist($output, $list, $outputNum + 1, $listNum + 1)
        else  if ($output[$outputNum] is $separater:left) (: "("の場合，()内の処理に移行 :)
              then  ddo:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum, fn:false())
              else    (: ノードが違う場合，分岐を作成 :)
                  if ($output[$outputNum] << $list[$listNum]) (: 文書順かどうかの確認 :)
                  then  ($output[$outputNum > fn:position()], $separater:left, $separater:left, $output[$outputNum <= fn:position()], $separater:right, $separater:left, $list[$listNum <= fn:position()], $separater:right, $separater:right)  (: result :)
                  else  ($output[$outputNum > fn:position()], $separater:left, $separater:left, $list[$listNum <= fn:position()], $separater:right, $separater:left, $output[$outputNum <= fn:position()], $separater:right, $separater:right)  (: result :)
};






(: ()内の処理 :)
(: flagは()内に分岐できるノードがあるときtrueに :)
declare function ddo:setDDOlist-Parantheses($output as node()*, $list as node()*, $outputNum as xs:integer, $listNum as xs:integer, $flag as xs:boolean)
as node()*
{
  fn:trace((), "ddo:setDDOlist-Parantheses"),
  if (fn:empty($list[$listNum]))
  then  $output
  else  if($output[$outputNum] is $list[$listNum])  (: 同じノードの場合 :)
        then  ddo:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum + 1, fn:true())
        else if ($output[$outputNum] is $separater:left)  (: "("の場合 :)
        then  ddo:setDDOlist-Parantheses($output, $list, $outputNum + 1, $listNum, fn:false())
        else if ($output[$outputNum] is $separater:right)
        then  $output
        else if($flag)    (: ()内に新たに()の分岐が必要な場合 :)
        then  let $nextoutputNum := ddo:nextBranch($output, $outputNum + 1, 0)
              return  if ($output[$outputNum] << $list[$listNum])
                      then  ($output[$outputNum > fn:position()], $separater:left, $separater:left, $output[$outputNum <= fn:position() and fn:position() < $nextoutputNum - 1], $separater:right, $separater:left, $list[$listNum <= fn:position()], $separater:right, $separater:right, $output[$nextoutputNum - 1 <= fn:position()])  (: result :)
                      else  ($output[$outputNum > fn:position()], $separater:left, $separater:left, $list[$listNum <= fn:position()], $separater:right, $separater:left,  $output[$outputNum <= fn:position() and fn:position() < $nextoutputNum - 1],$separater:right, $separater:right, $output[$nextoutputNum - 1 <= fn:position()])  (: result :)
        else  (: 次の分岐を検索 :)
              if ($output[$outputNum] >> $list[$listNum])
              then  ($output[$outputNum - 1 > fn:position()], $separater:left, $list[$listNum <= fn:position()], $separater:right, $output[$outputNum - 1 <= fn:position()])  (: result :)
              else  let $outputNum1 := ddo:nextBranch($output, $outputNum + 1, 0)
                    return  if ($output[$outputNum1] is $separater:right or fn:empty($output[$outputNum1])) (: 分岐終了の場合 :)
                            then  ($output[$outputNum1 > fn:position()], $separater:left, $list[$listNum <= fn:position()], $separater:right, $output[$outputNum1 <= fn:position()])  (: result :)
                            else  (: 分岐が残っている場合 :)
                              ddo:setDDOlist-Parantheses($output, $list, $outputNum1, $listNum, fn:false())
};

(: 次の分岐を検索する関数 :)
declare function ddo:nextBranch ($output as node()*, $outputNum as xs:integer, $level as xs:integer)
as xs:integer
{
  fn:trace((), "ddo:nextBranch"),
  if (fn:empty($output[$outputNum]))
  then  $outputNum
  else  if ($output[$outputNum] is $separater:right)
  then  if($level = 0)
        then  $outputNum + 1
        else  ddo:nextBranch($output, $outputNum + 1, $level - 1)
  else if ($output[$outputNum] is $separater:left)
  then  ddo:nextBranch($output, $outputNum + 1, $level + 1)
  else  ddo:nextBranch($output, $outputNum + 1, $level)
};