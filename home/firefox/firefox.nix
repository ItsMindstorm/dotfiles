{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    profiles.yvess = {
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        ublock-origin
        tree-style-tab
      ];
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "svg.context-properties.content.enabled" = true;
      };
      # Copyright goes to Miguel Avila for
      # Userchrome and content
      userChrome = ''
        ${builtins.readFile ./userChrome.css}
      '';

      userContent = ''
        ${builtins.readFile ./userContent.css}
      '';
    };
  };
}
