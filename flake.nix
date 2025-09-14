{
  description = "Niri Scratchpad support";

  inputs = {
    # nix doesn't need the full history, this should be the default ¯\_(ツ)_/¯
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    systems.url = github:nix-systems/default-linux;
    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.systems.follows = "systems";
    };
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        scratchpad-overlay = f: p: {
          niri-scratchpad = p.callPackage ./src/drv.nix { };
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ scratchpad-overlay ];
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          inherit (pkgs) niri-scratchpad;
          default = pkgs.niri-scratchpad;
        };
      }
    );
}
