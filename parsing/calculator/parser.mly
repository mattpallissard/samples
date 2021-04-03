%token <float> FLOAT
%token PLUS MINUS DIVIDE MULTIPLY
%token SIN
%token EOF
%token QUIT
%token NEWLINE

%left PLUS MINUS
%left MULTIPLY DIVIDE
%left SIN

%start main
%type <float> main

%%

main:
  | NEWLINE { 0. }
  | expression = expr NEWLINE { expression }
  | expression = expr EOF { expression }
;

expr:
  | i = FLOAT { i }
  | i = expr PLUS j = expr { i +. j }
  | i = expr MINUS j = expr { i -. j }
  | i = expr MULTIPLY j = expr { i *. j }
  | i = expr DIVIDE j = expr { i /. j }
  | SIN i = expr { sin i }
  | QUIT { exit 0 }
;

%%
