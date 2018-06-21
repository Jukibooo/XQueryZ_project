(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 軸処理するためのモジュール :)
declare namespace axis = "http://xqueryz/axis";
import module "http://xqueryz/axis" at "Axis.xq";

(: 見やすいように出力するためのモジュール :)
declare namespace output = "http://xqueryz/output";
import module "http://xqueryz/output" at "output.xq";
      
(: 対象にする文書をimport :)
declare namespace file = "http://xqueryz/file";
import module "http://xqueryz/file" at "file.xq";


output:output(

(: 問合せ処理 :)
(:===================================================:)

for $v in $file:original/root/S/child::*[2]/*[1]
return axis:descendant($v, "TEAM")

(:===================================================:)
,
1,
"START -> "
)