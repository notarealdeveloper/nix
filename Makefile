# Makefile for system and user setup on any OS

system:
	sudo nixos-rebuild switch --flake .#default

home:
	home-manager switch --flake .#default

jason:
	sudo -iu jason -- nix run --refresh github:/notarealdeveloper/nixos#homeConfigurations.jason.activationPackage

ramya:
	sudo -iu ramya -- nix run --refresh github:/notarealdeveloper/nixos#homeConfigurations.ramya.activationPackage

luna:
	sudo -iu luna -- nix run --refresh github:/notarealdeveloper/nixos#homeConfigurations.luna.activationPackage

update:
	nix-channel --update

upgrade: update
	sudo nixos-rebuild switch --upgrade --flake .#default

.PHONY: home
