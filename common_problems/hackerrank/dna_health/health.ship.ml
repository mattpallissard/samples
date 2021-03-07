module type WEIGHT = sig
  type data

  type node
end

type id = char * int

type mapping = int * int

type data = mapping list option

module W = struct
  type comparison = Lt | Eq | Gt

  module Tf = Map.Make (struct
    type t = id

    let compare = compare
  end)

  let empty = Tf.empty

  let stat tree = function
    | c, _ -> Tf.mem c tree

  let set tree = function
    | i, j -> Tf.add i j tree

  let get tree = function
    | i, _ -> (i, Tf.find i tree)

  let compare i j = if i = j then Eq else if i < j then Lt else Gt

  let merge_node i i' =
    match (i, i') with
    | Some w, Some w' -> Some (w @ w')
    | None, (Some _ as i') -> i'
    | (Some _ as i), None -> i
    | None, None -> None

  let exists i j =
    match (i, j) with
    | (i, j), (_, j') -> (i, merge_node j j')

  let write tree node =
    match stat tree node with
    | true -> set tree (exists (get tree node) node)
    | false -> set tree node
end

module I = struct
  let explode s =
    let rec exp i l = if i < 0 then l else exp (i - 1) (s.[i] :: l) in
    exp (String.length s - 1) []

  let split = Str.split (Str.regexp " ")

  let _ = read_line ()

  let genes = read_line ()

  let weights = read_line ()

  let num_items = int_of_string (read_line ())

  let get_weights =
    let rec word i tree g w =
      match (g, w) with
      | gh :: gt, wh :: wt ->
          let rec c j tree = function
            | [] -> tree
            | [ch] ->
                c (j + 1)
                  (W.write tree ((ch, j), Some [(i, int_of_string wh)]))
                  []
            | ch :: ct -> c (j + 1) (W.write tree ((ch, j), None)) ct
          in
          word (i + 1) (c 0 tree (explode gh)) gt wt
      | _ -> tree
    in
    word 0 W.empty (split genes) (split weights)

  exception INPUTERROR

  exception FAIL

  let score tree =
    let rec run min max = function
      | 0 -> (
        match (min, max) with
        | Some i, Some j -> Printf.printf "%d %d\n" i j
        | _ -> raise FAIL )
      | i -> (
        match split (read_line ()) with
        | h :: t :: s :: _ -> (
            let l = int_of_string h in
            let r = int_of_string t in
            let rec walk_string acc n p pl = function
              | c :: s ->
                  let rec sum acc = function
                    | [] -> acc
                    | h :: t -> (
                      match h with
                      | index, w -> (
                        match (index >= l, index <= r) with
                        | true, true -> sum (acc + w) t
                        | _ -> sum acc t ) )
                  in
                  let score pl =
                    let rec get_scores acc = function
                      | [] -> acc
                      | h :: t -> (
                        try
                          let item = W.get tree ((c, h), None) in
                          match item with
                          | _, Some j -> get_scores (sum acc j) t
                          | _, None -> get_scores acc t
                        with Not_found -> get_scores acc t )
                    in
                    get_scores acc pl
                  in
                  let same, pl' =
                    match n with
                    | Some n ->
                        if c = n then (p + 1, (p + 1) :: pl) else (0, [0])
                    | None -> (0, [0])
                  in
                  walk_string (score pl') (Some c) same pl' s
              | _ -> acc
            in
            let acc = walk_string 0 None 0 [0] (explode s) in
            Printf.printf "%s %d\n" s acc;
            match (min, max) with
            | None, None -> run (Some acc) (Some acc) (i - 1)
            | Some min, Some max ->
                if acc < min then run (Some acc) (Some max) (i - 1)
                else if acc > max then run (Some min) (Some acc) (i - 1)
                else run (Some min) (Some max) (i - 1)
            | _ -> raise INPUTERROR )
        | _ -> raise INPUTERROR )
    in
    run None None num_items
end

let () =
  let foo = I.get_weights in
  I.score foo
