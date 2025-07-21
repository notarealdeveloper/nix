PKG := nixos

build:
	nixos-rebuild switch

update:
	nix channel --update
	nixos-rebuild switch --upgrade

pull:
	git pull
	git subtree pull --prefix=python nix-python master

push:
	git push
	git subtree push --prefix=python nix-python master
