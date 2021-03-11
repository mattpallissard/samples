exception INPUTERROR


type greg = M of int | D of int | Y

type date = int * int * int

type compare = Eq | Lt | Gt


let get_rate = function
    | D i -> 15 * i
    | M i -> 500 * i
    | Y -> 10000

let compare i j =
  if i = j then Eq
  else if i < j then Lt
  else Gt

let fine return due =
  match (return, due) with
  | (d, m, y), (d', m', y') -> (
    let md = m - m' in
    let dd = d - d' in
    match compare y y' with
    | Lt -> 0
    | Eq -> (
      match compare m m' with
      | Lt -> 0
      | Eq -> (
        match compare d d' with
        | Lt | Eq -> 0
        | Gt -> get_rate (D dd) )
      | Gt -> get_rate (M md) )
    | Gt -> get_rate Y)

let parse_input i =
  match Str.split (Str.regexp " ") i with
  | m :: d :: y :: _ -> (int_of_string m, int_of_string d, int_of_string y)
  | _ -> raise INPUTERROR

let do_it =
  let return = parse_input (read_line ()) in
  let due = parse_input (read_line ()) in
  let dollar = fine return due in
  if dollar > 0
  then Printf.printf "%d\n" dollar
  else print_string "0\n";
