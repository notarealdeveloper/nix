PKG := nixos

build:
	nixos-rebuild switch

update:
	nix-channel --update
	nixos-rebuild switch --upgrade

pull:
	git pull

push:
	git push
