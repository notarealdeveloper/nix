PKG := cowsay

# Flakes are pretty lame
FLAKE := $(shell sed "s@$$(git rev-parse --show-toplevel)/@@g" <<< "$$(readlink -f "$$PWD")")

build:
	nix build

install:
	nix profile add

uninstall:
	nix profile remove $(FLAKE)

update:
	nix flake update
	nix profile upgrade $(FLAKE)

clean:
	rm -rvf result flake.lock
