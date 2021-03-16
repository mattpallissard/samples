let inc i = 1 + i

let explode s =
  let rec exp i l = if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

(* this strategy is pretty rough *)

module type SET = sig
  type t

  type id

  type score

  type key

  val print : key -> unit

  val unscored : score

  val eq : key -> key -> bool

  val sum : score -> score -> score
end

module Trie (S : SET) = struct
  type key = S.key

  module T = Map.Make (struct
    type t = key

    let compare = compare
  end)

  type t = S.t

  type data = S.score

  type bounds = Set of data | Unset of data

  type depth = int

  type 'a trie =
    | H of 'a children
    | B of key * depth * 'a children * 'a children option
    | R of key * depth * 'a children option * data * 'a children option
    | Nil

  and 'a children = 'a trie T.t

  let empty = Nil

  let emptyhead = H T.empty

  (*
          let acc' = S.sum weight acc in
          if S.eq h c then (match min, max with
              | Unset _, Unset _ -> 
                  let min' = Set weight in
                  let max' = Set weight in
                  T.find t m' |> aux min' max' (t :: r)
              | Set min, Set max ->
                  let min' = if weight < min then Set weight else Set min in
                  let max' = if weight > max then Set weight else Set max in
                  T.find t m' |> aux min' max' (t :: r)
              | Set min, Unset _ ->
                  let min' = if weight < min then Set weight else Set min in
                  T.find t m' |> aux min' max (t :: r)
              | Unset _, Set max ->
                  let max' = if weight > max then Set weight else Set max in
                  T.find t m' |> aux min max' (t :: r))
      else match fail with
        | Some fail -> T.find t fail |> aux min max r
        | None -> *)

  let score char_list m =
    let rec aux acc char_list m' =
      match char_list with
      | [] -> acc
      | [h] -> (
        match m' with
        | R (c, _, _, d, _) -> if S.eq h c then S.sum  d  acc else acc
        | H _ | B(_, _, _, _) | Nil -> acc)
      | h :: t :: r -> (
        match m' with
        | H m' -> (
          try T.find h m' |> aux acc (t :: r) with Not_found -> acc )
        | R (c, _, Some m', weight, fail) -> (
            if S.eq h c then S.sum weight acc |> S.sum (s m' (t :: r))
            else
              match fail with
              | Some fail -> S.sum (s fail (t :: r)) S.unscored
              | None -> S.sum (s m (t :: r)) S.unscored )
        | B (c, _, m', fail) -> (
            if S.eq h c then S.sum (s m' (t :: r)) acc
            else
              match fail with
              | Some fail -> S.sum (s fail (t :: r)) S.unscored
              | None -> S.sum (s m (t :: r)) S.unscored )
        | R (_, _, None, _, fail) -> (
          match fail with
          | Some fail -> S.sum (s fail (t :: r)) S.unscored
          | None -> S.sum (s m (t :: r)) S.unscored )
        | Nil -> acc )
    and s i j = T.to_seq i |> List.of_seq |> run j
    and run j = function
        | [] -> S.unscored
        | (_, v) :: t -> S.sum (aux S.unscored j v) (run j t)
    in
    s m char_list

  let rec get char_list m =
    match char_list with
    | [] -> raise Not_found
    | [h] -> (
      match m with
      | H _ -> raise Not_found
      | R (c, _, _, d, _) -> if S.eq h c then d else raise Not_found
      | B (_, _, _, _) -> raise Not_found
      | Nil -> raise Not_found )
    | h :: t :: r -> (
      match m with
      | H m -> T.find h m |> get (t :: r)
      | R (c, _, Some m, _, _) | B (c, _, m, _) ->
          if S.eq h c then T.find t m |> get (t :: r) else raise Not_found
      | R (_, _, None, _, _) -> raise Not_found
      | Nil -> raise Not_found )

  let get_fail_path c m =
    let rec aux acc m =
      let rec run = function
        | [] -> []
        | (_, v) :: t -> aux [] v @ run t
      in
      let s i = T.to_seq i |> List.of_seq |> run in
      match m with
      | R (c', _, None, _, _) -> if S.eq c c' then m :: acc else acc
      | Nil -> acc
      | H i -> s i
      | R (c', _, Some j, _, _) | B (c', _, j, _) ->
          let acc' = if S.eq c c' then m :: acc else acc in
          acc' @ s j
    in
    List.sort (fun i j -> compare j i) (aux [] m)

  let get_fail i j =
    let rec aux = function
      | [] -> None
      | h :: t -> (
        match h with
        | (B (_, h, m, _) | R (_, h, Some m, _, _)) as j ->
            if i < h then Some m else aux t
        | Nil | H _ | R (_, _, None, _, _) -> None )
    in
    aux j

  let rec display = function
    | [] -> ()
    | h :: t -> (
      match h with
      | Nil | H _ -> display t
      | R (c, d, _, _, _) | B (c, d, _, _) ->
          S.print c ; Printf.printf " %d\n" d ; display t )

  exception Neverhere

  let insert char_list data m gd =
    let rec aux depth m = function
      | [] -> raise Neverhere
      | [h] -> R (h, depth, None, data, gd h depth)
      | h :: t :: r -> (
        match m with
        | H m -> (
          match T.find_opt h m with
          | Some i -> H (T.add h (aux (inc depth) i (t :: r)) m)
          | None -> H (T.add h (aux (inc depth) Nil (t :: r)) m) )
        | Nil ->
            B
              ( h
              , depth
              , T.add t (aux (inc depth) Nil (t :: r)) T.empty
              , gd h depth )
        | B (c, depth, m, _) -> (
            if S.eq c h then
              match T.find_opt t m with
              | Some i ->
                  B
                    ( c
                    , depth
                    , T.add t (aux (inc depth) i (t :: r)) m
                    , gd h depth )
              | None ->
                  B
                    ( c
                    , depth
                    , T.add t (aux (inc depth) Nil (t :: r)) m
                    , gd h depth )
            else
              match T.find_opt h m with
              | Some i -> aux (inc depth) i (t :: r)
              | None ->
                  aux (inc depth) (B (h, depth, T.empty, gd h depth)) (t :: r) )
        | R (c, depth, m, d, _) -> (
          match m with
          | Some m -> (
              if S.eq c h then
                match T.find_opt t m with
                | Some i ->
                    R
                      ( c
                      , depth
                      , Some (T.add t (aux (inc depth) i r) m)
                      , d
                      , gd h depth )
                | None ->
                    R
                      ( c
                      , depth
                      , Some
                          (T.add t
                             (aux
                                (inc (inc depth))
                                (B (h, inc depth, T.empty, gd h depth))
                                (t :: r))
                             m)
                      , d
                      , gd c depth )
              else
                match T.find_opt h m with
                | Some i ->
                    R
                      ( c
                      , depth
                      , Some (T.add t (aux (inc depth) i (t :: r)) m)
                      , d
                      , gd c depth )
                | None ->
                    R
                      ( c
                      , depth
                      , Some
                          (T.add t
                             (aux
                                (inc (inc depth))
                                (B (h, inc depth, T.empty, gd h depth))
                                (t :: r))
                             m)
                      , d
                      , gd c depth ) )
          | None ->
              if S.eq c h then
                R
                  ( c
                  , depth
                  , Some (T.add t (aux (inc depth) Nil (t :: r)) T.empty)
                  , d
                  , gd c depth )
              else
                R
                  ( h
                  , depth
                  , Some (T.add t (aux (inc depth) Nil (t :: r)) T.empty)
                  , d
                  , gd h depth ) ) )
    in
    aux 0 m char_list
end

module Set = struct
  type score = int

  type id = int

  type t = score * id

  type mapping = char list * score

  type key = char

  let unscored = 0

  let print = Printf.printf "%c"

  let eq i j = i = j

  let sum i j = i + j
end

module A = Trie (Set)

module I = struct
  let split = String.split_on_char ' '

  let num = int_of_string (read_line ())

  let genes = read_line ()

  let weights = read_line ()

  let num_items = int_of_string (read_line ())


  exception Input_error
  let set_tree genes weights =
    let f _ _ = None in
    let rec aux m g w = match g, w with
    | [], [] -> m
    | hg :: tg, hw :: tw -> aux (A.insert (explode hg) hw m f) tg tw
    | _, _ -> raise Input_error
    in
    aux A.empty genes weights

  let rebuild_tree genes weights m = 
    let f c depth = A.get_fail depth (A.get_fail_path c m) in
    let rec aux m g w = match g, w with
    | [], [] -> m
    | hg :: tg, hw :: tw -> aux (A.insert (explode hg) hw m f) tg tw
    | _, _ -> raise Input_error
    in
    aux (set_tree genes weights) genes weights



  let run_it = 
    let rec aux min max = function
      | 0 -> Printf.printf "%d %d\n" min max;
   



end


let durr m =
  let f c depth = A.get_fail depth (A.get_fail_path c m) in
  let foo = A.insert (explode "foo") 3 A.emptyhead f in
  let baz = A.insert (explode "foo") 4 foo f in
  let buzz = A.insert (explode "doodoo") 11 baz f in
  let fizz = A.insert (explode "doofus") 10 buzz f in
  let buzz =
    A.insert (explode "howdydoodymotherfuckerthisoneisloooong") 100 fizz f
  in
  let baz =
    A.insert (explode "howdydoodymotherfuckerthatoneisloooong") 200 buzz f
  in
  A.get (explode "foo") fizz |> Printf.printf "%d\n" ;
  A.get (explode "doofus") baz |> Printf.printf "%d\n" ;
  A.get (explode "doodoo") baz |> Printf.printf "%d\n"

let hurr =
  let f _ _ = None in
  let foo = A.insert (explode "foo") 3 A.emptyhead f in
  let baz = A.insert (explode "foo") 4 foo f in
  let buzz = A.insert (explode "doodoo") 11 baz f in
  let fizz = A.insert (explode "doofus") 10 buzz f in
  let buzz =
    A.insert (explode "howdydoodymotherfuckerthisoneisloooong") 100 fizz f
  in
  let baz =
    A.insert (explode "howdydoodymotherfuckerthatoneisloooong") 200 buzz f
  in
  A.get (explode "foo") fizz |> Printf.printf "%d\n" ;
  (*
  A.get (explode "fool") fizz |> Printf.printf "%d\n" ;
  *)
  A.get (explode "doofus") baz |> Printf.printf "%d\n" ;
  A.get (explode "doodoo") baz |> Printf.printf "%d\n" ;
  fizz

let () =
  (*
  A.get (explode "howdydoodymotherfuckerthisoneislooong") baz
  |> Printf.printf "%d\n" ;
  A.get (explode "howdydoodymotherfuckerthatoneisloooong") baz
  |> Printf.printf "%d\n" ;
  try A.get (explode "doo") baz |> Printf.printf "%d\n"

  with Not_found -> print_string "expected results\n"
*)
  hurr |> durr
