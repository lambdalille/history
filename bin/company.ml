open Yocaml.Util

type t =
  { name : string
  ; website : string option
  ; logo : string
  }

let make name website logo = { name; website; logo }

let from_string (module Validable : Yocaml.Metadata.VALIDABLE) = function
  | None -> Yocaml.Error.(to_validate $ Required_metadata [ "company" ])
  | Some str ->
    let open Validable in
    let open Yocaml.Validate in
    let* value = Validable.from_string str in
    object_and
      (fun obj ->
        make
        <$> required_assoc string "name" obj
        <*> optional_assoc string "website" obj
        <*> required_assoc string "logo" obj)
      value
;;

let inject
    (type a)
    (module Describable : Yocaml.Key_value.DESCRIBABLE with type t = a)
    { name; website; logo }
  =
  Describable.
    [ "name", string name
    ; "website", Option.fold ~none:null ~some:string website
    ; "has_website", boolean $ Option.is_some website
    ; "logo", string logo
    ]
;;

include Util.Fetchable (struct
  type nonrec t = t

  let get_file = Path.company_file
  let from_string = from_string
end)
