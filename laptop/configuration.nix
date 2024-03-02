# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;

  networking.hostName = "nixin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ /* any engine you want, for example */ m17n bamboo ];
   };
  # i18n.defaultLocale = "vi_VN";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"]; # or "nvidiaLegacy470 etc.

  hardware.nvidia = {

    prime = {
      amdgpuBusId = "PCI:102:0:0";
      nvidiaBusId = "PCI:1:0:0";

      offload = {
  			enable = true;
  			enableOffloadCmd = true;
  		};
    };

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    exportConfiguration = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.xuta = {
    isNormalUser = true;
    createHome = true;
    description = "Xuta Le";
    extraGroups = [ "networkmanager" "wheel" ];
    group = "xuta";
    home = "/home/xuta";
    uid = 1000;
    initialPassword = "abc123";
    shell = pkgs.bashInteractive;
    packages = with pkgs; [
      # firefox
    #  thunderbird
    ];
  };

  users.groups.xuta = {
    gid = 1000;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "electron-25.9.0"
  ];

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bashInteractive
    wget
    curl
    git
    vim
    helix

    lm_sensors
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services = {
    thinkfan = {
      enable = true;

      # sensors = ''
      #   # Entries here discovered by:
      #   # find /sys/devices -type f -name "temp*_input"
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp6_input
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp3_input
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp7_input
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp4_input
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp1_input
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp5_input
      #   hwmon /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon6/temp2_input
      #   hwmon /sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon5/temp1_input
      #   hwmon /sys/devices/pci0000:00/0000:00:01.2/0000:02:00.0/ieee80211/phy0/hwmon7/temp1_input
      #   hwmon /sys/devices/pci0000:00/0000:00:08.1/0000:66:00.0/hwmon/hwmon4/temp1_input
      #   hwmon /sys/devices/pci0000:00/0000:00:02.4/0000:05:00.0/nvme/nvme0/hwmon3/temp3_input
      #   hwmon /sys/devices/pci0000:00/0000:00:02.4/0000:05:00.0/nvme/nvme0/hwmon3/temp1_input
      #   hwmon /sys/devices/pci0000:00/0000:00:02.4/0000:05:00.0/nvme/nvme0/hwmon3/temp2_input
      #   hwmon /sys/devices/virtual/thermal/thermal_zone0/hwmon1/temp1_input
      # '';

      levels = [
        [0 0  41]
        [1 40 56]
        [2 55 61]
        [3 60 65]
        [4 64 68]
        [5 67 78]
        [6 77 90]
        [7 87 32767]
      ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
