type t

val from
  :  (module Yocaml.Metadata.VALIDABLE with type t = 'a)
  -> 'a
  -> t Yocaml.Validate.t

val inject : (module Yocaml.Key_value.DESCRIBABLE with type t = 'a) -> t -> 'a
