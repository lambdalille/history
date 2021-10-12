open Yocaml.Util

let tokenize s =
  let open String in
  lowercase_ascii $ trim s
;;

let md5 s =
  let open Digest in
  to_hex $ string s
;;

module Traverse_try = Preface.List.Monad.Traversable (Yocaml.Try.Monad)

module Fetchable (F : sig
  type t

  val get_file : string -> Yocaml.Filepath.t

  val from_string
    :  (module Yocaml.Metadata.VALIDABLE)
    -> string option
    -> t Yocaml.Validate.t
end) =
struct
  let fetch_list (module Validable : Yocaml.Metadata.VALIDABLE) list =
    let open Yocaml.Effect in
    let open Preface.Fun in
    let paths = List.map F.get_file list in
    let* files = List.map read_file paths |> Traverse.sequence in
    let result =
      List.map
        (fun ctn ->
          let open Yocaml.Try.Monad.Infix in
          ctn
          >>= Yocaml.Validate.to_try
              % F.from_string (module Validable)
              % Option.some)
        files
      |> Traverse_try.sequence
    in
    match result with
    | Error err -> throw err
    | Ok l -> return (Yocaml.Deps.(of_list $ List.map file paths), l)
  ;;

  let fetch (module Validable : Yocaml.Metadata.VALIDABLE) str =
    let open Yocaml.Effect in
    let open Preface.Fun in
    let path = F.get_file str in
    let* file = read_file path in
    let result =
      let open Yocaml.Try.Monad in
      file
      >>= Yocaml.Validate.to_try
          % F.from_string (module Validable)
          % Option.some
    in
    match result with
    | Error err -> throw err
    | Ok l -> return (Yocaml.Deps.(singleton $ file path), l)
  ;;
end
