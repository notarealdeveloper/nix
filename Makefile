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

ramya mei luna:
	sudo -iu $@ -- home-manager switch -b backup --flake github:notarealdeveloper/nixos#$@

.PHONY: default system home $(HOSTS)
