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
    in
    {
      # ── NixOS (ARM Linux machine) ──────────────────────────────
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit unstable; };
        modules = [
          ./configuration.nix
          ./modules/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dunghd = homeConfig {
              username = "dunghd";
              homeDirectory = "/home/dunghd";
            };
          }
        ];
      };

      # ── nix-darwin (macOS - this Mac) ─────────────────────────
      darwinConfigurations.dunghd = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit unstableDarwin; };
        modules = [
          ./darwin.nix
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.huynhdung = homeConfig {
              username = "huynhdung";
              homeDirectory = "/Users/huynhdung";
            };
          }
        ];
      };
    };
}
