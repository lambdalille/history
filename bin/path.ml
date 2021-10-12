open Yocaml

let target = "_site/"
let talks_repository = "data/talks"
let speakers_repository = "data/speakers"
let companies_repository = "data/companies"
let places_repository = "data/places"
let events_repository = "data/events"
let events_target = into target "event"
let talks_target = into target "talks"
let talk_file name = Filename.concat talks_repository name
let event_file name = Filename.concat events_repository name

let speaker_file name =
  Filename.concat speakers_repository $ Filepath.add_extension name "yaml"
;;

let company_file name =
  Filename.concat companies_repository $ Filepath.add_extension name "yaml"
;;

let place_file name =
  Filename.concat places_repository $ Filepath.add_extension name "yaml"
;;

let event_target name =
  Filepath.replace_extension name "html" |> into events_target
;;

let talk_target name =
  Filepath.replace_extension name "html" |> into talks_target
;;

let template file = into "templates" (Filepath.add_extension file "html")
