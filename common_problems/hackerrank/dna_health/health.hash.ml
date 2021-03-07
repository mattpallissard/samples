module type WEIGHT = sig
  type data

  type node
end

type id = char * int

type mapping = int * int

type data = mapping list option
type data = mapping list option

module My = struct
  type t = id

  let equal i j = i = j

  let hash foo =  match foo with
    | (c, i) -> i land (int_of_char c)
end

module MyT = Hashtbl.Make (My)

let tree = MyT.create 20480

module W = struct
  type comparison = Lt | Eq | Gt

  let set = function
    | i, j -> MyT.replace tree i j

  (*
  let set = function
    | i, j -> Hashtbl.replace tree i j
    *)

  let get = function
    | i, _ -> (i, MyT.find tree i)

  let compare i j = if i = j then Eq else if i < j then Lt else Gt

  let merge_node i i' =
    match (i, i') with
    | Some w, Some w' ->
        Printf.printf "%d %d\n" (List.length w') (List.length w'); Some (w @ w')
    | None, (Some _ as i') -> i'
    | (Some _ as i), None -> i
    | None, None -> None

  let exists i j =
    match (i, j) with
    | (i, j), (_, j') -> (i, merge_node j j')

  let write node = try set (exists (get node) node) with Not_found -> set node
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
    let word i g w =
      let rec c j = function
        | [] -> ()
        | [ch] ->
            W.write ((ch, j), Some [(i, int_of_string w)]) ;
            c (j + 1) []
        | ch :: ct ->
            W.write ((ch, j), None) ;
            c (j + 1) ct
      in
      c 0 (explode g)
    in
    let rec iter_g i gs = function
      | 0 -> ()
      | num -> (
        (*
          Printf.printf "%d\n" num ;
          *)
          let rec iter_w i gs ws num =
            let wc = Stream.next weights in
            match Char.equal wc ' ' with
            | false -> iter_w i gs (ws ^ Char.to_string wc) num
            | true ->
                (*
                Printf.printf "%s %s\n" gs ws;
                *)
                word i gs ws ;
                iter_g (i + 1) "" (num - 1)
          in
          let gc = Stream.next genes in
          match Char.equal gc ' ' with
          | true -> iter_w i gs "" num
          | false -> iter_g i (gs ^ Char.to_string gc) num )
    in
    try iter_g 0 "" num with Stream.Failure -> ()

  exception INPUTERROR

  exception FAIL

  let score =
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
                          let item = W.get ((c, h), None) in
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
  I.get_weights ;
  Printf.printf "Execution time: %fs\n" (Sys.time () -. t1) ;
  (*
  W.display foo |> fun _ -> ();
  *)
  let t2 = Sys.time () in
  I.score ;
  Printf.printf "Execution time: %fs\n" (Sys.time () -. t2)
