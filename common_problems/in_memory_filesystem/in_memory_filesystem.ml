type content = S of string | Int of int | Bytes of bytes | Dir
type key = string

type errors = Exists_file

module type FS = sig
  type 'a m

  val get : key -> content m -> content

  val empty : 'a m

  val mkdir : content m -> key -> (content m, errors) result

  val write : content m -> key -> content -> (content m, errors) result
end

module Fs : FS = struct
  module Tf = Map.Make (String)

  type 'a m = 'a Tf.t

  let empty = Tf.empty

  let sregxp = Str.regexp "/"

  let splitpath = Str.split sregxp

  let stat = Tf.mem

  let set path contents tree = Tf.add path contents tree

  let get path = Tf.find path

  let write tree path contents =
    match stat path tree with
    | true -> Error Exists_file
    | false ->
        let rec aux tree root = function
          | [] -> Ok (set path contents tree)
          | h :: t -> (
              let path = root ^ "/" ^ h in
              match stat path tree with
              | true -> aux tree path t
              | false -> aux (set path Dir tree) path t )
        in
        aux tree "" (splitpath path)

  let mkdir tree path = write tree path Dir
end

let display i j k = Printf.printf i j k

exception Can't_display_type

let () =
  let rec aux tree = function
    | [] -> ()
    | h :: t -> (
      try
        match Fs.get h tree with
        | S i -> display "%s: %s\n" h i ; aux tree t
        | Int i -> display "%s: %d\n" h i ; aux tree t
        | Dir -> display "%s: %s\n" h "dir" ; aux tree t
        | _ -> raise Can't_display_type
      with Not_found -> Printf.printf "notfound: %s\n" h )
  in
  let b =
    match Fs.mkdir Fs.empty "/foo/bar/baz" with
    | Ok i -> i
    | Error i -> (
      match i with
      | Exists_file ->
          Printf.printf "%s\n" "exists file" ;
          raise Can't_display_type )
  in
  aux b ["/foo"; "/foo/bar"; "/foo/bar/baz"] ;
  Printf.printf "%s" "fuck\n" ;
  let a =
    match Fs.write b "/foo/bar/baz" (Int 1337) with
    | Ok i -> i
    | Error i -> (
      match i with
      | Exists_file ->
          Printf.printf "exists :%s\n" "/foo/bar/baz" ;
          raise Can't_display_type )
  in
  aux a ["/foo"; "/foo/bar"; "/foo/bar/baz"]

(*
  match Fs.set "foo" (S "stringfile") Fs.empty |> Fs.get "foo" with
  | S i -> display "%s" i
  | Int i -> display "%d" i
  | Dir | Bytes _ -> raise Can't_display_type
  *)
