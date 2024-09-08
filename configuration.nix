# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

#========got chromedriver=================

let
  # Define the channel you want
  chromeChannel = "stable";  # Adjust as needed (stable, beta, dev)

  # Define a function to get the correct Chrome package
  getChromePackage = channel: pkgs."google-chrome-${channel}";

  # Get the correct package for the selected channel
  chromePkg = getChromePackage chromeChannel;

  # Define the wrapper script
  chromeWrapper = pkgs.writeShellScriptBin "google-chrome" ''
    #!/bin/sh
    exec ${chromePkg}/bin/google-chrome-stable "$@"
  '';
in

#=========================================

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hpnix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  #Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Emacs Daemon
  services.emacs = {
    enable = true;
    package = pkgs.emacs; # replace with emacs-gtk, or a version provided by the community overlay if desired.
  };

# Postgress Config
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "mydatabase" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };


  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # KDE
  #services.displayManager.sddm.enable = true;
  #services.desktopManager.plasma6.enable = true;

  # XFCE
  services.xserver.desktopManager.xfce.enable  = true;
  services.displayManager.defaultSession  = "xfce";
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
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
  users.users.xalil = {
    isNormalUser = true;
    description = "xalil";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

            
  nixpkgs.config.permittedInsecurePackages = [
     "openssl-1.1.1w"
  ];
            


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
alacritty
vim
neovim
fzf
git
jdk20
maven
ranger
tmux
libsForQt5.okular
htop
surfraw
dejavu_fonts
texliveFull
texmaker
vscode
sublime4
xclip
eclipses.eclipse-java
jetbrains.idea-community
chromedriver
mpv
brave
google-chrome
mupdf
postman
bitwarden-desktop
espanso
zoom-us
github-desktop
libreoffice-qt6-still
wget
jq
yt-dlp
freetube
zip
unzip
emacs
gnome.gnome-keyring
obsidian

# Postgresql
postgresql
dbeaver-bin
mysql-workbench

#XFCE Related
leafpad
plata-theme
arc-icon-theme
gnome.file-roller
xfce.thunar
xfce.xfce4-whiskermenu-plugin
xfce.thunar-archive-plugin
numix-gtk-theme
xfce.xfce4-volumed-pulse
xfce.xfce4-pulseaudio-plugin


];


# non nix binary
programs.nix-ld.enable = true;

# for global user ZSH
users.defaultUserShell=pkgs.zsh; 

# enable zsh and oh my zsh
programs = {
   zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
         enable = true;
         theme = "robbyrussell";
         plugins = [
           "git"
	   "fzf"
	   "ripgrep"
           "history"
         ];
      };
   };
};


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

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
  system.stateVersion = "24.05"; # Did you read the comment?

}
