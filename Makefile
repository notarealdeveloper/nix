PKG := nixos

nixos:
	sudo nixos-rebuild switch --flake .#default

update:
	nix-channel --update
	sudo nixos-rebuild switch --upgrade --flake .#default

pull:
	git pull

push:
	git push
