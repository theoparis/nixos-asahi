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
      python3 = super.python313;
      elfutils = super.elfutils.overrideAttrs (previous: {
        patches = [
          ./packages/elfutils/cxx-header-collision.patch
        ];
      });
      nix = super.nix.overrideAttrs (previous: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];

  nixpkgs.buildPlatform = "aarch64-linux";
  nixpkgs.hostPlatform.config = "aarch64-unknown-linux-gnu";
  nixpkgs.hostPlatform.useLLVM = true;
  nixpkgs.hostPlatform.linker = "lld";

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

  services.libinput.enable = true;

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
    ];
    shell = pkgs.nushell;
  };

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    extractPeripheralFirmware = false;
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
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
