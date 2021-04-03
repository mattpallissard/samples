let rec do_it () =
  print_string " " ;
  flush stdout ;
  Lexing.from_channel stdin
  |> Parser.main Lexer.lexeme
  |> string_of_float
  |> fun i -> print_endline i
  |> do_it

let () =
  print_endline "'quit' to exit'" ;
  do_it ()
