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


  # Enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

environment.variables = {
  EDITOR = "nvim";
  # VISUAL = "nvim"; # Optionally set VISUAL as well
  JAVA_HOME = "/run/current-system/sw/lib/openjdk";
};


  # Update PATH to include JAVA_HOME
  environment.extraInit = ''
    export PATH="$JAVA_HOME/bin:$PATH"
  '';


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

  # Window Managers =====================

  # XFCE =========================================
  services.xserver.desktopManager.xfce.enable  = true;
  services.displayManager.defaultSession  = "xfce";
  #DWM ================================================
  services.xserver.windowManager.dwm.enable = true;

  # dwm custom config
  services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs {
    src = /home/xalil/suckless/dwm;
  };
  # i3 window manager==================================
  services.xserver.windowManager.i3.enable = true;

  #===================================================

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  #=========Printer==============================

  # Enable CUPS for printing
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.browsedConf = ''
  BrowseDNSSDSubTypes _cups,_print
  BrowseLocalProtocols all
  BrowseRemoteProtocols all
  CreateIPPPrinterQueues All

  BrowseProtocols all
  '';
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  #===============================================
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
    extraGroups = [ "networkmanager" "wheel" "docker" "lp" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # virtual box setup
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "xalil" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.draganddrop = true;
  # ===================

  nixpkgs.config.permittedInsecurePackages = [
     "openssl-1.1.1w"
  ];
            


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget


# Bluetooth
bluez
bluez-tools
blueman

# Terminal Apps
oh-my-zsh
zsh-powerlevel10k
vim
neovim
fzf
ripgrep
git
ranger
tmux
htop
surfraw
xclip
wget
jq
yt-dlp
zip
unzip
stow
translate-shell
gnumake
bc
gcc # Gnu compiler for gcc etc.
binutils # required for nvim and others
ffmpeg-full
gst_all_1.gst-libav # required by ffmpeg for h.264 videos
alsa-utils
docker
docker-compose
sdcv # dictionary for offline use
brightnessctl # brithness control: brightnessctl set +5%  OR brightnessctl set 5%-
xbindkeys # bind keyboard shortcuts to commands. requires ~/.xbindkeys which is in dotfiles
shotcut # video editor
pandoc # document conversion
cups # printing package
coreutils-full
upower #battary check
acpi # battary check

xorg.xev # find keyboard keys code
xbindkeys

# LaTeX
texliveFull
texmaker

# IDE and Programming Languages
vscode
eclipses.eclipse-java


jetbrains.idea-community
jdk11
jdt-language-server # java language server
maven
python3

# Browsers
brave
google-chrome
chromedriver

# General GUI Apps
audio-recorder
libsForQt5.okular
sublime4
sioyek
mpv
mupdf
postman
espanso
zoom-us
libreoffice-qt6-still
freetube
emacs
sbcl # emacs lisp compiler. Without this ripgrep doesnt work in emacs
gnome.gnome-keyring
obsidian
pavucontrol
shutter # image editor
obs-studio
discord
anki
goldendict-ng # Dictionary app
#syncthing 
feh
vlc
libpng
libjpeg
libtiff

# Postgresql
#postgresql
#dbeaver-bin
#mysql-workbench

# XFCE Related==============
#leafpad
xarchiver

## XFCE Themes
plata-theme
numix-gtk-theme
arc-icon-theme

## XFCE Thunar
xfce.thunar
xfce.thunar-volman 
xfce.thunar-archive-plugin 
xfce.xfce4-whiskermenu-plugin
xfce.xfce4-volumed-pulse
xfce.xfce4-pulseaudio-plugin
# DWM ============================
dmenu
st
alacritty
slstatus


# i3 Window Manager
i3
i3status
xterm

# Kde
#kdePackages.ark #File archiver

# Gnome
#gnome.file-roller #Gnome Archive Manager
gnome.gnome-disk-utility


# Android
android-file-transfer

];



# Fonts
fonts.packages = with pkgs; [
dejavu_fonts
noto-fonts
nerdfonts
jetbrains-mono
font-awesome
];


#=================================

# non nix binary
programs.nix-ld.enable = true;

# for global user ZSH
users.defaultUserShell=pkgs.zsh; 

