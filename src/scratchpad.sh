#! /usr/bin/env bash

##############################################################################################
#        _        _                                  _          _                        _   #
#       (_)      (_)                                | |        | |                      | |  #
# _ __   _  _ __  _          ___   ___  _ __   __ _ | |_   ___ | |__   _ __    __ _   __| |  #
#| '_ \ | || '__|| | ______ / __| / __|| '__| / _` || __| / __|| '_ \ | '_ \  / _` | / _` |  #
#| | | || || |   | ||______|\__ \| (__ | |   | (_| || |_ | (__ | | | || |_) || (_| || (_| |  #
#|_| |_||_||_|   |_|        |___/ \___||_|    \__,_| \__| \___||_| |_|| .__/  \__,_| \__,_|  #
#                                                                     | |                    #
#                                                                     |_|                    #
#                                                                                            #
##############################################################################################
#
# Adapted from the many ideas shared at: https://github.com/YaLTeR/niri/discussions/329

SCRATCH_WORKSPACE_NAME=scratch

SEARCH_METHOD_FLAG=$1
SCRATCH_WIN_NAME=$2
SPAWN_FLAG=$3
PROCESS_NAME=$4

showHelp() {
  echo "[niri-scratchpad]"
  echo ""
  echo "  Open scratchpad app by app-id:"
  echo "    - 'niri-scratchpad spotify'"
  echo "    - 'niri-scratchpad --app-id spotify'"
  echo ""
  echo "  Open scratchpad by title (some apps do not support app-id):"
  echo "    - 'niri-scratchpad --title Telegram'"
  echo ""
  echo "  Spawn process on first request if it does not exist:"
  echo "    - 'niri-scratchpad --app-id Audacious --spawn audacious'"
  echo ""
  echo "  NOTE: when using the '--spawn' flag, you MUST indicate either '--app-id' or 'title' flag as well."
}

windows=$(niri msg -j windows)

case $SEARCH_METHOD_FLAG in
  "--app-id")
    app_window=$(echo "$windows" | jq ".[] | select(.app_id == \"$SCRATCH_WIN_NAME\")")
    ;;
  "--title")
    app_window=$(echo "$windows" | jq ".[] | select(.title == \"$SCRATCH_WIN_NAME\")")
    ;;
  "--help")
    showHelp
    exit 0
    ;;
  "--version")
    echo "niri-scratchpad v0.0.1"
    exit 0
    ;;
  *)
    SCRATCH_WIN_NAME=$1
    app_window=$(echo "$windows" | jq ".[] | select(.app_id == \"$SCRATCH_WIN_NAME\")")
    ;;
esac

win_id=$(echo "$app_window" | jq .id)

if [[ -z $win_id ]]; then
  case $SPAWN_FLAG in
    "--spawn")
      if [[ -z $PROCESS_NAME ]]; then
        showHelp
        exit 1
      else
        niri msg action spawn -- "$PROCESS_NAME"
        exit 0
      fi
      ;;
    *)
      showHelp
      exit 1
      ;;
  esac
fi

moveWindowToScratchpad() {
  niri msg action move-window-to-workspace --window-id "$win_id" "$SCRATCH_WORKSPACE_NAME" --focus=false
  if [[ -n $NIRI_SCRATCHPAD_ANIMATIONS ]]; then
    niri msg action move-window-to-tiling --id "$win_id"
  fi
}

bringScratchpadWindowToFocus() {
  is_win_floating=$(echo "$app_window" | jq .is_floating)
  niri msg action move-window-to-workspace --window-id "$win_id" "$work_id"
  if [[ $is_win_floating == "false" && -n $NIRI_SCRATCHPAD_ANIMATIONS ]]; then
    niri msg action move-window-to-floating --id "$win_id"
  fi
  niri msg action focus-window --id "$win_id"
}

if [[ $(echo "$app_window" | jq .is_focused) == "false" ]]; then
  work_id=$(niri msg -j workspaces | jq '.[] | select(.is_focused == true)' | jq .idx)
  win_work_id=$(echo "$app_window" | jq .workspace_id)

  if [[ "$win_work_id" == "$work_id" ]]; then
    moveWindowToScratchpad
  else
    bringScratchpadWindowToFocus
  fi
else
  moveWindowToScratchpad
fi
