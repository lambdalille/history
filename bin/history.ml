open Yocaml
module E = Event

let binary = Build.watch Sys.argv.(0)

let talks =
  let open Build in
  process_files [ Path.talks_repository ] (with_extension "yaml") (fun file ->
      let basename = Filepath.basename file in
      let* talk_arrow = Talk.arrow (module Yocaml_yaml) basename in
      create_file
        (Path.talk_target basename)
        (binary
        >>> talk_arrow
        >>> Yocaml_jingoo.apply_as_template
              (module Talk.Complete)
              (Path.template "talk")
        >>> Yocaml_jingoo.apply_as_template
              (module Talk.Complete)
              (Path.template "global")
        >>^ Stdlib.snd))
;;

let events =
  let open Build in
  process_files
    [ Path.events_repository ]
    (with_extension "yaml")
    (fun file ->
      let basename = Filepath.basename file in
      let* event_arrow = Event.arrow (module Yocaml_yaml) basename in
      create_file
        (Path.event_target basename)
        (binary
        >>> event_arrow
        >>> Yocaml_jingoo.apply_as_template
              (module Event.Complete)
              (Path.template "event")
        >>> Yocaml_jingoo.apply_as_template
              (module Event.Complete)
              (Path.template "global")
        >>^ Stdlib.snd))
;;

let () = Yocaml_unix.execute (talks >> events)
