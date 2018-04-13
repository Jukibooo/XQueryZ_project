let $v := doc("ex/DBLP/DBLP.xml")
return
copy $x := $v
modify delete node ($x//text())
return $x