type comparison = Lt | Gt | Eq

module type SET = sig
  type t

  type id

  type score

  type key

  val print : key -> unit

  val eq : key -> key -> bool
end

module Trie (S : SET) = struct
  type key = S.key

  module T = Map.Make (struct
    type t = key

    let compare = compare
  end)

  type t = S.t

  type data = S.score

  type 'a trie =
    | H of 'a children
    | B of key * 'a children
    | R of key * 'a children option * data
    | Nil

  and 'a children = 'a trie T.t

  (*https://www.lri.fr/~filliatr/publis/enum2.pdf *)

  let get_fail c m =
    let rec aux = function
      | R (_, None, _) | Nil | H _ -> None
      | (B (c', i) | R (c', Some i, _)) as j -> (
          if S.eq c c' then Some j
          else
            try T.find c m
            with Not_found -> (
              match aux_seq (T.to_seq m |> List.of_seq) with
              | Some i -> i
              | None -> aux j ) )
    and aux_seq = function
      | [] -> None
      | h :: t -> (
        match h with
        | B (_, i) | R (_, Some i, _) -> (
          match aux h with
          | Some i -> i
          | None -> aux_seq t ) )
    in
    aux m

  let empty = Nil

  let emptyhead = H T.empty

  let rec get char_list m =
    match char_list with
    | [] -> raise Not_found
    | [h] -> (
      match m with
      | H _ -> raise Not_found
      | R (c, _, d) -> if S.eq h c then d else raise Not_found
      | B (_, _) -> raise Not_found
      | Nil -> raise Not_found )
    | h :: t :: r -> (
      match m with
      | H m -> T.find h m |> get (t :: r)
      | R (c, Some m, _) | B (c, m) ->
          if S.eq h c then T.find t m |> get (t :: r) else raise Not_found
      | R (_, None, _) -> raise Not_found
      | Nil -> raise Not_found )

  exception Neverhere

  let insert char_list data m =
    let rec aux m = function
      | [] -> raise Neverhere
      | [h] -> R (h, None, data)
      | h :: t :: r -> (
        match m with
        | H m -> (
          match T.find_opt h m with
          | Some i -> H (T.add h (aux i (t :: r)) m)
          | None -> H (T.add h (aux Nil (t :: r)) m) )
        | Nil -> B (h, T.add t (aux Nil (t :: r)) T.empty)
        | B (c, m) -> (
            if S.eq c h then
              match T.find_opt t m with
              | Some i -> B (c, T.add t (aux i (t :: r)) m)
              | None -> B (c, T.add t (aux Nil (t :: r)) m)
            else
              match T.find_opt h m with
              | Some i -> aux i (t :: r)
              | None -> aux (B (h, T.empty)) (t :: r) )
        | R (c, m, d) -> (
          match m with
          | Some m -> (
              if S.eq c h then
                match T.find_opt t m with
                | Some i -> R (c, Some (T.add t (aux i r) m), d)
                | None ->
                    R (c, Some (T.add t (aux (B (h, T.empty)) (t :: r)) m), d)
              else
                match T.find_opt h m with
                | Some i -> R (c, Some (T.add t (aux i (t :: r)) m), d)
                | None ->
                    R (c, Some (T.add t (aux (B (h, T.empty)) (t :: r)) m), d) )
          | None ->
              if S.eq c h then
                R (c, Some (T.add t (aux Nil (t :: r)) T.empty), d)
              else R (h, Some (T.add t (aux Nil (t :: r)) T.empty), d) ) )
    in
    aux m char_list
end

module Set = struct
  type score = int

  type id = int

  type t = score * id

  type mapping = char list * score

  type key = char

  let print = Printf.printf "%c"

  let eq i j = i = j
end

module A = Trie (Set)

let explode s =
  let rec exp i l = if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

let () =
  let foo = A.insert (explode "foo") 3 A.emptyhead in
  let baz = A.insert (explode "foo") 4 foo in
  let buzz = A.insert (explode "doodoo") 11 baz in
  let fizz = A.insert (explode "doofus") 10 buzz in
  let buzz =
    A.insert (explode "howdydoodymotherfuckerthisoneisloooong") 100 fizz
  in
  let baz =
    A.insert (explode "howdydoodymotherfuckerthatoneisloooong") 200 buzz
  in
  A.get (explode "foo") fizz |> Printf.printf "%d\n" ;
  (*
  A.get (explode "fool") fizz |> Printf.printf "%d\n" ;
  *)
  A.get (explode "doofus") baz |> Printf.printf "%d\n" ;
  A.get (explode "doodoo") baz |> Printf.printf "%d\n" ;
  A.get (explode "howdydoodymotherfuckerthisoneislooong") baz
  |> Printf.printf "%d\n" ;
  A.get (explode "howdydoodymotherfuckerthatoneisloooong") baz
  |> Printf.printf "%d\n" ;
  try A.get (explode "doo") baz |> Printf.printf "%d\n"
  with Not_found -> print_string "expected results\n"
