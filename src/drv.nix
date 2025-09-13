{ jq, libnotify, niri, writeShellApplication }:

writeShellApplication {
  name = "niri-scratchpad";
  bashOptions = [ "errexit" "pipefail" ];
  runtimeInputs = [ jq libnotify niri ];
  text =
    let src = builtins.readFile ./scratchpad.sh;
    in builtins.replaceStrings [ "#! /usr/bin/env bash" ] [ "" ] src;
}
