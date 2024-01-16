{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nur.overlay
    inputs.firefox-darwin.overlay
    inputs.nix-minecraft.overlay

    (final: prev: {
      yvess =
        (prev.yvess or {})
        // (import ../packages/default.nix {inherit (prev) pkgs;});

      nwg-displays = prev.nwg-displays.override {hyprlandSupport = true;};

      vimPlugins =
        prev.vimPlugins
        // {
          vim-snippets = prev.vimUtils.buildVimPlugin {
            name = "vim-snippets";
            src = inputs.vim-snippets;
          };

          ouroboros = prev.vimUtils.buildVimPlugin {
            name = "ouroboros";
            src = inputs.ouroboros;
          };
        };

      iina = prev.iina.overrideAttrs (o: rec {
        installPhase = ''
          ${o.installPhase}
          mkdir -p $out/bin
          ln -s "$out/Applications/IINA.app/Contents/MacOS/iina-cli" "$out/bin/iina"
        '';
      });

      sddm = prev.sddm.overrideAttrs (o: {
        buildInputs =
          o.buildInputs
          ++ [final.qt5.qtquickcontrols2 final.qt5.qtgraphicaleffects];
      });

      libsForQt5 =
        prev.libsForQt5
        // {
          sddm = prev.libsForQt5.sddm.overrideAttrs (o: {
            buildInputs = o.buildInputs ++ [final.qt5.qtgraphicaleffects];
          });
        };

      ani-cli-rofi = prev.ani-cli.overrideAttrs (o: rec {
        desktop = pkgs.makeDesktopItem {
          name = "ani-cli";
          desktopName = "Anime cli";
          comment = "A cli program to watch anime";
          genericName = "Anime player";
          categories = ["Video"];
          exec = "ani-cli --rofi";
        };

        installPhase = ''
          mkdir -p $out/share/applications
          cp ${desktop}/share/applications/* $out/share/applications
          ${o.installPhase}
        '';
      });
    })
  ];
}
