# Makefile for system and user setup on any OS

HOST := $(shell hostname -s)
HOSTS := turing kleene gates

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
	sudo -iu $* -- home-manager switch --flake .#$* -b backup

.PHONY: default system home $(HOSTS)
