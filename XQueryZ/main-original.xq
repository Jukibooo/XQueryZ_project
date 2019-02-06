(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 対象にする文書をimport :)
declare namespace file = "http://xqueryz/file";
import module "http://xqueryz/file" at "file.xq";

for $v in
(:===///===:)
doc("../ex/Nasa/Nasa-n.xml")
(:===///===:)

return 
element result {  
(:===///===:)
$v/descendant::dataset/child::reference
(:===///===:)
}