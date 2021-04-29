;;
let r = [|-1; -1; -1; 0; 1; 0; 1; 1|] in
let c = [|-1; 1; 0; -1; -1; 1; 0; 1|] in
let max = 10 in
let is_valid mat acc x y =
  x >= 0 && x < max && y >= 0 && y < max && !acc.(y).(x) = 0 && mat.(y).(x) = 1
in
let rec walk_perimeter x y acc mat =
  let rec aux x y = function
    | 8 -> ()
    | _ as i -> (
        !acc.(y).(x) <- 1 ;
        match is_valid mat acc (r.(i) + x) (c.(i) + y) with
        | true ->
            aux (r.(i) + x) (c.(i) + y) 0 ;
            aux x y (i + 1)
        | false -> aux x y (i + 1) )
  in
  aux x y 0
in
let rec iter_y x acc mat =
  let rec aux sum = function
    | 10 -> sum
    | _ as y -> (
      match (mat.(y).(x), !acc.(y).(x)) with
      | 1, 0 ->
          walk_perimeter x y acc mat ;
          aux (sum + 1) (y + 1)
      | _ -> aux sum (y + 1) )
  in
  aux 0 0
in
let iter_x mat =
  let acc = ref (Array.make_matrix 10 10 0) in
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
Printf.printf "%d\n" foo
