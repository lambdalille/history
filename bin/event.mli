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

module Complete : sig
  type t = (Place.t, Talk.Complete.t, Company.t) event

  include Yocaml.Metadata.INJECTABLE with type t := t
end

module Raw : sig
  type t = (string, string, string) event

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

module Collection : sig
  type t = Complete.t list

  val make : ?decreasing:bool -> t -> t

  val arrow
    :  (module Yocaml.Metadata.VALIDABLE)
    -> string list
    -> (unit, Complete.t list * string) Yocaml.Build.t Yocaml.t

  include Yocaml.Metadata.INJECTABLE with type t := t
end
