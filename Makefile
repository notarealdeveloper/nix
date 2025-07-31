# Makefile for system and user setup on any OS

HOST := $(shell hostname -s)
HOSTS := turing kleene gates

# fail fast if we’re on an unknown machine
ifeq ($(filter $(HOST),$(HOSTS)),)
$(error Host "$(HOST)" not recognised; choose one of $(HOSTS))
endif

system:
	system-$(HOST)

home:
	home-$(HOST)

$(HOSTS): %: system-% home-%

system-%:
	sudo nixos-rebuild switch --flake .#$*

home-%:
	home-manager switch --flake .#$*

home-ramya:
	sudo -iu ramya -- home-manager switch --flake .#ramya -b backup

home-luna:
	sudo -iu luna  -- home-manager switch --flake .#luna  -b backup

.PHONY: default system home $(HOSTS)
