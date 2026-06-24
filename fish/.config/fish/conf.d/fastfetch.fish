if status is-interactive
    # Show fastfetch as the shell greeting: it runs automatically on terminal
    # open, so there's no typed command and no prompt/directory line above it.
    function fish_greeting
        fastfetch
    end
end
