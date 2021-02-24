
(*
 * tags: flatten, nested, list
 * notes:  '::' is O(1) as opposed to cons (@) which is O(n)
 * which is why we call rev at the end instead of cons repeatedly
 *)
type 'a node = One of 'a | Many of 'a node list

let flatten l =
  let rec aux acc = function
  | [] -> acc
  | One h :: t -> aux (h :: acc) t
  | Many h :: t -> aux (aux acc h) t in
  List.rev (aux [] l)

let () =
  let b = flatten [ One "a" ; Many [ One "b" ; Many [ One "c" ; One "d" ] ; One "e" ] ] in
