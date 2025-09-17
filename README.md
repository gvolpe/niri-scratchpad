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

Access the package via `niri-scratchpad` or `default`.

```nix
inputs.niri-scratchpad-flake.packages.${system}.niri-scratchpad;
```

Only available for Linux systems, see `nix flake show`.

```console
$ nix flake show --all-systems
git+file:///home/gvolpe/workspace/niri-scratchpad
└───packages
    ├───aarch64-linux
    │   ├───default: package 'niri-scratchpad'
    │   └───niri-scratchpad: package 'niri-scratchpad'
    └───x86_64-linux
        ├───default: package 'niri-scratchpad'
        └───niri-scratchpad: package 'niri-scratchpad'
```

If Nix is not your jam, simply copy the [scratchpad.sh](./src/scratchpad.sh) file into your system and give it execution permissions (`chmod +x scratchpad.sh`). Even if you're on Nix, have a look at the script source code :)

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

For a better experience, *declare all your workspaces explicitly* and add the "scratch" one last. [Example](https://github.com/gvolpe/nix-config/blob/7cc8c60c41a73f30c5c11957a1780496dec265d4/home/wm/niri/config.kdl#L611).

In this example, we create a window rule so that both `spotify` and `nemo` are spawned in the "scratch" workspace. Additionally, we spawn these processes at startup. 

Next, we have our scratchpad keybindings.

```kdl
binds {
    Mod+Ctrl+S { spawn-sh "niri-scratchpad spotify"; }
    Mod+Ctrl+F { spawn-sh "niri-scratchpad --app-id nemo"; }
}
```

Both `spotify` and `nemo` are spawned at startup by Niri (via `spawn-at-startup`).

To further enhance your experience, you may consider a second script resizing your scratchpad windows and placing them at the XY location you wish when Niri starts up. [Example](https://github.com/gvolpe/nix-config/blob/9af91fee7757645aac6fef9ed5ba76128cbcbd97/home/wm/niri/scripts.nix#L17).

### Spawn

In the following example, we have a keybinding for the Audacious application, which is not spawned by Niri. So we can indicate that if the process does not yet exist, it should be spawned by `niri-scratchpad` (internally done via `niri msg spawn`).

```kdl
binds {
    Mod+Ctrl+A { spawn-sh "niri-scratchpad --app-id Audacious --spawn audacious"; }
}
```

**NOTE**: a spawned window via the `--spawn` flag can't be made floating the first time it's brought up, but it will be from the second time onwards, due to a known limitation. If you would like to avoid this, you can either fix it via a window rule, or by letting Niri start the process at startup instead.

### Animations

By default, scratchpad animations are disabled. To enable them, set the `NIRI_SCRATCHPAD_ANIMATIONS` environment variable to any value, e.g.

```console
NIRI_SCRATCHPAD_ANIMATIONS=true niri-scratchpad nemo
```

The animation is achieved by switching the scratchpad window to tiling mode when it's moved to the scratch workspace, and subsequently making it a floating window when it's summoned.

## Known Limitations

Given the fact that Niri doesn't support "hidden" workspaces, this solution imposes a few caveats. First of all, the "scratch" workspace will always be visible if you scroll all the way down to your last workspace, it can't be hidden.

### Dynamic workspaces

If you rely on accessing your workspaces by index (e.g. `Mod+2`, `Mod+3`) and don't explicitly declare your workspaces in your configuration, then it means you're relying on dynamic workspaces, which is the default in Niri.

Declaring only the "scratch" workspace and leaving everything else as dynamic still works, but you can't expect your indices to remain the same. So always declare all your workspaces explicitly (see [Named Workspaces](https://yalter.github.io/niri/Configuration%3A-Named-Workspaces.html)) if you'd like the indices to be predictable.

Nevertheless, a better approach is to access your workspaces by name instead, e.g.

```kdl
workspace "web"
workspace "dev"
workspace "scratch"

binds {
    Mod+1 { focus-workspace "web"; }
    Mod+2 { focus-workspace "dev"; }
    Mod+Shift+1 { move-window-to-workspace "web"; }
    Mod+Shift+2 { move-window-to-workspace "dev"; }
}
```

By using named workspaces, we also get to enjoy dynamic workspaces. See [addressing workspaces by index](https://yalter.github.io/niri/Workspaces.html#addressing-workspaces-by-index) in the official docs for more.
