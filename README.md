# history

**History** is a static site (and Markdown document) generator that aims to
simplify the various reports (and website) related to LambdaLille.

## Local installation

After forking `lambdalille/history` and cĺoning it to your machine:

```shellsession
cd history
opam install . --deps-only --with-doc --with-test
opam install yocaml
opam install yocaml_markdown yocaml_unix yocaml_jingoo yocaml_yaml
```

There is a bit of ceremony involved in installing `Yocaml' because its
[maintainer](https;//github.com/xhtmlboi) doesn't seem to have had the faith to
package it properly on OPAM. What a shame!

## Compilation

If you have `Make` installed, you can simply run `make` (or `make build`).
Alternatively, you can use `dune` directly by running `dune build`.

## Usage

Each time the project is compiled, an executable `bin/history.exe` is created
and you can run it to generate `history.md`: `./bin/history.exe`. The command
will generate the file `_markdown/history.md` which is roughly a report of the
various events already encoded (that have taken place, at LambdaLille).

## How to contribute

At the moment, improving the generator is not a priority, so the best way is to
build on what has already been encoded to add missing data.
