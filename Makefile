# Makefile for the WNIX Operating System
.DEFAULT_GOAL := default

HOST ?= $(shell hostname -s)
LAPTOPS := turing kleene
# path: includes a freshly copied hardware file even before git add.
FLAKE ?= path:$(CURDIR)
ACTION ?= switch
UUID_TODO := TODO-TELL-AN-AGENT-TO-SWITCH-THE-UUIDS-TO-THE-LABELS-IN-dev-disk-by-label

# Laptop configurations include Home Manager; a second home switch is unnecessary.
default: $(HOST)

$(LAPTOPS) $(addsuffix -stage-one,$(LAPTOPS)):
	sudo nixos-rebuild --extra-experimental-features 'nix-command flakes' --print-build-logs $(ACTION) --flake '$(FLAKE)#$@'
	@if [ '$@' = turing ] || [ '$@' = turing-stage-one ]; then ./$(UUID_TODO) --remind; fi

# Both spellings select exactly the same small system and home configuration.
$(addsuffix -simple,$(LAPTOPS)): %-simple: %-stage-one

system: $(HOST)

gates:
	sudo nixos-rebuild --extra-experimental-features 'nix-command flakes' --print-build-logs $(ACTION) --flake '$(FLAKE)#gates'
	$(MAKE) home HOST=gates

x:
	cat flake.nix configuration.nix home/jason.nix | xc

localhost:
	@if [ "$(USER)" != "nix-on-droid" ]; then echo "This doesn't look like a phone"; exit 1; fi
	nix-on-droid switch --flake '$(FLAKE)#localhost'

# Standalone Home Manager remains useful for home-only changes after authentication.
home:
	home-manager switch -b backup --flake '$(FLAKE)#$(HOST)'

# Evaluate full bootable systems and activation scripts without installing anything.
check:
	@set -e; for host in $(LAPTOPS) $(addsuffix -stage-one,$(LAPTOPS)); do \
		nix --extra-experimental-features 'nix-command flakes' eval --raw \
			'$(FLAKE)#nixosConfigurations.'$$host'.config.system.build.toplevel.drvPath'; \
		printf '\n'; \
	done

arch:
	sudo pacman -S nix
	nix profile add home-manager
	home-manager switch -b backup --refresh --flake "github:notarealdeveloper/nix#self"

luna:
	sudo -iu $@ -- home-manager switch -b backup --refresh --flake "github:notarealdeveloper/nix#luna"

.PHONY: default system home check x arch luna gates localhost $(LAPTOPS) $(addsuffix -stage-one,$(LAPTOPS)) $(addsuffix -simple,$(LAPTOPS))
