PKG := ld

build:
	nix build -f .

install:
	nix profile add -f .

uninstall:
	nix profile remove $(PKG)

update: uninstall install

clean:
	rm -rfv result

pull:
	git pull
	git subtree pull --prefix=python nix-python master --squash

push:
	git push
	git subtree push --prefix=python nix-python master
