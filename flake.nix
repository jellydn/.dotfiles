{
  description = "jellydn's NixOS + nix-darwin + home-manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Dotfiles repo - source for symlinked config files (helix, ghostty, lazygit, kitty, nvim)
    dotfiles = {
      url = "github:jellydn/dotfiles";
      flake = false;
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , nix-darwin
    , ...
    }:
    let
      # Shared home-manager config (works on both NixOS and macOS)
      homeConfig = { username, homeDirectory, ... }: {
        imports = [ ./home ];
        home = {
          inherit username homeDirectory;
          stateVersion = "24.05";
        };
      };

      # Helper to add unstable packages from nixpkgs-unstable
      unstable = import nixpkgs-unstable {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };

      unstableDarwin = import nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };

      # Common dev shell packages (shared between platforms)
      # Derived from home/packages.nix, using only cross-platform tools
      devPackages = pkgs: with pkgs; [
        # CLI essentials
        curl wget jq unzip zip htop ripgrep fd bat eza fzf tree du-dust duf procs sd

        # Git / Dev tools
        gh lazygit git-lfs diff-so-fancy delta ghq diffr

        # Shell / Terminal
        fish zsh tmux direnv zoxide

        # Languages
        nodejs_22 deno bun go python3 rustup gnumake cmake gcc

        # LSP / Formatting
        nil nixfmt-rfc-style statix deadnix
        nodePackages.biome nodePackages.prettier typos

        # Misc
        mise just jujutsu yq
      ];
    in
    {
      # ── NixOS (ARM Linux machine) ──────────────────────────────
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit unstable dotfiles; };
        modules = [
          ./configuration.nix
          ./modules/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit dotfiles; };
            home-manager.users.dunghd = homeConfig {
              username = "dunghd";
              homeDirectory = "/home/dunghd";
            };
          }
        ];
      };

      # ── Formatter (nix fmt) ────────────────────────────────────
      formatter.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.nixfmt-rfc-style;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;

      # ── Dev shells (nix develop) ──────────────────────────────
      devShells.aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.mkShellNoCC {
        packages = devPackages nixpkgs.legacyPackages.aarch64-linux;
        shellHook = ''
          echo "🛠️  jellydn dotfiles dev shell (aarch64-linux)"
        '';
      };

      devShells.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShellNoCC {
        packages = devPackages nixpkgs.legacyPackages.aarch64-darwin;
        shellHook = ''
          echo "🛠️  jellydn dotfiles dev shell (aarch64-darwin)"
        '';
      };

      # ── nix-darwin (macOS - this Mac) ─────────────────────────
      darwinConfigurations.dunghd = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit unstableDarwin dotfiles; };
        modules = [
          ./darwin.nix
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit dotfiles; };
            home-manager.users.huynhdung = homeConfig {
              username = "huynhdung";
              homeDirectory = "/Users/huynhdung";
            };
          }
        ];
      };
    };
}
