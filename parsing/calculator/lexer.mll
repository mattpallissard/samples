{
  open Parser
}

rule lexeme = parse
  | [' ' '\t'] { lexeme lexbuf }
  | ['0'-'9' '.'] + {FLOAT (float_of_string (Lexing.lexeme lexbuf))}
  | '+' { PLUS }
  | '-' { MINUS }
  | '/' { DIVIDE }
  | '*' { MULTIPLY }
  | "sin" { SIN }
  | '\n' { NEWLINE }
  | "quit" { QUIT }
  | eof { EOF }
