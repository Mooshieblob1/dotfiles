# dotfiles

Personal configuration for a **NixOS + Hyprland (Wayland)** desktop, managed with
[GNU Stow](https://www.gnu.org/software/stow/). Colors across every app are driven
by [wallust](https://codeberg.org/explosion-mental/wallust), so the whole rice
re-themes itself from the current wallpaper.

> Apps are installed by my NixOS system flake
> ([nixos-config](https://github.com/Mooshieblob1/nixos-config)), not from here.
> This repo holds **configuration only**.

## How it works

Each top-level directory is a stow *package* whose contents mirror their location
under `$HOME`:

```
dotfiles/
  hypr/.config/hypr/...
  waybar/.config/waybar/...
  fish/.config/fish/...
  tmux/.tmux.conf
  ...
```

Running `stow` symlinks those paths into `~`, so `~/.config/<app>` points **back
into this repo**. Editing a live config therefore edits the repo directly — just
commit to persist.

## Install

```sh
git clone https://github.com/Mooshieblob1/dotfiles ~/dotfiles
cd ~/dotfiles

# stow every package (back up / move any conflicting real files first)
stow -t ~ hypr waybar wallust fish wofi fastfetch gtk-3.0 ghostty nvim zathura tmux
```

Re-stow a single package after adding files: `stow -R -t ~ <pkg>`.

After editing configs:

- **hypr** → `hyprctl reload`
- **waybar** → `pkill -SIGUSR2 waybar`

## Packages

| Package     | Target                          |
|-------------|---------------------------------|
| `hypr`      | `~/.config/hypr`                |
| `waybar`    | `~/.config/waybar`              |
| `wallust`   | `~/.config/wallust`             |
| `fish`      | `~/.config/fish`                |
| `wofi`      | `~/.config/wofi`                |
| `fastfetch` | `~/.config/fastfetch`           |
| `gtk-3.0`   | `~/.config/gtk-3.0`             |
| `ghostty`   | `~/.config/ghostty`             |
| `nvim`      | `~/.config/nvim`                |
| `zathura`   | `~/.config/zathura`             |
| `tmux`      | `~/.tmux.conf`                  |

## Theming (wallust)

`wallust` is the single source of truth for colors. On a wallpaper change it
renders the templates in `wallust/.config/wallust/templates/` into each app's
color file and runs a reload hook (waybar SIGUSR2, `makoctl reload`,
`hyprctl reload`, restart thunar).

Re-render manually:

```sh
wallust run "$(cat ~/.cache/current_wallpaper)"
```

The generated color files are **gitignored** — never edit them by hand, edit the
matching *template* instead and re-render. The mapping:

| Generated file (gitignored)                     | Source template          |
|-------------------------------------------------|--------------------------|
| `hypr/.config/hypr/colors.conf`                 | `hyprland-colors.conf`   |
| `waybar/.config/waybar/colors.css`              | `waybar-colors.css`      |
| `waybar/.config/waybar/calendar-colors.jsonc`   | `waybar-calendar.jsonc`  |
| `wofi/.config/wofi/colors.css`                  | `wofi-colors.css`        |
| `~/.config/mako/config` (whole file)            | `mako-config`            |
| `~/.themes/wallust/gtk-3.{0,20}/gtk.css`        | `flatcolor-gtk3*.css`    |
| VSCode color theme                              | `vscode-color-theme.json`|

## Notes & gotchas

- **hypr uses per-file symlinks**, not a folded directory symlink. A running
  Hyprland watches its config and instantly regenerates a stub `hyprland.conf`
  if the file disappears, so the directory can't be safely re-folded while it's
  running. Replace a hypr symlink atomically (`ln -s` to a temp name, then
  `mv -T`) rather than delete-then-recreate.
- **mako is intentionally not a stow package** — its config is 100%
  wallust-generated, so `~/.config/mako/` is left as a plain directory. Its
  source lives in the wallust template `mako-config`.
- **Gitignored:** the wallust outputs above, `fish/.config/fish/fish_variables`
  (machine-specific), `*.bak`, and Nix `result` artifacts.

See [`AGENTS.md`](AGENTS.md) for operational notes aimed at AI agents.

## Credits

`ghostty`, `nvim`, `zathura`, and `tmux` configs originated from
[szymonwilczek/dotfiles](https://github.com/szymonwilczek/dotfiles).
