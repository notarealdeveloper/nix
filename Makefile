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
	sudo nixos-rebuild switch --flake .#$*

home-%:
	home-manager switch -b backup --flake .#$*

arch:
	sudo pacman -S nix
	nix profile add home-manager
	home-manager switch -b backup --refresh --flake github:notarealdeveloper/nixos#jason

ramya mei luna:
	sudo -iu $@ -- home-manager switch -b backup --refresh --flake github:notarealdeveloper/nixos#$@

.PHONY: default system home $(HOSTS)
