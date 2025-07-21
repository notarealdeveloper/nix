PKG := ld

build:
	nix build -f .

install:
	nix profile add -f .

uninstall:
	nix profile remove $(PKG)

upgrade: uninstall install

clean:
	rm -rfv result
