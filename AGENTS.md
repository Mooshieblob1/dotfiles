# AGENTS.md

Operational notes for AI agents editing this repo. Read before making changes.

## What this is

Personal dotfiles for a **NixOS + Hyprland (Wayland)** rice, managed with **GNU Stow**.
Each top-level directory is a stow *package*; `~/.config/<app>` (and `~/.tmux.conf`) are
symlinks **into this repo**, so editing a file here edits the live config directly.
Commit + push to persist.

## Applying changes

- Stow a package: `cd ~/dotfiles && stow -t ~ <pkg>`  (re-stow: `stow -R -t ~ <pkg>`).
- After editing hypr: `hyprctl reload`.
- After editing waybar: `pkill -SIGUSR2 waybar`.

## Pulling remote changes

`~/.config/<app>` are symlinks into this repo, so `cd ~/dotfiles && git pull`
makes edits to **existing** tracked files go live immediately — no re-stow
needed. Then reload the affected app (see above). Two things `pull` does *not*
do on its own:

- **New package** added remotely → `stow -t ~ <pkg>` once to create its symlinks.
- **New hypr file** added remotely → symlink it per-file (atomically); the hypr
  dir is deliberately not a folded symlink (see Quirks).

`pull` fails if a tracked file has conflicting local edits. wallust's generated
color files are gitignored, so they never conflict.

## Theming is wallust-driven — do NOT hand-edit color files

`wallust` is the single source of truth for colors. On a wallpaper change it renders the
templates in `wallust/.config/wallust/templates/` (wired up in `wallust.toml`) into each
app's color file, then runs a reload hook (waybar SIGUSR2, `makoctl reload`,
`hyprctl reload`, thunar restart).

Re-render manually:

```sh
wallust run "$(cat ~/.cache/current_wallpaper)"
```

These targets are **generated at runtime and gitignored** — never edit them; edit the
*template* instead:

| Generated file (gitignored)                      | Source template            |
|--------------------------------------------------|----------------------------|
| `hypr/.config/hypr/colors.conf`                  | `hyprland-colors.conf`     |
| `waybar/.config/waybar/colors.css`               | `waybar-colors.css`        |
| `waybar/.config/waybar/calendar-colors.jsonc`    | `waybar-calendar.jsonc`    |
| `wofi/.config/wofi/colors.css`                   | `wofi-colors.css`          |
| `eww/.config/eww/colors.scss`                    | `eww-colors.scss`          |
| `~/.config/mako/config` (entire file)            | `mako-config`              |
| `~/.themes/wallust/gtk-3.{0,20}/gtk.css` (outside repo) | `flatcolor-gtk3*.css` |
| VSCode theme (outside repo)                      | `vscode-color-theme.json`  |

## Quirks / footguns

- **Never delete `hypr/.config/hypr/hyprland.conf` (or the hypr dir) while Hyprland is
  running.** A live Hyprland watches its config and instantly regenerates a ~541-byte
  *stub* if the file goes missing, racing any `rm`. That is why **hypr uses per-file
  symlinks** rather than a single folded directory symlink. Replace a hypr symlink
  atomically (`ln -s` to a temp name, then `mv -T`); never delete-then-recreate.
- **mako is intentionally NOT a stow package.** Its entire config is wallust-generated,
  so `~/.config/mako/` is left as a plain directory. The source lives in the wallust
  template `mako-config`.
- **eww / layer-shell popups: no outer `box-shadow`.** eww sizes the surface to its
  content, so an outer shadow clips into a hard dark rectangle around the panel. Style
  popups with background + border + `border-radius` only, keep the window root
  transparent (`window, window.background { background-color: transparent; }`), and use
  an inset highlight if you want depth. (waybar/wofi are normal toplevels and shadow fine.)
- **Gitignored, do not commit:** the wallust outputs above, `fish/.config/fish/fish_variables`
  (machine-specific), `*.bak`, and `result` (Nix build artifacts).
- **Apps themselves are installed by the NixOS system flake** (separate repo at
  `/etc/nixos`), not from here. This repo holds configuration only.

## Packages

`hypr` `waybar` `wallust` `fish` `wofi` `eww` `fastfetch` `gtk-3.0` `ghostty` `nvim` `zathura` `tmux`

(`ghostty`, `nvim`, `zathura`, `tmux` originated from szymonwilczek/dotfiles.)
