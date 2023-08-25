{ config
, pkgs
, lib
, ...
}: {
  imports = [
    ./nixos/bootloader.nix
    ./nixos/networking.nix
    ./nixos/nvidia.nix
    ./nixos/pkgs.nix
    ./nixos/security.nix
    ./nixos/services.nix
    ./nixos/settings.nix
    ./nixos/sound.nix
    ./nixos/time.nix

    # Desktops
    # ./nixos/plasma.nix
  ];
}