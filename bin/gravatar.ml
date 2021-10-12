open Util

let from_email email_opt =
  let open Preface.Fun in
  let hash =
    Option.fold
      ~none:"00000000000000000000000000000000"
      ~some:(md5 % tokenize)
      email_opt
  in
  "https://www.gravatar.com/avatar/" ^ hash
;;
