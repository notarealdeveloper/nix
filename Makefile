PKG := nixos

build:
	nixos-rebuild switch --flake .#turing

update:
	nix-channel --update
	nixos-rebuild switch --upgrade --flake .#turing

pull:
	git pull

push:
	git push
