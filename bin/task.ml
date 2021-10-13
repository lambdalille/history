open Yocaml

let binary = Build.watch Sys.argv.(0)

let css =
  let open Build in
  process_files
    [ Path.css_repository ]
    (with_extension "css")
    (copy_file ~into:Path.css_target)
;;

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

let history_md =
  let open Build in
  let repo = Path.events_repository in
  let* events = read_child_files repo (with_extension "yaml") in
  let events_name = List.map Filepath.basename events in
  let* arrow = Event.Collection.arrow (module Yocaml_yaml) events_name in
  create_file
    Path.history_target
    (binary
    >>> arrow
    >>> Yocaml_jingoo.apply_as_template
          (module Event.Collection)
          (Path.template ~extension:"md" "history")
    >>^ Stdlib.snd)
;;
