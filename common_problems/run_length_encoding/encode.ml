let encode l =
  let rec aux i = function
  | [] -> []
  | [h] -> [(i, h)]
  | h :: (m :: _ as t) -> if h = m then aux (i+1) t else (i, h) :: (aux 1 t)
in
aux 1 l
;;
