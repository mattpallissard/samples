let rec pack l =
  let rec aux current acc = function
    | [] -> []
    | [i] -> (i :: current) :: acc
    | h :: (m :: _ as t) ->
        if h = m then aux (h :: current) acc t
        else aux [] ((h :: current):: acc) t
  in
  List.rev (aux [] [] l)
;;
