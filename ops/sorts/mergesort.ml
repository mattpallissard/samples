module type I = sig
  type t

  val lt : t -> t -> bool
end

module type MS = sig
  type t

  val sort : t list -> t list
end

module Ms (Elem : I) : MS with type t = Elem.t = struct
  type t = Elem.t

  let ( < ) = Elem.lt

  let rec merge i j =
    match (i, j) with
    | [], _ -> j
    | _, [] -> i
    | h :: t, h' :: t' -> if h < h' then h :: merge t j else h' :: merge i t'

  let rec split i j k =
    match i with
    | [] -> (j, k)
    | h :: t -> split t k (h :: j)

  let sort i =
    let rec aux i c =
      match i with
      | [] -> c []
      | [i] -> c [i]
      | i ->
          split i [] []
          |> fun (i, j) -> aux i (fun k -> aux j (fun l -> c (merge k l)))
    in
    aux i (fun i -> i)

  (* continuation *)
end

module Foo = struct
  type t = int

  let lt i j = i < j

  let rec display = function
    | [] -> ()
    | h :: t -> Printf.printf " %d\n" h ; display t
end

module Bar = Ms (Foo)

let () = Bar.sort [2; 5; 4; 26; 7; 9] |> Foo.display
