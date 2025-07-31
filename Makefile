# Makefile for system and user setup on any OS


system:
	sudo nixos-rebuild switch --flake .#

turing:
	sudo nixos-rebuild switch --flake .#turing

kleene:
	sudo nixos-rebuild switch --flake .#kleene

gates:
	sudo nixos-rebuild switch --flake .#gates

home:
	home-manager switch --flake .#default -b backup

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
