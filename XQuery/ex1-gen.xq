(:         
   r := a*
   a := b,c+
   c := d?,e?,f?
:)

let $count_a := 10000
let $max_c := 100000000
return
  element r {
    for $a in 1 to $count_a
    return element a {
      (element b { text { $a } },
       let $count_c := random:integer($max_c)
       return for $c in 0 to $count_c
              return element c { 
                (let $count_d := random:integer(2)
                 return if ($count_d)
                        then element d { text { $a, "/", $c } }
                        else (),
                 let $count_e := random:integer(2)
                 return if ($count_e)
                        then element e { text { $a, "/", $c } }
                        else (),
                 let $count_f := random:integer(2)
                 return if ($count_f)
                        then element f { text { $a, "/", $c } }
                        else ()
                )
              }
      )
    }
 }
