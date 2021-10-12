open Yocaml.Util

type t =
  { name : string
  ; address : string
  ; city : string option
  ; country : string option
  ; website : string option
  }

let make name address city country website =
  { name; address; city; country; website }
;;

let from_string (module Validable : Yocaml.Metadata.VALIDABLE) = function
  | None -> Yocaml.Error.(to_validate $ Required_metadata [ "place" ])
  | Some str ->
    let open Validable in
    let open Yocaml.Validate in
    let* value = Validable.from_string str in
    object_and
      (fun obj ->
        make
        <$> required_assoc string "name" obj
        <*> required_assoc string "address" obj
        <*> optional_assoc string "city" obj
        <*> optional_assoc string "country" obj
        <*> optional_assoc string "website" obj)
      value
;;

let inject
    (type a)
    (module Describable : Yocaml.Key_value.DESCRIBABLE with type t = a)
    { name; address; city; country; website }
  =
  Describable.
    [ "name", string name
    ; "address", string address
    ; "city", string $ Option.value ~default:"Lille" city
    ; "country", string $ Option.value ~default:"France" country
    ; "website", Option.fold ~none:null ~some:string website
    ; "has_website", boolean $ Option.is_some website
    ]
;;

module F = Util.Fetchable (struct
  type nonrec t = t

  let get_file = Path.place_file
  let from_string = from_string
end)

let fetch = F.fetch
