open Core

type trie = Trie of (int * int) option * char_to_children
and char_to_children = (char * trie) list [@@deriving sexp]

let empty = Trie (None, []) [@@deriving sexp]

let rec children_of_char c = function
  | (k, v) :: t -> if Char.equal k c then Some v else children_of_char c t
  | _ -> None

let rec lookup_with_index w index = function
  | Trie (k, v) as trie ->
      if index + 1 <= String.length w then
        match children_of_char w.[index] v with
        | Some trie -> lookup_with_index w (index + 1) trie
        | None -> None
      else k

let example =
  Trie
    ( None
    , [ ('i', Trie (Some (11, 12), [('n', Trie (Some (5, 12), [('n', Trie (Some (9,12), []))]))]))
      ; ( 't'
        , Trie
            ( None
            , [ ( 'e'
                , Trie
                    ( None
                    , [ ('n', Trie (Some (12, 2), []))
                      ; ('d', Trie (Some (4, 2), []))
                      ; ('a', Trie (Some (3, 5), [])) ] ) )
              ; ('o', Trie (Some (7,9), [])) ] ) )
      ; ('A', Trie (Some (15,12), [])) ] )

let bar = sexp_of_trie example

let formatter = Format.formatter_of_out_channel Stdio.stdout

let f =
  Sexp.pp_hum formatter bar ;
  Format.pp_print_flush formatter ()



(*
module I = struct
  let explode s =
    let rec exp i l = if i < 0 then l else exp (i - 1) (s.[i] :: l) in
    exp (String.length s - 1) []

  let split = String.split_on_chars ~on:[' ']

  let num = int_of_string (In_channel.input_line_exn In_channel.stdin)

  let genes =
    Stream.of_string (In_channel.input_line_exn In_channel.stdin)

  let weights =
    Stream.of_string (In_channel.input_line_exn In_channel.stdin)

  let num_items = int_of_string (In_channel.input_line_exn In_channel.stdin)
  let get_weights =
    let open Core in
    let word tree g w =
      let rec c tree j = function
        | [] -> tree
        | [ch] -> c (W.insert (R (ch, j, int_of_string w)) tree) (j + 1) []
        | ch :: ct -> c (W.insert (B ch) tree) (j + 1) ct
      in
      c tree 0 (explode g)
    in
    let rec iter_g tree i gs = function
      | 0 -> tree
      | num -> (
          let rec iter_w i gs ws num =
            match Stream.peek weights with
            | None -> tree
            | Some _ -> (
                let wc = Stream.next weights in
                match Char.equal wc ' ' with
                | false -> iter_w i gs (ws ^ Char.to_string wc) num
                | true -> iter_g (word tree gs ws) (i + 1) "" (num - 1) )
          in
          match Stream.peek genes with
          | None -> tree
          | Some _ -> (
              let gc = Stream.next genes in
              match Char.equal gc ' ' with
              | true -> iter_w i gs "" num
              | false -> iter_g tree i (gs ^ Char.to_string gc) num ) )
    in
    iter_g W.empty 0 "" num
end

*)