# enable zsh and oh my zsh
programs.zsh = {
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

# source powerlevel10k
programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

# zsh aliases
programs.zsh.shellAliases = {
    h = "cd ~";
    d = "cd ~/Desktop";
    p="cd ~/Pictures/";
    dn="cd ~/Downloads/";
    doc="cd ~/Documents/";
    notlar="cd ~/Documents/notlar";
    dot="cd /home/xalil/dotfiles";

    # Config Files
    bookmarks="vim /home/xalil/dotfiles/surfraw/.config/surfraw/bookmarks";
    resume = "mupdf ~/Documents/IbrahimKaraagacResume.pdf";

    # Other Files
    sqlfile = "nvim /home/xalil/dotfiles/sql/ibrahim.sql";

    # nix related
    nix-conf="sudo nvim /etc/nixos/configuration.nix";
    nix-switch ="sudo nixos-rebuild switch";

    # Dictionaries and Google Translate Online
    entr="trans en:tr"; #English to Turkish
    tren="trans tr:en"; #Turkish to English

    sdcv="sdcv --data-dir ~/Documents/stardict-oald-2.4.2";

    #Apps
    sqldeveloper="/home/xalil/Apps/sqldeveloper/sqldeveloper/bin/sqldeveloper &";

    #Udemy =====================================
    udemy-main="google-chrome-stable 'https://www.udemy.com/home/my-courses/learning'";
    udemy-cucumber="google-chrome-stable  'https://www.udemy.com/course/cucumber-from-scratch/learn/lecture/19199846?start=795#overview'";
    udemy-sql="google-chrome-stable 'https://www.udemy.com/course/oracle-sql-12c-become-an-sql-developer-with-subtitle/learn/lecture/34672622#overview'";
    udemy-github="google-chrome-stable 'https://www.udemy.com/course/git-and-github-bootcamp/learn/lecture/24869800?start=242#overview'";
    udemy-selenium="google-chrome-stable 'https://www.udemy.com/course/master-selenium-webdriver-with-java/learn/lecture/15448944?start=0#overview'";
    udemy-testng="google-chrome-stable 'https://www.udemy.com/course/the-complete-testng-automation-framework-design-course/learn/lecture/19998732?start=192#overview'";
    udemy-rest="google-chrome-stable 'https://www.udemy.com/course/learn-rest-api-automation-using-rest-assured/learn/lecture/24651094?start=9#overview'";
    udemy-algabra="google-chrome-stable 'https://www.udemy.com/course/integralcalc-algebra/learn/lecture/1223528?start=2#overview'";
    udemy-math="google-chrome-stable 'https://www.udemy.com/course/fundamentals-of-math/learn/lecture/16319778#overview'";
    udemy-redhat="google-chrome-stable 'https://www.udemy.com/course/unofficial-linux-redhat-certified-system-administrator-rhcsa-8/learn/lecture/26928962?start=75#overview'";

    udemy-rahul-cicd="google-chrome-stable 'https://www.udemy.com/course/selenium-real-time-examplesinterview-questions/learn/lecture/42310428#overview'";

    udemy-rahul-jdbc="google-chrome-stable 'https://www.udemy.com/course/selenium-real-time-examplesinterview-questions/learn/lecture/3289318#overview'";
    #===============Java Projects in Eclipse============================
    cd-interview = "cd /home/xalil/eclipse-workspace/javainterview/src/main/java";
    cd-restassured="cd /home/xalil/eclipse-workspace/RestAssured_DizLearn/src/test";
    cd-testngDez="cd /home/xalil/eclipse-workspace/TestNG_Dez/src";
    cd-cucumber="cd /home/xalil/eclipse-workspace/CucumberBDD_dezlearn";
    cd-jdbc="cd /home/xalil/eclipse-workspace/RenastechJDBCC/src/main/java/renastech/jdbc";
    cd-selenium="cd /home/xalil/eclipse-workspace/Selenium_Automation/src/test/java";
    cd-general="cd /home/xalil/eclipse-workspace/GeneralStudy/src/main/java";

    # nvim open these 
    n-interview="nvim /home/xalil/eclipse-workspace/javainterview/src/main/java";
    n-restassured="nvim /home/xalil/eclipse-workspace/RestAssured_DizLearn/src/test";
    n-testngDez="nvim /home/xalil/eclipse-workspace/TestNG_Dez/src";
    n-cucumber="nvim /home/xalil/eclipse-workspace/CucumberBDD_dezlearn";
    n-jdbc="nvim /home/xalil/eclipse-workspace/RenastechJDBCC/src/main/java/renastech/jdbc";
    n-selenium="nvim /home/xalil/eclipse-workspace/Selenium_Automation/src/test/java";
    n-general="nvim /home/xalil/eclipse-workspace/GeneralStudy/src/main/java";
    #================idea =================================================
    idea-collection = "idea-community '/home/xalil/eclipse-workspace/CollectionsAPI/'";
    idea-cucumber = "idea-community '/home/xalil/eclipse-workspace/CucumberBDD_dezlearn/'";
    idea-functional= "idea-community '/home/xalil/eclipse-workspace/Functional/'";
    idea-general = "idea-community '/home/xalil/eclipse-workspace/GeneralStudy/'";
    idea-javainterview = "idea-community '/home/xalil/eclipse-workspace/javainterview/'";
    idea-jdbc = "idea-community '/home/xalil/eclipse-workspace/RenastechJDBCC/'";
    idea-rest = "idea-community '/home/xalil/eclipse-workspace/RestAssured_DizLearn/'";
    idea-selenium= "idea-community '/home/xalil/eclipse-workspace/Selenium_Automation/'";
    idea-SeleniumTestNG07 = "idea-community '/home/xalil/eclipse-workspace/SeleniumTestNG07/'";
    idea-Streams = "idea-community '/home/xalil/eclipse-workspace/Streams/'";

    # copy/paste for linux machines (Mac style)
    pbcopy="xclip -selection clipboard";	# copy to clipboard, ctrl+c, ctrl+shift+c
    pbpaste="xclip -selection clipboard -o";	# paste from clipboard, ctrl+v, ctrl+shift+v
    pbselect="xclip -selection primary -o";	# paste from highlight, middle click, shift+insert
};

# ======Docker ===============
virtualisation.docker.enable = true;


# ===============Espanso systemd config=========

  # make sure to: espanso service register

  systemd.services.espanso = {
    description = "Espanso Text Expander";
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/espanso start";
      Restart = "on-failure";
      User = "xalil";
      Environment = "HOME=/home/xalil";

    };

    wantedBy = [ "default.target" ];
  };

#===========syncthing=========================
#services = {
#    syncthing = {
#        enable = true;
#        user = "xalil";
#        dataDir = "/home/xalil/Documents/SyncthingShare";    # Default folder for new synced folders
#        configDir = "/home/xalil/.config/syncthing";   # Folder for Syncthing's settings and keys
#    };
#};


#===============================================

  # GVFS - Enable usb drive to appear automatically in file manager
  services.gvfs.enable = true;


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

