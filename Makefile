# Makefile for system and user setup on any OS

turing: system-turing home-turing

kleene: system-turing home-turing

gates:  system-gates  home-gates

system-turing:
	sudo nixos-rebuild switch --flake .#turing

system-kleene:
	sudo nixos-rebuild switch --flake .#kleene

system-gates:
	sudo nixos-rebuild switch --flake .#gates

home-turing:
	home-manager switch --flake .#jason -b backup

home-kleene:
	home-manager switch --flake .#jason -b backup

home-gates:
	home-manager switch --flake .#headless -b backup

home-jason:
	home-manager switch --flake .#jason -b backup

home-ramya:
	sudo -iu ramya -- home-manager switch --flake .#ramya -b backup

home-luna:
	sudo -iu luna -- home-manager switch --flake .#luna -b backup

.PHONY: home
