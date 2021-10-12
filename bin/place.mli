type t

include Yocaml.Metadata.READABLE with type t := t
include Yocaml.Metadata.INJECTABLE with type t := t

val fetch
  :  (module Yocaml.Metadata.VALIDABLE)
  -> string
  -> (Yocaml.Deps.t * t) Yocaml.t
