let inc i = 1 + i

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

  type depth = int

  type 'a trie =
    | H of 'a children
    | B of key * depth * 'a children
    | R of key * depth * 'a children option * data
    | Nil

  and 'a children = 'a trie T.t

  let empty = Nil

  let emptyhead = H T.empty

  let rec get char_list m =
    match char_list with
    | [] -> raise Not_found
    | [h] -> (
      match m with
      | H _ -> raise Not_found
      | R (c, _, _, d) -> if S.eq h c then d else raise Not_found
      | B (_, _, _) -> raise Not_found
      | Nil -> raise Not_found )
    | h :: t :: r -> (
      match m with
      | H m -> T.find h m |> get (t :: r)
      | R (c, _, Some m, _) | B (c, _, m) ->
          if S.eq h c then T.find t m |> get (t :: r) else raise Not_found
      | R (_, _, None, _) -> raise Not_found
      | Nil -> raise Not_found )

  let get_fail_path c m =
    (* this strategy is pretty rough *) 
    let rec aux acc m =
      let rec run = function
        | [] -> []
        | (_, v) :: t -> aux [] v @ run t
      in
      let s i = T.to_seq i |> List.of_seq |> run in
      match m with
      | R (c', _, None, _) -> if S.eq c c' then m :: acc else acc
      | Nil -> acc
      | H i -> s i
      | R (c', _, Some j, _) | B (c', _, j) ->
          let acc' = if S.eq c c' then m :: acc else acc in
          acc' @ s j
    in
    aux [] m

  let rec display = function
    | [] -> ()
    | h :: t -> (
      match h with
      | Nil | H _ -> display t
      | R (c, d, _, _) | B (c, d, _) ->
          S.print c ; Printf.printf " %d\n" d ; display t )

  exception Neverhere

  let insert char_list data m =
    let rec aux depth m = function
      | [] -> raise Neverhere
      | [h] -> R (h, depth, None, data)
      | h :: t :: r -> (
        match m with
        | H m -> (
          match T.find_opt h m with
          | Some i -> H (T.add h (aux (inc depth) i (t :: r)) m)
          | None -> H (T.add h (aux (inc depth) Nil (t :: r)) m) )
        | Nil -> B (h, depth, T.add t (aux (inc depth) Nil (t :: r)) T.empty)
        | B (c, depth, m) -> (
            if S.eq c h then
              match T.find_opt t m with
              | Some i -> B (c, depth, T.add t (aux (inc depth) i (t :: r)) m)
              | None -> B (c, depth, T.add t (aux (inc depth) Nil (t :: r)) m)
            else
              match T.find_opt h m with
              | Some i -> aux (inc depth) i (t :: r)
              | None -> aux (inc depth) (B (h, depth, T.empty)) (t :: r) )
        | R (c, depth, m, d) -> (
          match m with
          | Some m -> (
              if S.eq c h then
                match T.find_opt t m with
                | Some i ->
                    R (c, depth, Some (T.add t (aux (inc depth) i r) m), d)
                | None ->
                    R
                      ( c
                      , depth
                      , Some
                          (T.add t
                             (aux
                                (inc (inc depth))
                                (B (h, inc depth, T.empty))
                                (t :: r))
                             m)
                      , d )
              else
                match T.find_opt h m with
                | Some i ->
                    R
                      ( c
                      , depth
                      , Some (T.add t (aux (inc depth) i (t :: r)) m)
                      , d )
                | None ->
                    R
                      ( c
                      , depth
                      , Some
                          (T.add t
                             (aux
                                (inc (inc depth))
                                (B (h, inc depth, T.empty))
                                (t :: r))
                             m)
                      , d ) )
          | None ->
              if S.eq c h then
                R
                  ( c
                  , depth
                  , Some (T.add t (aux (inc depth) Nil (t :: r)) T.empty)
                  , d )
              else
                R
                  ( h
                  , depth
                  , Some (T.add t (aux (inc depth) Nil (t :: r)) T.empty)
                  , d ) ) )
    in
    aux 0 m char_list
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
  (*
  A.get (explode "howdydoodymotherfuckerthisoneislooong") baz
  |> Printf.printf "%d\n" ;
  A.get (explode "howdydoodymotherfuckerthatoneisloooong") baz
  |> Printf.printf "%d\n" ;
  try A.get (explode "doo") baz |> Printf.printf "%d\n"

  with Not_found -> print_string "expected results\n"
*)

  A.get_fail_path 'd' baz |> A.display
