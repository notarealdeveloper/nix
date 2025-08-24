# Makefile for the WNIX Operating System

HOST := $(shell hostname -s)
HOSTS := turing kleene gates
USERS := jason ramya mei luna

# fail fast if we’re on an unknown machine
ifeq ($(filter $(HOST),$(HOSTS)),)
$(error Host "$(HOST)" not recognised; choose one of $(HOSTS))
endif

default: $(HOST)

system home:
	@$(MAKE) $@-$(HOST)

$(HOSTS): %: system-% home-%

system-%:
	sudo nixos-rebuild --print-build-logs switch --flake .#$*
	#cachix watch-exec notarealdeveloper -- sudo nixos-rebuild --print-build-logs switch --flake .#$*

home-%:
	home-manager switch -b backup --flake .#$*

arch:
	sudo pacman -S nix
	nix profile add home-manager
	home-manager switch -b backup --refresh --flake "github:notarealdeveloper/nixos#jason"

gentoo:
	@echo TODO: Determinate Systems installer.

freebsd:
	@echo TODO: pkg install nix

ramya mei luna:
	sudo -iu $@ -- home-manager switch -b backup --refresh --flake github:notarealdeveloper/nixos#$@

.PHONY: default system home $(HOSTS)
