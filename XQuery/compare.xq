for $v in doc("result/BaseBall-result-r.xml")
return ("BaseBall-result-r",fn:count($v//*))
					 ,
for $v in doc("result/BaseBall-result-r2.xml")
return ("BaseBall-result-r2",fn:count($v//*))
					 ,
for $v in doc("result/Shake-result-r.xml")
return ("Shake-result-r",fn:count($v//*))
					 ,
for $v in doc("result/Shake-result-r2.xml")
return ("Shake-result-r2",fn:count($v//*))
					 ,
for $v in doc("result/Nasa-result-r.xml")
return ("Nasa-result-r",fn:count($v//*))
					 ,
for $v in doc("result/Nasa-result-r2.xml")
return ("Nasa-result-r2",fn:count($v//*))