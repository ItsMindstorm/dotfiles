{pkgs-darwin, ...}: let
  callPackage = pkgs-darwin.callPackage;
in {
	skim = callPackage ./skim/skim.nix {};
}
