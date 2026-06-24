if status is-interactive
    # Apply wallust's wallpaper palette (OSC sequences) to the terminal so
    # ANSI-colored output like fastfetch matches the active theme.
    test -e ~/.cache/wallust/sequences && cat ~/.cache/wallust/sequences
end
