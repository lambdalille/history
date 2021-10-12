type t

include Yocaml.Metadata.READABLE with type t := t
include Yocaml.Metadata.INJECTABLE with type t := t

val fetch_list
  :  (module Yocaml.Metadata.VALIDABLE)
  -> string list
  -> (Yocaml.Deps.t * t list) Yocaml.t
