{
  lib,
  fetchgit,
  buildUBoot,
  m1n1,
}:

(buildUBoot rec {
  src = fetchgit {
    url = "https://source.denx.de/u-boot/u-boot.git";
    rev = "6d41f0a39d6423c8e57e92ebbe9f8c0333a63f72";
    hash = "sha256-gtXt+BglBdEKW7j3U2x2QeKGeDH1FdmAMPXk+ntkROo=";
  };
  version = "mainline";

  defconfig = "apple_m1_defconfig";
  extraMeta.platforms = [ "aarch64-linux" ];
  filesToInstall = [
    "u-boot-nodtb.bin.gz"
    "m1n1-u-boot.bin"
  ];
  extraConfig = ''
    CONFIG_IDENT_STRING=" ${version}"
    CONFIG_VIDEO_FONT_4X6=n
    CONFIG_VIDEO_FONT_8X16=n
    CONFIG_VIDEO_FONT_SUN12X22=n
    CONFIG_VIDEO_FONT_16X32=y
    CONFIG_CMD_BOOTMENU=y
  '';
}).overrideAttrs
  (o: {
    # nixos's downstream patches are not applicable
    patches = [
    ];

    # DTC= flag somehow breaks DTC compilation so we remove it
    makeFlags = builtins.filter (s: (!(lib.strings.hasPrefix "DTC=" s))) o.makeFlags;

    preInstall = ''
      # compress so that m1n1 knows U-Boot's size and can find things after it
      gzip -n u-boot-nodtb.bin
      cat ${m1n1}/build/m1n1.bin arch/arm/dts/t[68]*.dtb u-boot-nodtb.bin.gz > m1n1-u-boot.bin
    '';
  })
