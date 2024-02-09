{pkgs, ...}: {
  home.packages = with pkgs; [
    (python311.withPackages (ps:
      with ps; [
        yt-dlp
        spotdl
        pygments
        tkinter
      ]))

    texlive.combined.scheme-full
    nodejs_21
    rustup
    yarn
    openjdk19

    unzip
    sshfs
    ffmpeg
    neofetch
    gcc
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
