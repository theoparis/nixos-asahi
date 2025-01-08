{
  fetchFromGitLab,
  mesa,
  lib,
  libglvnd,
  libpng,
  stdenv,
  llvmPackages,
}:

let
  vulkanLayers = [
    "device-select"
    "overlay"
    "screenshot"
  ];

  galliumDrivers = [
    "softpipe"
    "zink"
  ];
  vulkanDrivers = [
    "swrast"
    "asahi"
  ];
  eglPlatforms = [ "wayland" ];
in
(mesa.override {
  inherit galliumDrivers vulkanDrivers eglPlatforms;
}).overrideAttrs
  (previous: {
    src = fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "mesa";
      repo = "mesa";
      rev = "1f333ac9fa9b6d168562a5c8a56008c0124c7918";
      hash = "sha256-7ehRkm+KLy7RuilaL7qubd1BBR3hEClN5qqkxnGndGA=";
    };

    patches = [
      ./opencl.patch
    ];

    buildInputs = previous.buildInputs ++ [
      libpng
    ];

    mesonFlags =
      [
        "--sysconfdir=/etc"
        "--datadir=${placeholder "drivers"}/share"

        (lib.mesonEnable "split-debug" true)

        # What to build
        (lib.mesonOption "platforms" (lib.concatStringsSep "," eglPlatforms))
        (lib.mesonOption "gallium-drivers" (lib.concatStringsSep "," galliumDrivers))
        (lib.mesonOption "vulkan-drivers" (lib.concatStringsSep "," vulkanDrivers))
        (lib.mesonOption "vulkan-layers" (lib.concatStringsSep "," vulkanLayers))
        (lib.mesonEnable "xlib-lease" false)
        (lib.mesonOption "glx" "disabled")
        (lib.mesonEnable "gallium-vdpau" false)
        (lib.mesonEnable "gallium-va" false)
        (lib.mesonEnable "gallium-xa" false)
        (lib.mesonEnable "libunwind" false)

        # Make sure we know where to put all the drivers
        (lib.mesonOption "dri-drivers-path" "${placeholder "drivers"}/lib/dri")
        (lib.mesonOption "vdpau-libs-path" "${placeholder "drivers"}/lib/vdpau")
        (lib.mesonOption "va-libs-path" "${placeholder "drivers"}/lib/dri")
        (lib.mesonOption "d3d-drivers-path" "${placeholder "drivers"}/lib/d3d")

        # Set search paths for non-Mesa drivers (e.g. Nvidia)
        (lib.mesonOption "gbm-backends-path" "${libglvnd.driverLink}/lib/gbm:${placeholder "out"}/lib/gbm")

        # Enable glvnd for dynamic libGL dispatch
        (lib.mesonEnable "glvnd" true)

        (lib.mesonBool "gallium-nine" true) # Direct3D in Wine
        (lib.mesonBool "osmesa" true) # used by wine
        (lib.mesonBool "teflon" true) # TensorFlow frontend

        # Enable Intel RT stuff when available
        (lib.mesonBool "install-intel-clc" true)
        (lib.mesonBool "install-mesa-clc" true)
        (lib.mesonEnable "intel-rt" stdenv.hostPlatform.isx86_64)
        (lib.mesonOption "clang-libdir" "${lib.getLib llvmPackages.clang-unwrapped}/lib")

        # Rusticl, new OpenCL frontend
        (lib.mesonBool "gallium-rusticl" true)

        # meson auto_features enables this, but we do not want it
        (lib.mesonEnable "android-libbacktrace" false)
        (lib.mesonEnable "microsoft-clc" false) # Only relevant on Windows (OpenCL 1.2 API on top of D3D12)
        (lib.mesonEnable "valgrind" false)
        (lib.mesonOption "video-codecs" "all")
      ]
      ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
        (lib.mesonOption "intel-clc" "system")
        (lib.mesonOption "mesa-clc" "system")
      ];
  })
