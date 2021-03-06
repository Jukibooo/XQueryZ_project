(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 軸処理するためのモジュール :)
declare namespace axis = "http://xqueryz/axis";
import module "http://xqueryz/axis" at "Axis.xq";

declare namespace axis-binary = "http://xqueryz/axis-binary";
import module "http://xqueryz/axis-binary" at "axis-binary.xq";

(: 見やすいように出力するためのモジュール :)
declare namespace output = "http://xqueryz/output";
import module "http://xqueryz/output" at "output.xq";
      
(: 対象にする文書をimport :)
declare namespace file = "http://xqueryz/file";
import module "http://xqueryz/file" at "file.xq";


declare namespace unranked = "http://xqueryz/unranked";
import module "http://xqueryz/unranked" at "unranked.xq";

declare namespace compressed = "http://xqueryz/compressed";
import module "http://xqueryz/compressed" at "compressed.xq";




(:
output:output(


(:=====================問合せ処理=======================:)

for $v in $file:original/root/S/child::*[2]/*[1]
return 


axis:descendant($v, "T")
,
1,
"START -> "
)
:)



(:
for $v in $file:original/*/*
return axis-binary:ancestor(axis-binary:descendant($v, "reference"), "dataset")
:)



unranked:output(

(:=====================問合せ処理=======================:)




for $v in $file:original/root/S/child::*[2]/*[1]
return 
(:===///===:)
axis:child(axis:descendant($v, "proceedings"), "url")
(:===///===:)

(:====================================================:)
,
0
,
()
)



(: compressed:output( 

(:=====================問合せ処理=======================:)

for $v in $file:original/root/S/child::*[2]/*[1]
return 

axis:descendant($v, "creator")


(:====================================================:)

) :)


