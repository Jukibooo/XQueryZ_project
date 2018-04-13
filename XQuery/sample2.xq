declare function local:doc($x as node())
as node()*
{
  let $trietree := element DocumentNode { 
                      attribute id { $x/@id }
                   }
  return $trietree
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

(:let $v := <b><a/><c id="1"/></b>
let $x := %updating function($v) {
	insert node (<e/>) into $v
}
return let $z := $v update (
	updating $x(.))
return ($z/*)[fn:last()]
,
:)

declare function local:my ($v as node()*, $num as xs:integer)
{
	$v/*[$num]
};

let $v := (<b><a/><c id="1"/></b>, <a id="V"/>, <c id="V"/>)
return $v/fn:last()
