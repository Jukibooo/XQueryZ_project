(: xquery宣言 :)
xquery version "1.0" encoding "utf-8";

(: 名前空間宣言 :)
module namespace file = "http://xqueryz/file";

(:ここにファイル名を入力:)
declare variable $file:original := doc("../ex/Nasa/Nasa-b.xml");
(:declare variable $file:original := doc("../ex/Nasa/Nasa-r.xml");:)
(:declare variable $file:original := doc("../ex/BaseBall/BaseBall-r.xml");:)
(:declare variable $file:original := doc("../ex/Treebank/Treebank-r.xml");:)
(:declare variable $file:original := doc("../ex/DBLP/DBLP-r.xml");:)

