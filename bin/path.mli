val target : Yocaml.Filepath.t
val history_target : Yocaml.Filepath.t
val css_repository : Yocaml.Filepath.t
val talks_repository : Yocaml.Filepath.t
val speakers_repository : Yocaml.Filepath.t
val companies_repository : Yocaml.Filepath.t
val places_repository : Yocaml.Filepath.t
val events_repository : Yocaml.Filepath.t
val talks_target : Yocaml.Filepath.t
val events_target : Yocaml.Filepath.t
val talk_file : string -> Yocaml.Filepath.t
val event_file : string -> Yocaml.Filepath.t
val company_file : string -> Yocaml.Filepath.t
val place_file : string -> Yocaml.Filepath.t
val speaker_file : string -> Yocaml.Filepath.t
val talk_target : string -> Yocaml.Filepath.t
val event_target : string -> Yocaml.Filepath.t
val template : ?extension:string -> string -> Yocaml.Filepath.t
val css_target : Yocaml.Filepath.t
