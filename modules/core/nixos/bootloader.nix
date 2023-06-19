{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;
}