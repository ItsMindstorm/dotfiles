{pkgs, ...}: {
  home.packages = with pkgs; [
    (python311.withPackages (ps:
      with ps; [
        matplotlib
        requests
      ]))

    (pkgs.texlive.combine {
      inherit
        (pkgs.texlive)
        scheme-full
        ;
    })

    ripgrep
    fd
    fzf
    gcc
    nodejs_20
		dotnet-sdk
		mono
		roslyn
    unzip
    cargo
    sshfs
    ffmpeg
    aria
    neofetch
    sqlite

  ];
}
