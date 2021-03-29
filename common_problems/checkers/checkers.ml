type moves = Forward_left | Forward_right | Back_left | Back_right

type coord_x = A | B | C | D | E | F | G | H

type coord_y = One | Two | Three | Four | Five | Six | Seven | Eight

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

let move mx my = function
  | x, y -> (
    match (mx x, my y) with
    | Ok x, Ok y -> (x, y)
    | _, _ ->
        print_string "invalid move\n" ;
        (x, y) )

let move_fl = move forward_x reverse_y

let move_fr = move forward_x forward_y



type coord = coord_x * coord_y

type color = Red | Black

type status = Pawn | King | Out

type piece = color * status * coord

let is_valid_direction piece move =
  match move with
  | Forward_right | Forward_left -> true
  | Back_left | Back_right -> (
    match piece with
    | _, King -> true
    | _, Pawn | _, Out -> false )

module Board = Map.Make (struct
  type t = coord

  let compare = compare
end)

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
