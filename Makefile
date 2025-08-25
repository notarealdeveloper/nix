# Makefile for the WNIX Operating System

HOST := $(shell hostname -s)
HOSTS := turing kleene gates localhost
USERS := jason luna

# fail fast if we're on an unknown machine
ifeq ($(filter $(HOST),$(HOSTS)),)
$(error Host "$(HOST)" not recognised; choose one of $(HOSTS))
endif

default: 	$(HOST)
turing: 	system
kleene: 	system
gates: 		system

system:
	sudo nixos-rebuild --print-build-logs switch --flake .#$(HOST)
	@#cachix watch-exec notarealdeveloper -- sudo nixos-rebuild --print-build-logs switch --flake .#$(HOST)

localhost:
	@if [ "$(USER)" != "nix-on-droid" ]; then echo "This doesn't look like a phone"; exit 1; fi
	nix-on-droid switch --flake .#$(HOST)

home:
	home-manager switch -b backup --flake .#$(HOST)

arch:
	sudo pacman -S nix
	nix profile add home-manager
	home-manager switch -b backup --refresh --flake "github:notarealdeveloper/nix#self"

luna:
	sudo -iu $@ -- home-manager switch -b backup --refresh --flake "github:notarealdeveloper/nix#luna"

.PHONY: default system home $(HOSTS)
