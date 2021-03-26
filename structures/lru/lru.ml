exception Empty

exception Empty1

exception Empty2

exception Neverhere

exception Eof

type 'a dl = E | T of 'a p * 'a * 'a p

and 'a p = N | P of 'a dl ref

let h = Hashtbl.create 10

let init i = ([], i, [])

let empty = E

(*
let r_to i m =
  let rec aux m' =
    match !m' with
    | E -> raise Empty
    | T (_, j, r) -> (
        if i = j then m := !m'
        else
          match r with
          | N -> raise Not_found
          | P r -> aux r )
  in
  aux m

let l_to i m =
  let rec aux m' =
    match !m' with
    | E -> raise Empty
    | T (l, j, _) -> (
        if i = j then m := m'
        else
          match l with
          | N -> raise Not_found
          | P l -> aux l )
  in
  aux !m

let check = function
  | E -> print_string "empty\n"
  | T (N, d, N) -> Printf.printf "%d: none\n" d
  | T (P _, d, N) -> Printf.printf "%d: no r\n" d
  | T (N, d, P _) -> Printf.printf "%d: no l\n" d
  | T (P _, d, P _) -> Printf.printf "%d: both\n" d

let rec check_r = function
  | E -> print_string "empty\n"
  | T (N, d, N) -> Printf.printf "%d: none\n" d
  | T (P l, d, N) ->
      Printf.printf "%d: no r\n" d ;
      check_l !l
  | T (N, d, P r) ->
      Printf.printf "%d: no l\n" d ;
      check_r !r
  | T (P _, d, P r) ->
      Printf.printf "%d: both\n" d ;
      check_r !r

and check_l = function
  | E -> print_string "empty\n"
  | T (N, d, N) -> Printf.printf "%d: none\n" d
  | T (P l, d, N) ->
      Printf.printf "%d: no r\n" d ;
      check_l !l
  | T (N, d, P _) -> Printf.printf "%d: no l\n" d
  | T (P l, d, P _) ->
      Printf.printf "%d: both\n" d ;
      check_l !l

let current = function
  | E -> raise Empty
  | T (_, i, _) -> i

let next = function
  | E -> raise Empty
  | T (_, _, r) -> r

let prev = function
  | lh :: lt, i, r -> (lh, lt, i :: r)
  | _ -> raise Eof
  *)

let insert i node =
  match !(!node) with
  | E ->
      let n = ref (T (N, i, N)) in
      node := n ;
      Hashtbl.add h i n
  | T (N, d, P r) -> (
    match !r with
    | T (_, _, _) ->
        let n = ref (T (N, i, P !node)) in
        !node := T (P n, d, P r) ;
        node := n ;
        Hashtbl.add h i n
    | E -> raise Neverhere )
  | T (N, d, N) ->
      let n = ref (T (N, i, P !node)) in
      !node := T (P n, d, N) ;
      node := n ;
      Hashtbl.add h i n
  | T (P _, _, _) -> raise Neverhere

let remove m a =
  match !m with
  | E | T (N, _, N) -> raise Neverhere
  | T (N, d, P i) -> (
    match !i with
    | T (P _, dl, P r) ->
        i := T (N, dl, P r) ;
        a := i ;
        Hashtbl.remove h d
    | _ -> raise Neverhere )
  | T (P i, d, N) -> (
    match !i with
    | T (l, dl, P _) ->
        i := T (l, dl, N) ;
        Hashtbl.remove h d
    | _ -> raise Neverhere )
  | T (P l, d, P r) -> (
    match (!l, !r) with
    | T (_, _, _), E -> raise Neverhere
    | E, T (_, _, _) -> raise Neverhere
    | T (ll, ld, _), T (_, rd, rr) ->
        l := T (ll, ld, P r) ;
        r := T (P l, rd, rr) ;
        Hashtbl.remove h d
    | _, _ -> raise Empty2 )

let rec display = function
  | E -> print_string "empty\n"
  | T (_, i, r) -> (
      Printf.printf "%d\n" i ;
      match r with
      | N -> print_string "end\n"
      | P r -> display !r )

let get i a =
  let j = Hashtbl.find h i in
  match !j with
  | T (_, v, _) -> remove j a ; insert v a ; v
  | _ -> raise Neverhere

let () =
  let z = ref E in
  let a = ref z in
  let () =
    insert 1 a ;
    insert 2 a ;
    insert 3 a ;
    insert 4 a ;
    insert 5 a ;
    insert 6 a ;
    insert 7 a
  in
  () ;
  get 7 a |> Printf.printf "-%d\n\n" ;
  get 6 a |> Printf.printf "-%d\n\n" ;
  get 5 a |> Printf.printf "-%d\n\n" ;
  get 4 a |> Printf.printf "-%d\n\n" ;
  get 3 a |> Printf.printf "-%d\n\n" ;
  get 2 a |> Printf.printf "-%d\n\n" ;
  display !(!a) |> print_newline

(*
  get 6 a |> Printf.printf "%d\n\n" ;
  display !(!a) |> print_newline ;
  get 5 a |> Printf.printf "%d\n\n" ;
  display !(!a) |> print_newline ;
  get 4 a |> Printf.printf "%d\n\n" ;
  display !(!a) |> print_newline ;
  get 3 a |> Printf.printf "%d\n\n" ;
  display !(!a) |> print_newline ;
  get 2 a |> Printf.printf "%d\n\n" ;
  get 1 a |> Printf.printf "%d\n\n" ;
  display !(!a) |> print_newline
  display !(!a) |> print_newline ;
  remove (Hashtbl.find h 4) ;
  display !(!a) |> print_newline ;
  remove (Hashtbl.find h 1) ;
  display !(!a) |> print_newline
  get 7 a |> Printf.printf "%d\n\n";
  get 4 a |> Printf.printf "%d\n\n";
  display (!a) |> print_newline
  check (!a);
*)

(*
  check !(!(Hashtbl.find h 4));
  check !(!a);
  check !(M.find 4 m);
  *)
(*
let () =
  let a = ref (T(N, 1, N)) in
  let m = M.add 1 a M.empty in

  a := (T (N, 1, P (a)));

  if (M.find 1 m) = a then print_string "fail\n" else print_string "win\n"

*)
