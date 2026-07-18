programs.prismLauncher = {
    enable = true;

    package = pkgs.prismlauncher.override { jdks = [ pkgs.jdk21 pkgs.jdk17 ]; };

    # If you are using Uku's mcsr-nixos package, then I recommend that you use this:
    # package = pkgs.prismlauncher.override { jdks = [ mcsrPkgs.graalvm-21 ]; };

    settings = {
      General = {
        ApplicationTheme = "dark";
        AutoCloseConsole = false;
        AutomaticJavaDownload = false;
        AutomaticJavaSwitch = true;
        ConsoleFont = "JetBrainsMonoNL Nerd Font";
        ConsoleFontSize = 11;

        # Check out the linux-mcsr documentation if you would like to know about the performance benefits of jemalloc.
        # Env = "{\"LD_PRELOAD\":\"${lib.getLib pkgs.jemalloc}/lib/libjemalloc.so.2\"}";

        MaxMemAlloc = 4096;
        MinMemAlloc = 256;

        # If you don't use Waywall, make sure to comment out this line!
        WrapperCommand = "waywall wrap --";
      };

      UI = {
        "mods_Page\\ColumnsVisibility" =
          "{\"Image\":true,\"Last Modified\":true,\"Loaders\":false,\"Minecraft Versions\":false,\"Pack Format\":true,\"Provider\":true,\"Release Type\":false,\"Required By\":false,\"Requires\":false,\"Side\":false,\"Size\":false,\"Version\":true}";
      };
    };
  };
