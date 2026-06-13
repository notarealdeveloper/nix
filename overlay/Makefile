# overlay

build:
	nix build --print-build-logs
	$(MAKE) clean

check:
	nix flake check --print-build-logs

clean:
	@rm -f result
