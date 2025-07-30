PKG := nixos

nixos:
	sudo nixos-rebuild switch --flake .#default

home:
	nix run .#homeConfigurations.default.activationPackage

update:
	nix-channel --update
	sudo nixos-rebuild switch --upgrade --flake .#default

pull:
	git pull

push:
	git push
