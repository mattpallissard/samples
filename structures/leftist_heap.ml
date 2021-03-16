type comparison = Lt | Eq | Gt

module type ORDERED = sig
  type t

  val compare : t -> t -> comparison
end

module type HEAP = sig
  type elem

  type heap

  val empty : heap

  val isempty : heap -> bool

  val insert : elem -> heap -> heap

  val insert2 : elem -> heap -> heap

  val merge : heap -> heap -> heap

  val min : heap -> elem

  val remove_min : heap -> heap
end

module Heap (Element : ORDERED) : HEAP with type elem = Element.t = struct
  type elem = Element.t

  type rank = int

  type heap = E | T of rank * elem * heap * heap

  let empty = E

  let _compare i j = if i = j then Eq else if i < j then Lt else Gt

  let isempty = function
    | E -> true
    | _ -> false

  let rank = function
    | E -> 0
    | T (r, _, _, _) -> r

  let make i j k =
    match _compare (rank j) (rank k) with
    | Gt -> T (rank k + 1, i, j, k)
    | _ -> T (rank j + 1, i, k, j)

  let rec merge i j =
    match (i, j) with
    | i, E -> i
    | E, i -> i
    | (T (_, i, j, k) as h), T (_, i', j', k') -> (
      match Element.compare i i' with
      | Lt -> make i j (merge k h)
      | _ -> make i' j' (merge h k') )

  let insert i j = merge (T (1, i, E, E)) j

  let rec insert2 i j =
    match (i, j) with
    | i, E -> T (1, i, E, E)
    | i, (T (_, i', j', k') as h) -> (
      match Element.compare i i' with
      | Lt -> T (1, i, h, E)
      | _ -> make i' j' (insert2 i k') )


  exception Empty

  let min = function
    | E -> raise Empty
    | T (_, i, _, _) -> i

  let remove_min = function
    | E -> raise Empty
    | T (_, _, i, j) -> merge i j
end

module OI = struct
  type t = int

  let compare i j = if i = j then Eq else if i < j then Lt else Gt
end

module I = Heap (OI)

let () =
  let foo = I.insert2 6 I.empty in
  let bar = I.insert2 5 foo in
  let baz = I.insert2 4 bar in
  Printf.printf "=%d\n" (I.min baz) ;
  let fizz = I.remove_min baz in
  Printf.printf "+%d\n" (I.min fizz) ;
  let bar = I.remove_min fizz in
  let der = I.remove_min bar in
  Printf.printf "-%d\n" (I.min der)
