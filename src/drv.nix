{ lib, jq, niri, writeShellApplication }:

writeShellApplication {
  name = "niri-scratchpad";
  bashOptions = [ "errexit" "pipefail" ];
  runtimeInputs = [ jq niri ];

  text =
    let src = builtins.readFile ./scratchpad.sh;
    in builtins.replaceStrings [ "#! /usr/bin/env bash" ] [ "" ] src;

  meta = {
    description = "Scratchpad support for the Niri Wayland compositor";
    homepage = "https://github.com/gvolpe/niri-scratchpad";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ gvolpe ];
    mainProgram = "niri-scratchpad";
    platforms = lib.platforms.linux;
  };
}
