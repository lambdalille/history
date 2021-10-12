val tokenize : string -> string
val md5 : string -> string

module Fetchable (F : sig
  type t

  val get_file : string -> Yocaml.Filepath.t

  val from_string
    :  (module Yocaml.Metadata.VALIDABLE)
    -> string option
    -> t Yocaml.Validate.t
end) : sig
  val fetch_list
    :  (module Yocaml.Metadata.VALIDABLE)
    -> string list
    -> (Yocaml.Deps.t * F.t list) Yocaml.t

  val fetch
    :  (module Yocaml.Metadata.VALIDABLE)
    -> string
    -> (Yocaml.Deps.t * F.t) Yocaml.t
end
