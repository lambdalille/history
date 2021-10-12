type 'a talk = private
  { title : string
  ; speakers : 'a list
  ; abstract : string
  ; tags : string list
  ; lang : [ `French | `English ]
  ; video_link : string option
  ; support_link : string option
  ; other_links : Link.t list
  }

module Complete : sig
  type t = Speaker.t talk

  include Yocaml.Metadata.INJECTABLE with type t := t
end

module Raw : sig
  type t = string talk

  include Yocaml.Metadata.READABLE with type t := t
end

val fetch
  :  (module Yocaml.Metadata.VALIDABLE)
  -> string
  -> (Yocaml.Deps.t * Complete.t) Yocaml.t

val fetch_list
  :  (module Yocaml.Metadata.VALIDABLE)
  -> string list
  -> (Yocaml.Deps.t * Complete.t list) Yocaml.t

val arrow
  :  (module Yocaml.Metadata.VALIDABLE)
  -> string
  -> (unit, Complete.t * string) Yocaml.Build.t Yocaml.t
