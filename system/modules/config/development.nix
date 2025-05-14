# Development environment configuration module that uses the config system
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configuration
  cfg = moduleSystem.getModuleConfig config.sysConfig.development;

  # Helper to check if a feature is enabled
  isEnabled = feature: feature ? cfg && cfg.${feature};

  # Helper to check if a language is enabled
  isLanguageEnabled = lang: cfg.languages.${lang} or false;

  # Helper to check if a tool is enabled
  isToolEnabled = tool: cfg.tools.${tool} or false;
in {
  config = lib.mkIf (isEnabled "enable") (lib.mkMerge [
    # Basic development tools always included
    {
      environment.systemPackages = with pkgs; [
        # Basic development tools
        gnumake
        cmake
        gcc
        gdb
        lldb

        # Utilities
        ripgrep
        fd
        jq
        yq
        curl
        wget
        tree
        du-dust
        unzip
        p7zip

        # Text editors
        vim
      ];

      # Standard programs
      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };
    }

    # Git configuration
    (lib.mkIf (isToolEnabled "git") {
      # Git packages
      environment.systemPackages = with pkgs; [
        git
        git-lfs
        gitui
        gh
        delta
      ];

      # Git program configuration
      programs.git = {
        enable = true;
        lfs.enable = true;
        config = {
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
          push = {
            autoSetupRemote = true;
          };
        };
      };
    })

    # Neovim configuration
    (lib.mkIf (isToolEnabled "neovim") {
      environment.systemPackages = with pkgs; [
        neovim

        # Language servers and development tools that enhance neovim
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        lua-language-server
        rust-analyzer
        gopls
        pyright
      ];

      # Set default editor to neovim
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    })

    # VS Code configuration
    (lib.mkIf (isToolEnabled "vscode") {
      environment.systemPackages = with pkgs; [
        vscode
      ];
    })

    # Docker configuration
    (lib.mkIf (isToolEnabled "docker") {
      virtualisation = {
        docker = {
          enable = true;
          autoPrune.enable = true;
        };
      };

      environment.systemPackages = with pkgs; [
        docker-compose
        lazydocker
      ];

      # Add user to docker group
      users.users.${config.sysConfig.user.defaults.name}.extraGroups = ["docker"];
    })

    # Python development configuration
    (lib.mkIf (isLanguageEnabled "python") {
      environment.systemPackages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.ipython
        python3Packages.black
        python3Packages.flake8
        python3Packages.mypy
        python3Packages.poetry
        python3Packages.virtualenv
        python3Packages.pipx
      ];
    })

    # Rust development configuration
    (lib.mkIf (isLanguageEnabled "rust") {
      environment.systemPackages = with pkgs; [
        rustup
        rust-analyzer
        cargo-edit
        cargo-watch
        cargo-audit
        cargo-outdated
      ];
    })

    # Node.js development configuration
    (lib.mkIf (isLanguageEnabled "node") {
      environment.systemPackages = with pkgs; [
        nodejs
        yarn
        nodePackages.pnpm
        nodePackages.typescript
        nodePackages.typescript-language-server
      ];
    })

    # Go development configuration
    (lib.mkIf (isLanguageEnabled "go") {
      environment.systemPackages = with pkgs; [
        go
        gopls
        golangci-lint
        gotools
        go-tools
      ];

      # Set up Go environment
      environment.variables = {
        GOPATH = "$HOME/go";
        GOBIN = "$HOME/go/bin";
        PATH = ["$HOME/go/bin"];
      };
    })

    # Java development configuration
    (lib.mkIf (isLanguageEnabled "java") {
      environment.systemPackages = with pkgs; [
        jdk
        maven
        gradle
        jdt-language-server
      ];

      # Set up Java environment
      environment.variables = {
        JAVA_HOME = "${pkgs.jdk}";
      };
    })
  ]);
}
