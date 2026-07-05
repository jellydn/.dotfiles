# Compatibility shim for `nix-shell` (legacy interface).
# Delegates to the flake's devShell so both `nix-shell` and `nix develop` work.
{
  system ? builtins.currentSystem,
}:
(builtins.getFlake (toString ./.)).devShells.${system}.default
