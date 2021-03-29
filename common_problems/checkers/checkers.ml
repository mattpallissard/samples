type moves = Forward_left | Forward_right | Back_left | Back_right

type coord_x = A | B | C | D | E | F | G | H

type coord_y = One | Two | Three | Four | Five | Six | Seven | Eight

type coord = coord_x * coord_y

type color = Red | Black

type status = Pawn | King

type piece = color * status

type ('a, 'b) jumperror =
  [ `Jump_invalid of ('a, 'b) result * ('a, 'b) result
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

let forward_x = function
  | A -> Ok B
  | B -> Ok C
  | C -> Ok D
  | D -> Ok E
  | E -> Ok F
  | F -> Ok G
  | G -> Ok H
  | H -> Error H

let reverse_x = function
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

let reverse_y = function
  | One -> Error One
  | Two -> Ok One
  | Three -> Ok Two
  | Four -> Ok Three
  | Five -> Ok Four
  | Six -> Ok Five
  | Seven -> Ok Six
  | Eight -> Ok Seven


let move mx my m = function
  | x, y -> (
    match (mx x, my y) with
    | Ok x', Ok y' -> (
      match Board.mem (x', y') m with
      | true ->
          print_string "space occupied, try using jump\n" ;
          m
      | false ->
          Board.find (x, y) m
          |> fun i -> Board.add (x', y') i m |> Board.remove (x, y) )
    | _, _ ->
        print_string "invalid move\n" ;
        m )

let jump mx my m = function
  | x, y -> (
      let aux =
        match (mx x, my y) with
        | Ok x', Ok y' -> (
          match (mx x', my y') with
          | Ok x'', Ok y'' -> (
            match
              ( Board.find (x, y) m
              , Board.find (x', y') m
              , Board.mem (x'', y'') m )
            with

            | ((Red, _) as i), (Black, _), false
             |((Black, _) as i), (Red, _), false ->
                Board.remove (x', y') m
                |> fun j -> Ok (Board.add (x'', y'') i j)

            | (Red, _), (Red, _), _
            | (Black, _), (Black, _), _ ->
                Error (`Jump_same (Ok x), Ok y)


            | _, _, true -> Error (`Jump_invalid (Ok x), Ok y) ) (* occupied landing coordinate *)
          | a, b -> Error (`Jump_invalid a, b) (* invalid landing coordinate *)
          )
        | a, b -> Error (`Jump_invalid a, b)
        (* invalid jumping coordinate *)
      in
      match aux with
      | Ok m -> m
      | Error (`Jump_same _, _) ->
          print_string "can't jump your own piece\n" ;
          m
      | Error (`Jump_invalid i, j) -> (
        match (i, j) with
        | Error _, Ok _ ->
            print_string "invalid x coord\n" ;
            m
        | Ok _, Error _ ->
            print_string "invalid y coord\n" ;
            m
        | Error _, Error _ ->
            print_string "invalid x and y coord\n" ;
            m
        | Ok _, Ok _ ->
            print_string "space occupied\n" ;
            m ) )

let move_fl m i = move forward_x reverse_y m i

let move_fr m i = move forward_x forward_y m i

let move_rl m i = match (is_valid_direction i m Back_left) with
  | true -> move reverse_x forward_y m i
  | false -> print_string "can't move backwards\n"; m

let move_rr m i = match (is_valid_direction i m) Back_right with
  | true -> move reverse_x reverse_y m i
  | false -> print_string "can't move_backwards\n"; m

let jump_fl m i = jump forward_x reverse_y m i

let jump_fr m i = jump forward_x forward_y m i

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
      Printf.printf "%c, %d: %s %s\n" (char_of_x x) (int_of_y y)
        (string_of_color color) (string_of_status status)

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
  let m = Board.add (B, Two) (Black, Pawn) Board.empty in
  let foo = (A, One) in
  move_fr m foo |> fun i -> display_coord i (B, Two)
