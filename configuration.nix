{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./apple-silicon-support
  ];

  nix.package = pkgs.nixVersions.git;
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  nix.settings.substituters = [
    "https://aseipp-nix-cache.freetls.fastly.net"
    "https://cache.garnix.io"
  ];
  nix.settings.trusted-public-keys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];

  nixpkgs.buildPlatform = "aarch64-linux";
  nixpkgs.hostPlatform.config = "aarch64-unknown-linux-gnu";
  # FIXME: causes nix to OOM during eval???
  # See https://github.com/NixOS/nix/issues/12153
  #nixpkgs.hostPlatform.useLLVM = true;
  #nixpkgs.hostPlatform.linker = "lld";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "nixos";
  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  services.xserver.enable = false;

  services.printing.enable = true;

  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  fonts.packages = [
    pkgs.nerd-fonts.comic-shanns-mono
    pkgs.noto-fonts-color-emoji
  ];

  environment.variables.EDITOR = "hx";

  programs.hyprland = {
    enable = true;
    xwayland.enable = false;
  };

  users.users.theo = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kvm"
      "video"
      "audio"
      "seat"
      "adbusers"
    ];
    packages = with pkgs; [
      vulkan-tools
      rio
      wl-clipboard
      bemenu
      prismlauncher
      mpv
      hyprshade
      slurp
      grim
    ];
    shell = pkgs.nushell;
  };

  security.wrappers = {
    ffmpeg = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.ffmpeg}/bin/ffmpeg";
    };
  };

  hardware.graphics.enable = true;
  hardware.asahi = {
    useExperimentalGPUDriver = true;
    peripheralFirmwareDirectory = ./firmware;
  };

  programs.firefox.enable = true;

  # TODO: remove, use wireguard
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    rizinPlugins.rz-ghidra
    rizin
    neovim
    stow
    gitMinimal
    curlHTTP3
    jujutsu
    dhcpcd
    wpa_supplicant
    iw
    libarchive
    nil
    nixfmt-rfc-style
    stylua
    nix-output-monitor
    fastfetch
    uutils-coreutils-noprefix
    ripgrep
    fd
    sd
    bottom
    ffmpeg
    zellij
    hyperfine
    starship
    zoxide
    bat
    skim
    mdbook
    qemu
    deno
    gnumake
    jdk23
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
