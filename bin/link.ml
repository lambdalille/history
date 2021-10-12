type t =
  { name : string
  ; href : string
  }

let make name href = { name; href }

let from
    (type a)
    (module Validable : Yocaml.Metadata.VALIDABLE with type t = a)
  =
  Validable.object_and (fun obj ->
      let open Validable in
      let open Yocaml.Validate in
      make
      <$> required_assoc string "name" obj
      <*> required_assoc string "href" obj)
;;

let inject
    (type a)
    (module Describable : Yocaml.Key_value.DESCRIBABLE with type t = a)
    { name; href }
  =
  Describable.(object_ [ "name", string name; "href", string href ])
;;
