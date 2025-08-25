# Makefile for the WNIX Operating System

HOST := $(shell hostname -s)
HOSTS := turing kleene gates localhost
USERS := jason luna

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

localhost: phone

phone:
	@if [ "$(USER)" != "nix-on-droid" ]; then \
		echo "Error: USER must be set to 'nix-on-droid' (got '$(USER)')"; \
		exit 1; \
	fi
	nix-on-droid switch --flake .#default

arch:
	sudo pacman -S nix
	nix profile add home-manager
	home-manager switch -b backup --refresh --flake "github:notarealdeveloper/nix#jason"

gentoo:
	@echo TODO: Determinate Systems installer.

freebsd:
	@echo TODO: pkg install nix

luna:
	sudo -iu $@ -- home-manager switch -b backup --refresh --flake github:notarealdeveloper/nix#$@

.PHONY: default system home $(HOSTS)
