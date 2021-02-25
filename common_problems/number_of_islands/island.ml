;;
let r = [|-1; -1; -1; 0; 1; 0; 1; 1|] in
let c = [|-1; 1; 0; -1; -1; 1; 0; 1|] in
let max = 10 in
let is_valid mat acc x y =

 if (x >=0) && (x < max) then
   Printf.printf "z%d %d\n" (acc.(y).(x)) (mat.(y).(x));

  x >= 0 && x < max && y >= 0 && y < max && acc.(y).(x) = 0 && mat.(y).(x) = 1
in
let rec walk_perimeter x y acc mat =
  let rec aux x y = function
    | 8 -> ()
    | _ as i -> (
        acc.(y).(x) <- 1 ;
        aux x y (i + 1) ;
        match is_valid mat acc (r.(i) + x) (c.(i) + y) with
        | true ->
            Printf.printf "there\n" ;
            aux (r.(i) + x) (c.(i) + y) (i + 1)
        | false -> Printf.printf "here\n" )
  in
  aux x y 0
in
(*
  else match (Array.get (Array.get mat x) y), (Array.get (Array.get acc x) y) with
  *)
let rec iter_y x acc mat =
  let rec aux sum = function
    | 10 -> sum
    | _ as y -> (
      match (mat.(y).(x), acc.(y).(x)) with
      | 1, 0 ->
          walk_perimeter x y acc mat ;
          aux (sum + 1) (y + 1)
      | _ -> 0 )
  in
  aux 0 0
in
let iter_x mat =
  let acc = Array.make_matrix 10 10 0 in
  let rec aux = function
    | 10 -> 0
    | _ as x -> iter_y x acc mat + aux (x + 1)
  in
  aux 0
in
let a =
  [| [|1; 0; 1; 0; 0; 0; 1; 1; 1; 1|]
   ; [|0; 0; 1; 0; 1; 0; 1; 0; 0; 0|]
   ; [|1; 1; 1; 1; 0; 0; 1; 0; 0; 0|]
   ; [|1; 0; 0; 1; 0; 1; 0; 0; 0; 0|]
   ; [|1; 1; 1; 1; 0; 0; 0; 1; 1; 1|]
   ; [|0; 1; 0; 1; 0; 0; 1; 1; 1; 1|]
   ; [|0; 0; 0; 0; 0; 1; 1; 1; 0; 0|]
   ; [|0; 0; 0; 1; 0; 0; 1; 1; 1; 0|]
   ; [|1; 0; 1; 0; 1; 0; 0; 1; 0; 0|]
   ; [|1; 1; 1; 1; 0; 0; 0; 1; 1; 1|] |]
in
let foo = iter_x a in
Printf.printf "e %d\n" foo
