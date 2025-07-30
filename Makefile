# Makefile for system and user setup on any OS

system:
	sudo nixos-rebuild switch --flake .#default

home:
	nix run .#homeConfigurations.default.activationPackage

jason:
	nix run .#homeConfigurations.jason.activationPackage

ramya:
	nix run .#homeConfigurations.ramya.activationPackage

luna:
	nix run .#homeConfigurations.luna.activationPackage

update:
	nix-channel --update

upgrade: update
	sudo nixos-rebuild switch --upgrade --flake .#default
