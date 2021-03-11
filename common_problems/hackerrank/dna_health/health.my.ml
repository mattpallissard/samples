type comparison = Lt | Gt | Eq

module type SET = sig
  type t

  type id

  type score

  type key

  val eq : key -> key -> bool

  val is_child : t -> bool
end

module Trie (S : SET) = struct
  type key = S.key

  module T = Map.Make (struct
    type t = key

    let compare = compare
  end)

  type t = S.t

  type data = S.score

  type 'a trie = Nil|  B of key * 'a children | R of key * 'a children option * data

  and 'a children = 'a trie T.t

  let empty = T.empty

  (*
   *
   * if tree node is equivalent
   *   if insert node is in map
   *     get list
   *       recur with tail
   *   else
   *     insert (recur with tail)
   *
   *
   *
   *
   * *)

  let insert char_list data m =
    let rec aux m = function
      | [] -> Nil
      | [h] -> R (h, None, data)
      | h :: t :: rest -> (
        match m with
        | B (c, i) -> (
            if S.eq c h then
              match T.find_opt t i with
              | Some m -> B (c, aux m rest)
              | None -> B (c, (T.add (aux B (t, T.empty) rest)) i)
            else
              match T.find_opt h i with
              | Some m -> B (c, aux m rest)
              | None -> B (c, (T.add (aux B (h, T.empty) rest)) i) )
        | R (c, None, _) ->
            if S.eq c h then B (c, T.add (aux B (t, T.empty) rest))
            else B (c, T.add (aux B (h, T.empty) rest))
        | R (c, Some i, _) -> (
            if S.eq c h then
              match T.find_opt t i with
              | Some m -> B (c, aux m rest)
              | None -> B (c, (T.add (aux B (t, T.empty) rest)) i)
            else
              match T.find_opt h i with
              | Some m -> B (c, aux m rest)
              | None -> B (c, (T.add (aux B (h, T.empty) rest)) i) ) )
    in
    aux m char_list
end

module Set = struct
  type score = int

  type id = int

  type t = score * id

  type mapping = char list * score
end
