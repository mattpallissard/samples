open Big_int
let i = big_int_of_int 1
let rec fact n = match int_of_big_int n with
  | 1 -> Printf.printf "here\n:"; i
  | _ -> Printf.printf "%s\n" (string_of_big_int n); mult_big_int n (fact (sub_big_int n i))

let () =
  Printf.printf "%s" (string_of_big_int (fact (big_int_of_int (read_int ()))))
