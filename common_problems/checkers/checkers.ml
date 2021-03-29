type moves = Forward_left | Forward_right | Back_left | Back_right

exception Neverhere

type coord_x = A | B | C | D | E | F | G | H

type coord_y = One | Two | Three | Four | Five | Six | Seven | Eight

type coord = coord_x * coord_y

type color = Red | Black

type status = Pawn | King

type piece = color * status

type ('a, 'b) jumperror =
  [ `Move_invalid of ('a, 'b) result * ('a, 'b) result
  | `Jump_same of ('a, 'b) result * ('a, 'b) result ]

module Board = Map.Make (struct
  type t = coord

  let compare = compare
end)

let is_valid_direction i m move =
  match move with
  | Forward_right | Forward_left -> true
  | Back_left | Back_right -> (
    match Board.find i m with
    | _, King -> true
    | _, Pawn -> false )

let string_of_status = function
  | Pawn -> "pawn"
  | King -> "king"

let string_of_color = function
  | Red -> "red"
  | Black -> "black"

let string_of_direction = function
  | Back_left -> "back/left"
  | Back_right -> "back/right"
  | Forward_left -> "forward/left"
  | Forward_right -> "forward/right"

let forward_x = function
  | A -> Ok B
  | B -> Ok C
  | C -> Ok D
  | D -> Ok E
  | E -> Ok F
  | F -> Ok G
  | G -> Ok H
  | H -> Error H

let back_x = function
  | A -> Error A
  | B -> Ok A
  | C -> Ok B
  | D -> Ok C
  | E -> Ok D
  | F -> Ok E
  | G -> Ok F
  | H -> Ok G

let forward_y = function
  | One -> Ok Two
  | Two -> Ok Three
  | Three -> Ok Four
  | Four -> Ok Five
  | Five -> Ok Six
  | Six -> Ok Seven
  | Seven -> Ok Eight
  | Eight -> Error Eight

let back_y = function
  | One -> Error One
  | Two -> Ok One
  | Three -> Ok Two
  | Four -> Ok Three
  | Five -> Ok Four
  | Six -> Ok Five
  | Seven -> Ok Six
  | Eight -> Ok Seven

let char_of_x = function
  | A -> 'a'
  | B -> 'b'
  | C -> 'c'
  | D -> 'd'
  | E -> 'e'
  | F -> 'f'
  | G -> 'g'
  | H -> 'h'

let int_of_y = function
  | One -> 1
  | Two -> 2
  | Three -> 3
  | Four -> 4
  | Five -> 5
  | Six -> 6
  | Seven -> 7
  | Eight -> 8

let display_coord m coord =
  match (coord, Board.find coord m) with
  | (x, y), (color, status) ->
      Printf.printf "%c, %d: %s %s" (char_of_x x) (int_of_y y)
        (string_of_color color) (string_of_status status)

let move mx my m = function
  | x, y -> (
    match (mx x, my y) with
    | Ok x', Ok y' -> (
      match Board.mem (x', y') m with
      | true -> Error (`Move_invalid (Ok x'), Ok y')
      | false ->
          Board.find (x, y) m
          |> fun i ->
          Board.add (x', y') i m |> fun m -> Ok (Board.remove (x, y) m) )
    | x, y -> Error (`Move_invalid x, y) )

let jump mx my m = function
  | x, y -> (
    match (mx x, my y) with
    | Ok x', Ok y' -> (
      match (mx x', my y') with
      | Ok x'', Ok y'' -> (
        match
          (Board.find (x, y) m, Board.find (x', y') m, Board.mem (x'', y'') m)
        with
        | ((Red, _) as i), (Black, _), false
         |((Black, _) as i), (Red, _), false ->
            Board.remove (x', y') m
            |> Board.remove (x, y)
            |> fun j -> Ok (Board.add (x'', y'') i j)
        | (Red, _), (Red, _), _ | (Black, _), (Black, _), _ ->
            Error (`Jump_same (Ok x), Ok y)
        | _, _, true ->
            Error (`Move_invalid (Ok x), Ok y) (* occupied landing coordinate *)
        )
      | x, y -> Error (`Move_invalid x, y) (* invalid landing coordinate *) )
    | x, y -> Error (`Move_invalid x, y) (* invalid jumping coordinate *) )

let move_fl m i = move forward_x back_y m i

let move_fr m i = move forward_x forward_y m i

let dispatch d t mx my m i =
  let aux =
    match
      match t mx my m i with
      | Ok m -> Ok m
      | Error (`Jump_same i, j) -> (
        match (i, j) with
        | Ok x, Ok y -> Error (x, y, "can't jump your own piece")
        | Error x, Error y | Ok x, Error y | Error x, Ok y ->
            Error (x, y, "unspecified jump error") )
      | Error (`Move_invalid i, j) -> (
        match (i, j) with
        | Error x, Ok y -> Error (x, y, "invalid x coord")
        | Ok x, Error y -> Error (x, y, "invalid y coord")
        | Error x, Error y -> Error (x, y, "invalid x and y coord")
        | Ok x, Ok y -> Error (x, y, "space occupied") )
    with
    | Ok m -> Ok m
    | Error (x, y, msg) ->
        display_coord m (x, y) ;
        Printf.printf ": %s\n" msg ;
        Error m
  in
  match is_valid_direction i m d with
  | true -> aux
  | false ->
      Printf.printf "invalid direction %s" (string_of_direction d) ;
      Error m

let move_bl m i = dispatch Back_right move back_x back_y m i

let move_br m i = dispatch Back_right move back_x forward_y m i

let jump_fl m i = dispatch Forward_left jump forward_x back_y m i

let jump_fr m i = dispatch Forward_right jump forward_x forward_y m i

let initial_coordinates = function
  | Red ->
      [ (B, One)
      ; (D, One)
      ; (F, One)
      ; (H, One)
      ; (A, Two)
      ; (C, Two)
      ; (E, Two)
      ; (G, Two)
      ; (B, Three)
      ; (D, Three)
      ; (F, Three)
      ; (H, Three) ]
  | Black ->
      [ (A, Six)
      ; (C, Six)
      ; (E, Six)
      ; (G, Six)
      ; (B, Seven)
      ; (D, Seven)
      ; (F, Seven)
      ; (H, Seven)
      ; (A, Eight)
      ; (C, Eight)
      ; (E, Eight)
      ; (G, Eight) ]

let () =
  let m = Board.add (C, Two) (Red, Pawn) Board.empty in
  let m = Board.add (B, Three) (Red, Pawn) m in
  let foo = (B, Three) in
  match jump_fl m foo with
    | Ok m -> display_coord m (B, Three)
    | Error _ -> print_string "try again\n"; ()
