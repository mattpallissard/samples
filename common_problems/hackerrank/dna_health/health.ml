open Sexplib

type comparison = Lt | Eq | Gt

module type ORDERED = sig
  type t

  val compare : t -> t -> comparison

  val show : t -> unit
end

module type SET = sig
  type elem

  type set

  type color

  val empty : set

  val get : elem -> set -> elem list

  val insert : elem -> set -> set

  val balance : color * set * elem * set -> set
end

module RBS (Element : ORDERED) : SET with type elem = Element.t = struct
  type elem = Element.t

  type color = R | B

  type tree = E | T of color * tree * elem * tree

  type set = tree

  let empty = E

  let get x set =
    let rec aux = function
      | E -> []
      | T (_, j, k, l) -> (
        match Element.compare x k with
        | Gt -> aux l
        | Eq -> (k :: aux j) @ aux j
        | Lt -> aux j )
    in
    aux set

  let balance = function
    | B, T (R, T (R, i, j, k), l, m), n, o ->
        T (R, T (B, i, j, k), l, T (B, m, n, o))
    | B, T (R, i, j, T (R, k, l, m)), n, o ->
        T (R, T (B, i, j, k), l, T (B, m, n, o))
    | B, i, j, T (R, T (R, k, l, m), n, o) ->
        T (R, T (B, i, j, k), l, T (B, m, n, o))
    | B, i, j, T (R, k, l, T (R, m, n, o)) ->
        T (R, T (B, i, j, k), l, T (B, m, n, o))
    | i, j, k, l -> T (i, j, k, l)

  let insert i j =
    let rec aux = function
      | E -> T (R, E, i, E)
      | T (color, k, l, m) as elem -> (
        match Element.compare i l with
        | Lt | Eq -> balance (color, aux k, l, m)
        | Gt -> balance (color, k, l, aux m) )
    in
    match aux j with
    | T (_, i, j, k) -> T (B, i, j, k)
    | E -> E

  (* never empty *)
end

let sexp_of_char = Core.sexp_of_char
let char_of_sexp = Core.char_of_sexp
let int_of_sexp = Core.int_of_sexp
let sexp_of_int = Core.sexp_of_int

type node = B of char | R of char * int * int [@@deriving sexp]

module Ordered = struct
  type t = node [@@deriving sexp]

  let compare i j =
    let aux i j = if i = j then Eq else if i < j then Lt else Gt in
    match (i, j) with
    | R (i, _, _), R (j, _, _) -> aux i j
    | B i, B j -> aux i j
    | R (i, _, _), B j -> aux i j
    | B i, R (j, _, _) -> aux i j

  let show = function
    | B i -> Printf.printf "black: %c\n" i
    | R (i, j, k) -> Printf.printf "Red: %c %d %d\n" i j k
end

module W = RBS (Ordered)

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

let display = function
  | B i -> Printf.printf "black: %c\n" i
  | R (i, j, k) -> Printf.printf "red: %c %d %d\n" i j k

let () =
  let foo = I.get_weights in
  List.map display (W.get (B 'a') foo) |> fun _ -> () ; print_string "here\n"
