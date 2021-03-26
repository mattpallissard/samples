exception Empty
exception Empty1
exception Empty2

exception Eof

type 'a dl = E | T of 'a p * 'a * 'a p

and 'a p = N | P of 'a dl ref

let h = Hashtbl.create 10

let init i = ([], i, [])

let dl_of_list = function
  | h :: t -> ([], h, t)
  | [] -> raise Empty

let empty = E

let insert i node =
  match !node with
  | E ->
      let n = T (N, i, N) in
      node := n ;
      Hashtbl.add h i (ref n)
  | T (l, d, P r) ->
      let rec n = T (l, i, P (ref t)) and t = T (P (ref n), d, P r) in
      node := n ;
      Hashtbl.find h d := t ;
      Hashtbl.add h i (ref n)
  | T (l, d, r) ->
      let rec n = T (l, i, P (ref t)) and t = T (P (ref n), d, r) in
      node := n ;
      Hashtbl.add h i (ref n)

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
  match !m with
  | E | T (N, _, N) -> print_string "uno\n"; raise Empty1
  | T (N, _, P i) | T (P i, _, N) ->
      print_string "dos\n";
      m := !i
  | T (P l, d, P r) -> (
      print_string "tres\n";
    match (!l, !r) with
    | T (_, _, _), E -> print_string "quatro\n"; m := !l
    | E, T (_, _, _) -> print_string "cinco\n";m := !r
    | T (ll, ld, P lr), T (P rl, rd, rr) ->
        let rec n = T (ll, ld, P (ref t)) and t = T (P (ref n), rd, rr) in
        Printf.printf "%d %d\n" ld rd;
        Hashtbl.remove h d ;
        lr := t ;
        rl := n
    | _, _ -> raise Empty2 )

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

let rec display = function
  | E -> ()
  | T (_, i, r) -> (
      Printf.printf "%d\n" i ;
      match r with
      | N -> ()
      | P r -> display !r )

let check i =
  match i with
  | T (N, d, _) -> Printf.printf "%d: bad left\n" d
  | T (_, _, N) -> print_string "bad right\n"
  | E -> print_string "empty\n"
  | T (P _, _, P _) -> print_string "good\n"


let get i a =
  let j = Hashtbl.find h i in
  match !j with
    | E -> print_string "thisone\n";raise Empty
    | T(_, v, _) ->
        remove j;
        insert v a;
        v


let () =
  let z = ref E in
  let a = z in
  let () =
    insert 1 a ;
    insert 2 a ;
    insert 3 a ;
    insert 4 a ;
    insert 5 a ;
    insert 6 a ;
    insert 7 a
  in
  display !a |> print_newline ;
  (*
  remove (Hashtbl.find h 4) ;
  *)

  get 6 a |> Printf.printf "%d\n\n";
  get 5 a |> Printf.printf "%d\n\n";
  get 4 a |> Printf.printf "%d\n\n";
  get 7 a |> Printf.printf "%d\n\n";

  check (!a);
  display !a |> print_newline

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
