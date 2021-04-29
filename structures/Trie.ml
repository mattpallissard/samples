module type SET = sig
  type t

  type id

  type data

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

  type data = S.data

  type bounds = Set of data | Unset of data

  (*
    type depth = int  we can use this when we build failes for something like AhoCorasik 
    *)

  type 'a trie =
    | H of 'a children
    | B of key * 'a children
    | R of key * 'a children option * data
    | Nil

  and 'a children = 'a trie T.t

  let empty = Nil

  let emptyhead = H T.empty

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
                match T.find_opt t m with
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
