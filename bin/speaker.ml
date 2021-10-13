open Yocaml.Util

type t =
  { firstname : string
  ; lastname : string
  ; bio : string option
  ; pronouns : string option
  ; email : string option
  ; main_link : string option
  ; links : Link.t list
  }

let make firstname lastname bio pronouns email main_link links =
  { firstname; lastname; bio; pronouns; email; main_link; links }
;;

let from_string (module Validable : Yocaml.Metadata.VALIDABLE) = function
  | None -> Yocaml.Error.(to_validate $ Required_metadata [ "speaker" ])
  | Some str ->
    let open Validable in
    let open Yocaml.Validate in
    let* value = Validable.from_string str in
    object_and
      (fun obj ->
        make
        <$> required_assoc string "firstname" obj
        <*> required_assoc string "lastname" obj
        <*> optional_assoc string "bio" obj
        <*> optional_assoc string "pronouns" obj
        <*> optional_assoc string "email" obj
        <*> optional_assoc string "main_link" obj
        <*> optional_assoc_or
              ~default:[]
              (list_of $ Link.from (module Validable))
              "links"
              obj)
      value
;;

let sanitize_name = Preface.Fun.(String.capitalize_ascii % String.trim)

let fullname firstname lastname =
  sanitize_name firstname ^ " " ^ sanitize_name lastname
;;

let smallname firstname lastname =
  ((sanitize_name firstname).[0] |> String.make 1)
  ^ ". "
  ^ sanitize_name lastname
;;

let inject
    (type a)
    (module Describable : Yocaml.Key_value.DESCRIBABLE with type t = a)
    { firstname; lastname; bio; pronouns; email; main_link; links }
  =
  Describable.
    [ "firstname", string $ sanitize_name firstname
    ; "lastname", string $ sanitize_name lastname
    ; "fullname", string $ fullname firstname lastname
    ; "smallname", string $ smallname firstname lastname
    ; "bio", Option.fold ~none:null ~some:string bio
    ; "avatar", string $ Gravatar.from_email email
    ; "pronouns", Option.fold ~none:null ~some:string pronouns
    ; "email", Option.fold ~none:null ~some:string email
    ; "main_link", Option.fold ~none:null ~some:string main_link
    ; "links", list $ List.map (Link.inject (module Describable)) links
    ]
;;

module F = Util.Fetchable (struct
  type nonrec t = t

  let get_file = Path.speaker_file
  let from_string = from_string
end)

let fetch = F.fetch_list
