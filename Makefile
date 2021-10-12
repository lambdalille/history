.PHONY: build clean fmt

build:
	dune build

clean:
	dune clean

fmt:
	dune build @fmt --auto-promote
