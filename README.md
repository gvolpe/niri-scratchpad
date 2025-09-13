# niri-scratchpad

Scratchpad support for [Niri](https://github.com/YaLTeR/niri): a scrollable-tiling Wayland compositor.

https://github.com/user-attachments/assets/6911e9b3-0a3c-4657-a564-7fcc3f0037b1

## Usage

Add this flake to your inputs.

```nix
inputs = {
  niri-scratchpad-flake = {
    url = "github:gvolpe/niri-scratchpad";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Access the package via.

```nix
inputs.niri-scratchpad-flake.packages.${system}.niri-scratchpad;
```

If Nix is not your jam, simply copy the [scratchpad.sh](./src/scratchpad.sh) into your system and give it execution permissions (`chmod +x scratchpad.sh`). Even if you're on Nix, have a look at the script source code :)

## Niri Configuration

The workspace "scratch" must exist, the rest is optional.

```kdl
workspace "scratch"

window-rule {
    match app-id=r#"^spotify|nemo$"#
    open-on-workspace "scratch"
    open-floating true
}

spawn-at-startup "spotify"
spawn-at-startup "nemo"
```

For a better experience, add it after all your other workspaces.

In this example, we create a window rule so that both `spotify` and `nemo` are spawned in the "scratch" workspace. Additionally, we spawn these processes at startup. 

Next, we have our scratchpad key-bindings.

```kdl
binds {
    Mod+Ctrl+S { spawn-sh "niri-scratchpad spotify"; }
    Mod+Ctrl+F { spawn-sh "niri-scratchpad --app-id nemo"; }
    Mod+Ctrl+A { spawn-sh "niri-scratchpad --app-id Audacious --spawn audacious"; }
}
```

Both `spotify` and `nemo` are spawned at startup by Niri, but the Audacious application is not. So we can indicate that if the process does not yet exist, it should be spawned (internally done via `niri msg spawn`).
