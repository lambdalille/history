open Yocaml.Util
open Util

type ('place, 'talk, 'sponsor) event =
  { name : string
  ; date : Yocaml.Date.t
  ; timezone : [ `CET ]
  ; is_online : bool
  ; place : 'place option
  ; sponsors : 'sponsor list
  ; talks : 'talk list
  ; link : Link.t
  }

module Complete = struct
  type t = (Place.t, Talk.Complete.t, Company.t) event

  let tz_to_string = function
    | `CET -> "cet"
  ;;

  let inject
      (type a)
      (module D : Yocaml.Key_value.DESCRIBABLE with type t = a)
      { name; date; timezone; is_online; place; sponsors; talks; link }
    =
    let open Preface.Fun in
    let obj = D.object_ in
    let talks = List.map (obj % Talk.Complete.inject (module D)) talks in
    let place = Option.map (obj % Place.inject (module D)) place in
    let sponsors = List.map (obj % Company.inject (module D)) sponsors in
    D.
      [ "name", string name
      ; "date", obj $ Yocaml.Metadata.Date.inject (module D) date
      ; "timezone", string $ tz_to_string timezone
      ; "is_online", boolean is_online
      ; "place", Option.value ~default:null place
      ; "sponsors", list sponsors
      ; "talks", list talks
      ; "link", Link.inject (module D) link
      ]
  ;;
end

module Raw = struct
  type t = (string, string, string) event

  let make name date timezone is_online place sponsors talks link =
    { name; date; timezone; is_online; place; sponsors; talks; link }
  ;;

  let cet
      (type a)
      (module Validable : Yocaml.Metadata.VALIDABLE with type t = a)
      f
    =
    Validable.string_and
      (fun str ->
        if String.equal $ tokenize str $ "cet"
        then Yocaml.Validate.valid `CET
        else Yocaml.Error.(to_validate $ Invalid_field "timezone"))
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
          <$> required_assoc string "name" obj
          <*> required_assoc
                (Yocaml.Metadata.Date.from (module Validable))
                "date"
                obj
          <*> required_assoc (cet (module Validable)) "timezone" obj
          <*> required_assoc boolean "is_online" obj
          <*> optional_assoc string "place" obj
          <*> optional_assoc_or ~default:[] (list_of string) "sponsors" obj
          <*> required_assoc (list_of string) "talks" obj
          <*> required_assoc (Link.from (module Validable)) "link" obj)
        value
  ;;
end

module F = Util.Fetchable (struct
  type t = Raw.t

  let get_file = Path.event_file
  let from_string = Raw.from_string
end)

let get_raw = F.fetch

let fetch (module Validable : Yocaml.Metadata.VALIDABLE) name =
  let open Yocaml in
  let* e_deps, event = get_raw (module Validable) name in
  let* t_deps, talks = Talk.fetch_list (module Validable) event.talks in
  let* s_deps, sponsors =
    Company.fetch_list (module Validable) event.sponsors
  in
  let+ p_deps, place =
    Option.fold
      ~none:(return (Deps.empty, None))
      ~some:(fun place ->
        Place.fetch (module Validable) place
        >|= Preface.Pair.Bifunctor.map_snd Option.some)
      event.place
  in
  let deps = Deps.Monoid.(e_deps <|> t_deps <|> s_deps <|> p_deps) in
  deps, { event with sponsors; place; talks }
;;

let fetch_list (module Validable : Yocaml.Metadata.VALIDABLE) list =
  let open Yocaml in
  let+ event_with_deps =
    List.map (fetch (module Validable)) list |> Traverse.sequence
  in
  let deps, talks = List.split event_with_deps in
  Deps.Monoid.reduce deps, talks
;;

let arrow (module Validable : Yocaml.Metadata.VALIDABLE) name =
  let open Yocaml in
  let+ deps, event = fetch (module Validable) name in
  Build.make deps (fun () -> return (event, ""))
;;
