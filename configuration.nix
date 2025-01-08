{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./apple-silicon-support
  ];

  nixpkgs.overlays = [
    (self: super: {
      # coreutils = super.callPackage ./packages/coreutils.nix {};
      # elfutils = super.elfutils.overrideAttrs (previous: {
      # patches = [
      # ./packages/elfutils/cxx-header-collision.patch
      # ];
      # });
      # nix = super.nix.overrideAttrs (previous: {
      # doCheck = false;
      # doInstallCheck = false;
      # });
    })
  ];

  nixpkgs.buildPlatform = "aarch64-linux";
  nixpkgs.hostPlatform.config = "aarch64-unknown-linux-gnu";
  # FIXME: causes nix to OOM during eval???
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

  # services.libinput.enable = true;

  users.users.theo = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kvm"
      "video"
      "audio"
      "seat"
    ];
    packages = with pkgs; [
      vulkan-tools
      # TODO: Rio has vulkan issues https://github.com/gfx-rs/wgpu/issues/6320
      # rio
      foot
      bemenu
    ];
    shell = pkgs.nushell;
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
    helix
    gitMinimal
    curlHTTP3
    jujutsu
    dhcpcd
    wpa_supplicant
    iw
    libarchive
    nil
    nixfmt-rfc-style
    nix-output-monitor
    fastfetch
    uutils-coreutils-noprefix
    ripgrep
    fd
    sd
    bottom
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
