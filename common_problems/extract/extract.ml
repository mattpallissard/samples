let rec extract n l =
  match n <= 0 with
  | true -> [[]]
  | false -> (
    match l with
    | [] -> []
    | h :: t ->
        let with_h =
          List.map
            (fun t' ->
              h :: t')
            (extract (n - 1) t)
        in
        let without_h =
          extract n t
        in
        with_h @ without_h )

let () = extract 3 ["a"; "b"; "c"; "d"]
    |> fun _ -> ()
