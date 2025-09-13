{
  description = "Niri Scratchpad support";

  inputs = {
    #nixpkgs.url = "nixpkgs/nixos-unstable";
    # nix doesn't need the full history, this should be the default ¯\_(ツ)_/¯
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
  };

  # TODO: build for other linux architectures
  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      scratchpad-overlay = self: super: {
        niri-scratchpad = super.callPackage ./src/drv.nix { };
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ scratchpad-overlay ];
        config.allowUnfree = true;
      };
    in
    {
      packages.${system} = {
        inherit (pkgs) niri-scratchpad;
        default = pkgs.niri-scratchpad;
      };
    };
}
