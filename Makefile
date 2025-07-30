# Makefile for system and user setup on any OS

root:
	sudo nixos-rebuild switch --flake .#default

home:
	nix run .#homeConfigurations.default.activationPackage

update:
	nix-channel --update
	sudo nixos-rebuild switch --upgrade --flake .#default
