exception INPUTERROR

let squares =
  let q = read_line () in
  let rec run = function
    | 0 -> ()
    | _ as i -> (
        let s = read_line () in
        match Str.split (Str.regexp " ") s with
        | h :: t :: _ ->
            let first =
              int_of_float ((ceil (sqrt (float_of_string h))))
            in
            let sq = int_of_float (floor (sqrt (float_of_string t))) in
            if sq < first then print_string "0\n"
            else Printf.printf "%d\n" (sq - first + 1) ;
            run (i - 1)
        | _ -> raise INPUTERROR )
  in
  run (int_of_string q)

let () = squares
