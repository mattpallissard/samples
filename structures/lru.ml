exception Empty

exception Eof

(*
module M = Map.Make (Int)
*)


type 'a dl = E | T of 'a p * 'a * 'a p

and 'a p = N | P of 'a dl ref

let h = Hashtbl.create 10
let init i = ([], i, [])

let dl_of_list = function
  | h :: t -> ([], h, t)
  | [] -> raise Empty

let empty = E

let insert i node m =
  match !(!node) with
  | E ->
      let n = T (N, i, N) in
      node := ref n ;
      (*
      M.add i (ref n) m
      *)
      Hashtbl.add h i (ref (ref n))
  | T (l, d, P r) ->
      let rec n = T (l, i, P (ref t))
      and t = T (P (ref n), d, P r) in
      Hashtbl.find h d := ref t;
      node := ref n ;
      (*
      M.add i (ref n) m
      *)
      Hashtbl.add h i (ref (ref n))
  | T (l, d, r) ->
      let rec n = T (l, i, P (ref t))
      and t = T (P (ref n), d, r) in
      node := ref n ;
      (*
      M.add i (ref n) m
      *)
      Hashtbl.add h i (ref (ref n))

      (*
let check_it m =
  match !m with
  | E -> raise Empty
  | T (_, i, P r) ->
      let rec aux prev x =
        match !x with
        | E -> print_string "empty 1\n"
        | T (l, d, r) -> (
            let checkl l =
              match l with
              | N -> print_string "fuck!\n"
              | P l -> (
                match !l with
                | E -> Printf.printf "empty: %d" d
                | T (_, ld, _) ->
                    if prev = ld then Printf.printf "match left: %d\n" prev
                    else Printf.printf "no good: %d %d\n" prev ld )
            in
            checkl l ;
            match r with
            | N -> print_string "end\n"
            | P i -> aux d i )
      in
      aux i r
      *)

let current = function
  | E -> raise Empty
  | T (_, i, _) -> i

let next = function
  | E -> raise Empty
  | T (_, _, r) -> r

let prev = function
  | lh :: lt, i, r -> (lh, lt, i :: r)
  | _ -> raise Eof

let remove m =
  match !(!m) with
  (* the symantics of this are inconsistent
   * we typically reutrn the right as a cursor
   * but, if the right is empty we return the left*)
  | E -> raise Empty
  | T (N, d, N) ->
      print_string ".1\n" ;
      Hashtbl.remove h d;
      m := ref E
  | T (N, d, P r) ->
      print_string ".2\n" ;
      Hashtbl.remove h d;
      m := r
  | T (P l, d, N) ->
      print_string "-3\n" ;
      Hashtbl.remove h d;
      m := l
  | T (P l, d, P r) -> (
    match (!l, !r) with
    | E, E -> raise Empty
    | (T (_, _, _)), E ->
        m := l
    | E, (T (_, _, _)) ->
        print_string ".6\n" ;
        m := r
    | T (ll, ld, P lr), T (P rl, rd, P rr) ->
        let rec n = T (ll, ld, P (ref t)) and t = T (P (ref n), rd, P rr) in
        Hashtbl.remove h d;
        Hashtbl.find h rd := ref t;
        lr := t;
        rl := n;)

let rec r_to i m =
  let rec aux m' = match !m' with
    | E -> raise Empty
    | T (_, j, r) -> (
        if i = j then m := m'
        else
          match r with
          | N -> raise Not_found
          | P r -> aux r )
  in
  aux !m

let rec l_to i m =
  let rec aux m' = match !m' with
    | E -> raise Empty
    | T (l, j, _) -> (
        if i = j then m := m'
        else
          match l with
          | N -> raise Not_found
          | P l -> aux l )
  in
  aux !m


let rec display = function
  | E -> ()
  | T (_, i, r) -> (
      Printf.printf "%d\n" i ;
      match r with
      | N -> ()
      | P r -> display !r )

let check i = match i with
  | T (N, d, _) -> Printf.printf "%d: bad left\n" d
  | T (_, _, N) -> print_string "bad right\n"
  | E -> print_string "empty\n"
  | T (P _, _, P _) -> print_string "good\n"

let () =
  let z = ref E in
  let a = ref z in
  let () =
    insert 1 a
    |> insert 2 a
    |> insert 3 a
    |> insert 4 a
    |> insert 5 a
    |> insert 6 a
    |> insert 7 a
  in

  check !(!(Hashtbl.find h 4));

  display !(!a) |> print_newline;
  check !(!a);

  remove (Hashtbl.find h 4);
  display !(!a) |> print_newline;

  (*
  check !(M.find 4 m);
  *)
(*
let () =
  let a = ref (T(N, 1, N)) in
  let m = M.add 1 a M.empty in

  a := (T (N, 1, P (a)));

  if (M.find 1 m) = a then print_string "fail\n" else print_string "win\n"

*)
