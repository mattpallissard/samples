open String
let modulo x y =
  let result = x mod y in
  if result >= 0 then result
  else result + y

let appendAndDelete =
  let s = read_line () in
  let t = read_line () in
  let k = read_int () in
  let slen = String.length s in
  let tlen = String.length t in
  let rec aux i j l = match i, j with
    | [], [] | _, [] | [], _ -> l
    | h :: t, h' :: t' -> if h = h'
      then aux t t' (l+2)
      else l
  in
  let s' =List.init slen (String.get s) in
  let t' = List.init tlen (String.get t) in
  let k' = (aux s' t' k) in
match (slen + tlen) > k' with
  | true -> print_string "No\n";
  | false -> (match modulo (slen + tlen) 2 > modulo k' 2 with
    | true -> print_string "No\n"
    | false-> print_string "Yes\n")
