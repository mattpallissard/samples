type content = S of string | Int of int | Bytes of bytes | Dir

type errors = Use_mkdir_for_dirs | Exists_dir | Exists_file

module FS = struct
  module Tf = Map.Make (String)

  let empty = Tf.empty

  let sregxp = Str.regexp "/"

  let splitpath = Str.split sregxp

  let stat = Tf.mem

  let set path contents tree = Tf.add path contents tree

  let get path x = Tf.find path x

  let mkdir tree path =
    let rec aux tree = function
      | [] -> Error "exists"
      | h :: t -> (
        match stat h tree with
        | true -> aux tree t
        | false -> create tree t )
    and create tree = function
      | [] -> Ok tree
      | h :: t -> create (set h Dir tree) t
    in
    aux tree path

  let write tree path contents =
    match contents with
    | Dir -> Error Use_mkdir_for_dirs
    | _ ->
        let rec aux root = function
          | [] -> Error Exists_file
          | h :: t -> (
              let path = root ^ "/" ^ h in
              match get path tree with
              | true -> aux path t
              | false -> (
                match t with
                | [] -> Ok (set root contents tree)
                | _ -> aux path t ) )
        in
        aux "/" (splitpath path)
end

let display i j = Printf.printf i j

exception Can't_display_type

let () =
  match FS.set "foo" (S "stringfile") FS.empty |> FS.get "foo" with
  | S i -> display "%s" i
  | Int i -> display "%d" i
  | Dir | Bytes _ -> raise Can't_display_type
