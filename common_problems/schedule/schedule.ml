(* linked list *)
type 'a dl = E | T of 'a p * 'a * 'a p

and 'a p = N | Node of 'a dl ref | Last of 'a dl ref

module type ELEM = sig
  type t

  type ds

  val empty : ds

  val create : int -> string -> t

  val insert : t dl ref -> t -> ds -> (ds, ds) result

  val remove : t -> ds -> (ds, ds) result

  val get_uuid : t -> ds -> t dl ref option

  val get_data : t -> ds -> t dl ref option

  val display : t -> unit
end

module type DQ = sig
  type t

  type ds

  val create : int -> string -> t

  val empty : ds

  val get_uuid : t -> ds -> t dl ref option

  val get_data : t -> ds -> t dl ref option

  val insert : t -> t dl ref ref -> ds -> (ds, ds) result

  val remove : t dl ref -> t dl ref ref -> ds -> (ds, ds) result

  val display : t dl ref -> unit

  val walk_right : t dl ref -> unit
end

module DeliveryQueue (Elem : ELEM) : DQ = struct
  type t = Elem.t

  type ds = Elem.ds

  let create = Elem.create

  let empty = Elem.empty

  let get_uuid = Elem.get_uuid

  let get_data = Elem.get_data

  let display i =
    match !i with
    | E -> print_string "empty\n"
    | T (_, d, _) -> Elem.display d

  let walk_right m =
    let rec aux = function
      | E -> print_string "empty\n"
      | T (_, i, r) -> (
          Elem.display i ;
          match r with
          | N | Last _ -> print_string "end\n"
          | Node r -> aux !r )
    in
    aux !m

  let insert i node ds =
    (* we have
     *   the initial empty case,
     *   the typical case when a node has two pointers,
     *   and the case where a node has no pointers *)
    match !(!node) with
    | E ->
        let n = ref (T (N, i, N)) in
        node := n ;
        Elem.insert n i ds
    | T (l, d, Node r) -> (
      match !r with
      | T (_, _, _) ->
          let n = ref (T (l, i, Node !node)) in
          !node := T (Node n, d, Node r) ;
          node := n ;
          Elem.insert n i ds
      | E ->
          Error ds
          (* we actually never reach here, return an error with the original ds *)
      )
    | T (N, d, N) ->
        let n = ref (T (Last !node, i, Node !node)) in
        !node := T (Node n, d, N) ;
        node := n ;
        Elem.insert n i ds
    | _ -> Error ds

  (* we actually never reach here, return an error with the original ds *)

  let remove m a ds =
    match !m with
    | T (Last last, d, Node i) -> (
      match !i with
      | T (Node _, dl, Node r) ->
          i := T (Node last, dl, Node r) ;
          a := i ;
          Elem.remove d ds
      | _ -> Error ds )
    | T (Node i, d, N) -> (
      match !i with
      | T (l, dl, Node _) ->
          i := T (l, dl, N) ;
          Elem.remove d ds
      | _ -> Error ds )
    | T (Node l, d, Node r) -> (
      match (!l, !r) with
      | T (ll, ld, _), T (_, rd, rr) ->
          l := T (ll, ld, Node r) ;
          r := T (Node l, rd, rr) ;
          Elem.remove d ds
      | _, _ -> Error ds )
    | _ -> Error ds

  let remove_last a ds =
    match !(!a) with
    | T (Last last, d', _) -> (
      match !last with
      | T (Node l, d, N) ->
          last := T (Node l, d', N) ;
          Elem.remove d ds
      | _ -> Error ds )
    | _ -> Error ds
end

module Elem = struct
  type t = {uuid: int; data: string}

  module U = Map.Make (Int)
  module D = Map.Make (String)

  type ds = D of t dl ref U.t * t dl ref D.t

  let empty = D (U.empty, D.empty)

  let create u d = {uuid= u; data= d}

  let remove i ds =
    match (i, ds) with
    | {uuid= i; data= s}, D (u, d) -> Ok (D (U.remove i u, D.remove s d))

  let insert n i ds =
    match (i, ds) with
    | {uuid= i; data= s}, D (u, d) -> Ok (D (U.add i n u, D.add s n d))

  let get_uuid i ds =
    match (i, ds) with
    | {uuid= i; data= _}, D (u, _) -> U.find_opt i u

  let get_data i ds =
    match (i, ds) with
    | {uuid= _; data= s}, D (_, d) -> D.find_opt s d

  let display = function
    | {uuid= u; data= s} -> Printf.printf "%d %s\n" u s
end

module Foo = DeliveryQueue (Elem)

exception Empty

exception Not_found

let r_to i m =
  let rec aux m' =
    match !m' with
    | E -> raise Empty
    | T (_, j, r) -> (
        if i = j then m := m'
        else
          match r with
          | N -> raise Not_found
          | Last r | Node r -> aux r )
  in
  aux !m

let l_to i m =
  let rec aux m' =
    match !m' with
    | E -> raise Empty
    | T (l, j, _) -> (
        if i = j then m := m'
        else
          match l with
          | N -> raise Not_found
          | Last l | Node l -> aux l )
  in
  aux !m

let () =
  let i = ref (ref E) in
  let ds =
    Foo.insert (Foo.create 1 "1") i Foo.empty
    |> function
    | Error ds -> ds
    | Ok ds -> (
        Foo.insert (Foo.create 2 "2") i ds
        |> function
        | Error ds -> ds
        | Ok ds -> (
            Foo.insert (Foo.create 3 "3") i ds
            |> function
            | Error ds -> ds
            | Ok ds -> (
                Foo.insert (Foo.create 4 "4") i ds
                |> function
                | Error ds -> ds
                | Ok ds -> (
                    Foo.insert (Foo.create 5 "5") i ds
                    |> function
                    | Error ds -> ds
                    | Ok ds -> (
                        Foo.insert (Foo.create 6 "6") i ds
                        |> function
                        | Error ds -> ds
                        | Ok ds -> ds ) ) ) ) )
  in
  let foo = Foo.create 2 "2" in
  let bar = Foo.create 5 "5" in
  print_string "\n\nhow\n" ;
  let _ =
    match (Foo.get_data foo ds, Foo.get_uuid foo ds) with
    | Some i, Some j -> Foo.display i ; Foo.display j
    | _, _ -> print_string "fail\n"
  in
  print_string "\n\nnow\n" ;
  Foo.display !i ;
  r_to foo i ;
  Foo.display !i ;
  l_to bar i ;
  Foo.display !i ;
  let remove_me = !i in
  print_string "\n\nbrown\n" ;
  l_to (Foo.create 6 "6") i ;
  Foo.walk_right !i ;
  let ds =
    match Foo.remove remove_me i ds with
    | Ok ds -> ds
    | Error ds -> ds
  in
  let _ =
    match Foo.get_data foo ds with
    | Some j -> Foo.remove j i ds
    | None -> Error ds
  in
  print_string "\n\ncow\n" ;
  l_to (Foo.create 6 "6") i ;
  Foo.walk_right !i
