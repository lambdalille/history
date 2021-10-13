open Yocaml.Util
open Util

type 'a talk =
  { title : string
  ; speakers : 'a list
  ; abstract : string option
  ; tags : string list
  ; lang : [ `French | `English ]
  ; video_link : string option
  ; support_link : string option
  ; other_links : Link.t list
  }

module Complete = struct
  type t = Speaker.t talk

  let lang_to_str = function
    | `English -> "en"
    | `French -> "fr"
  ;;

  let inject
      (type a)
      (module Describable : Yocaml.Key_value.DESCRIBABLE with type t = a)
      { title
      ; speakers
      ; abstract
      ; tags
      ; lang
      ; video_link
      ; support_link
      ; other_links
      }
    =
    let open Preface.Fun in
    let speakers =
      List.map
        (Describable.object_ % Speaker.inject (module Describable))
        speakers
    in
    Describable.
      [ "title", string title
      ; "speakers", list speakers
      ; "abstract", Option.fold ~none:null ~some:string abstract
      ; "tags", list (List.map (string % tokenize) tags)
      ; "lang", string $ lang_to_str lang
      ; "video_link", Option.fold ~none:null ~some:string video_link
      ; "support_link", Option.fold ~none:null ~some:string support_link
      ; ( "other_links"
        , list $ List.map (Link.inject (module Describable)) other_links )
      ]
  ;;
end

module Raw = struct
  type t = string talk

  let make
      title
      speakers
      abstract
      tags
      lang
      video_link
      support_link
      other_links
    =
    { title
    ; speakers
    ; abstract
    ; tags
    ; lang
    ; video_link
    ; support_link
    ; other_links
    }
  ;;

  let lang
      (type a)
      (module Validable : Yocaml.Metadata.VALIDABLE with type t = a)
      f
    =
    Validable.string_and
      (fun str ->
        match tokenize str with
        | "fr" | "french" | "f" -> Yocaml.Validate.valid `French
        | "uk" | "en" | "english" | "e" -> Yocaml.Validate.valid `English
        | _ -> Yocaml.Error.(to_validate $ Invalid_field "lang"))
      f
  ;;

  let from_string (module Validable : Yocaml.Metadata.VALIDABLE) = function
    | None -> Yocaml.Error.(to_validate $ Required_metadata [ "talk" ])
    | Some str ->
      let open Validable in
      let open Yocaml.Validate in
      let* value = Validable.from_string str in
      object_and
        (fun obj ->
          make
          <$> required_assoc string "title" obj
          <*> required_assoc (list_of string) "speakers" obj
          <*> optional_assoc string "abstract" obj
          <*> optional_assoc_or ~default:[] (list_of string) "tags" obj
          <*> required_assoc (lang (module Validable)) "lang" obj
          <*> optional_assoc string "video_link" obj
          <*> optional_assoc string "support_link" obj
          <*> optional_assoc_or
                ~default:[]
                (list_of $ Link.from (module Validable))
                "other_links"
                obj)
        value
  ;;
end

module F = Util.Fetchable (struct
  type t = Raw.t

  let get_file = Path.talk_file
  let from_string = Raw.from_string
end)

let get_raw = F.fetch

let fetch (module Validable : Yocaml.Metadata.VALIDABLE) name =
  let open Yocaml in
  let* t_deps, talk = get_raw (module Validable) name in
  let+ s_deps, speakers = Speaker.fetch (module Validable) talk.speakers in
  let deps = Deps.Monoid.(t_deps <|> s_deps) in
  deps, { talk with speakers }
;;

let fetch_list (module Validable : Yocaml.Metadata.VALIDABLE) list =
  let open Yocaml in
  let+ talks_with_deps =
    List.map (fetch (module Validable)) list |> Traverse.sequence
  in
  let deps, talks = List.split talks_with_deps in
  Deps.Monoid.reduce deps, talks
;;

let arrow (module Validable : Yocaml.Metadata.VALIDABLE) name =
  let open Yocaml in
  let+ deps, talk = fetch (module Validable) name in
  Build.make deps (fun () -> return (talk, ""))
;;
