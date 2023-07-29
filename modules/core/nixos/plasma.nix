{
  config,
  pkgs,
  lib,
  ...
}: {
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;

    programs.dconf.enable = true;
    displayManager.sddm = {
      enable = true;
      defaultSession = "plasmawayland";
    };
  };
}
