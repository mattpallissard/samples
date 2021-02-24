let compress l =
  let rec aux acc = function
    | [] -> acc
    | h :: t -> (
      match acc with
      | [] -> aux [h] t
      | h' :: _ -> (
        match String.equal h h' with
        | true -> aux acc t
        | false -> aux (h :: acc) t ) )
  in
  List.rev (aux [] l)

let b =
  compress ["a"; "a"; "a"; "a"; "b"; "c"; "c"; "a"; "a"; "d"; "e"; "e"; "e"; "e"]

let rec compress = function
  | a :: (b :: _ as t) -> if a = b then compress t else a :: compress t
  | smaller -> smaller
