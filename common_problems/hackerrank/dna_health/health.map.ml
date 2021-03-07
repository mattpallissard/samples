module type WEIGHT = sig
  type data

  type node
end

type id = char * int

type mapping = int * int

type data = mapping list option



module Lt = Map.Make(struct type t = id let compare = compare end)
module W = struct
  type comparison = Lt | Eq | Gt

  let set tree = function
    | i, j -> Lt.add i j tree

  (*
  let set = function
    | i, j -> Hashtbl.replace tree i j
    *)

  let get tree = function
    | i, _ -> (i, Lt.find i tree)

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

  let write tree node = try set tree (exists (get tree node) node) with Not_found -> set tree node
end

module I = struct
  let explode s =
    let rec exp i l = if i < 0 then l else exp (i - 1) (s.[i] :: l) in
    exp (String.length s - 1) []

  let split = String.split_on_char ' '

  let num = int_of_string (read_line ())

  let genes =
    let t = Sys.time () in
    let foo = read_line () in
    Printf.printf "read genes: %fs\n" (Sys.time () -. t) ;
    Stream.of_string foo

  let weights =
    let t = Sys.time () in
    let foo = read_line () in
    Printf.printf "read weights: %fs\n" (Sys.time () -. t) ;
    Stream.of_string foo

  let num_items = int_of_string (read_line ())

  let get_weights =
    let open Core in
    let word tree i g w =
      let rec c tree j = function
        | [] -> tree
        | [ch] ->
            c (W.write tree ((ch, j), Some [(i, int_of_string w)])) (j + 1) []
        | ch :: ct ->
            c (W.write tree ((ch, j), None))(j + 1) ct
      in
      c tree 0 (explode g)
    in
    let rec iter_g tree i gs = function
      | 0 -> tree
      | num -> (
          Printf.printf "%d\n" num ;
          let rec iter_w i gs ws num =
            let wc = Stream.next weights in
            match Char.equal wc ' ' with
            | false -> iter_w i gs (ws ^ Char.to_string wc) num
            | true ->
                iter_g (word tree i gs ws) (i + 1) "" (num - 1)
          in
          try
            let gc = Stream.next genes in
            match Char.equal gc ' ' with
            | true -> iter_w i gs "" num
            | false -> iter_g tree i (gs ^ Char.to_string gc) num
          with Stream.Failure -> tree
      )
    in
    iter_g Lt.empty 0 "" num

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
  let t1 = Sys.time () in
  let foo = I.get_weights in
  Printf.printf "Execution time: %fs\n" (Sys.time () -. t1) ;
  (*
  W.display foo |> fun _ -> ();
  *)
  let t2 = Sys.time () in
  I.score foo;
  Printf.printf "Execution time: %fs\n" (Sys.time () -. t2)
