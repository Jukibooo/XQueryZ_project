declare function local:binarytree ($v as node()* )
as node()*
{
  (:left child:)
  if($v/node())		(:children exist:)
  then
   ( if($v/text())
    then										(:first child is text node:)
     (: text {$v/child::node()[1]} :)
     element _ {
      attribute left {"0"}, attribute right {"0"}
    }
    else										(:first child is element node:)
      element {fn:name($v/child::*[1])}{
        if ($v/child::*[1]/following-sibling::* and $v/child::*[1]/node())
        then
        (attribute left {"1"}, attribute right {"1"})
        else if($v/child::*[1]/following-sibling::*)
        then
        (attribute left {"0"}, attribute right {"1"})
        else if($v/child::*[1]/node())
        then
        (attribute left {"1"}, attribute right {"0"})
        else
        (attribute left {"0"}, attribute right {"0"})
        ,
        local:binarytree($v/child::*[1])
      }
   )
  else (
    element _ {
      attribute left {"0"}, attribute right {"0"}
    }
  )
  ,
  (:right child:)
  if($v/following-sibling::*)
  then							(:sibling exist:)
   ( element {fn:name($v/following-sibling::*[1])}{
     if($v/following-sibling::*[1]/child::node() and $v/following-sibling::*[2])
     then
     (attribute left {"1"}, attribute right {"1"})
     else if($v/following-sibling::*[1]/child::node())
     then
     (attribute left {"1"}, attribute right {"0"})
     else if($v/following-sibling::*[2])
     then
     (attribute left {"0"}, attribute right {"1"})
     else
     (attribute left {"0"}, attribute right {"0"})
     ,
      local:binarytree($v/following-sibling::*[1])
    } )
  else (
    element _ {
      attribute left {"0"}, attribute right {"0"}
    }
  )
  
};

for $root in doc("student.xml")
return
  local:binarytree($root)