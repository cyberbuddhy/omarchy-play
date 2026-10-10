# omarchy-play

Play any artist, song, album, genre, or mood from YouTube Music — from your terminal.

Type `play tame impala` and music starts. It keeps going with related music after, like radio.

Made for [Omarchy](https://omarchy.org/) (Hyprland on Arch), but works on any Linux with the requirements below.

## What it does

- `play <anything>` — plays the top match, then related music forever
- `play --pick <query>` — choose from top 8 matches
- `play --list <query>` — just list matches, don't play
- `play --mood "chill evening"` / `play --genre lofi` — favors long mixes
- `play --browser <query>` — open it in YouTube Music in your browser instead
- `play --video <query>` — play with video window (default is audio-only)
- `play --prompt` — pop-up prompt (Omarchy menu) asking what to play
- `play --stop` / `play --toggle` / `play --next` / `play --prev` / `play --now` — control playback

A new `play` replaces what's currently playing.

## How it works

1. `yt-dlp` searches YouTube (same catalogue YouTube Music uses) and picks the best match — prefers Official / VEVO / Topic channels.
2. `mpv` plays it audio-only.
3. A background watcher queues the YouTube Mix (songs 2–26, then tops up 25 more before it runs dry) so music never stops.
4. Current track is saved to `~/.local/state/play/current`.

That's it. No API key, no account, no daemon to manage.

## Requirements

```bash
mpv yt-dlp socat jq
```

On Omarchy / Arch:

```bash
omarchy pkg add mpv yt-dlp socat jq libnotify
# libnotify gives you `notify-send` for the "▶ now playing" popup
```

Optional for the nice pop-ups (already on Omarchy):

- `omarchy-menu-select` + `omarchy-menu-input` (for `--pick` / `--prompt`)
- `omarchy-launch-browser` (for `--browser`)
- `playerctl` (for Spotify ⏯ ⏭ ⏮ buttons: `omarchy pkg add playerctl`)
- Hyprland (`HYPRLAND_INSTANCE_SIGNATURE`) — otherwise it falls back to plain terminal prompts

## Install

### As an Omarchy plugin (recommended)

```bash
omarchy plugin add https://github.com/cyberbuddhy/omarchy-play.git --enable
```

This adds a  button to your bar — no configuration needed:

- Left-click opens the dropdown panel: search bar (type, hit Enter, it plays),
  ⏮ ⏯ ⏭ ⏹ controls, now-playing title, and a provider dropdown.
- Right-click pauses/resumes, middle-click stops.

Then, for the `play` command itself, Super+Space entries, and a guided
provider choice, run the installer once:

```bash
git clone https://github.com/cyberbuddhy/omarchy-play.git
cd omarchy-play
./install.sh
```

`install.sh` copies `play` to `~/.local/bin`, merges `Play music` / `Stop music`
entries into your Super+Space menu (nothing else in that file is touched), and
asks which provider to use — free first, paid second. Safe to re-run.

### As a plain script

```bash
git clone https://github.com/cyberbuddhy/omarchy-play.git
cd omarchy-play
cp play ~/.local/bin/play
chmod +x ~/.local/bin/play
play --help
```

`~/.local/bin` is already on PATH on Omarchy. Open a new terminal if `play` isn't found yet.

Update later:

```bash
cd omarchy-play
git pull
cp play ~/.local/bin/play
```

## Remove

```bash
omarchy plugin remove io.github.cyberbuddhy.omarchy-play
rm ~/.local/bin/play
play --stop  # clears state in ~/.local/state/play/
```

Also delete the `music.play` / `music.stop` keys from
`~/.config/omarchy/extensions/omarchy-menu.jsonc` if you ran `install.sh`,
and optionally `rm -rf ~/.config/play ~/.local/state/play`.

## Providers

| Provider | Cost | How it plays | Controls |
|---|---|---|---|
| YouTube Music (default) | Free | `yt-dlp` + `mpv`, endless related-music radio | Full: ⏯ ⏭ ⏮ ⏹ |
| Spotify | Paid account + app or browser | Opens the match in Spotify (app via `omarchy-launch-browser`, else web player) | Via `playerctl` (`omarchy pkg add playerctl`) |

Switch anytime: the provider dropdown in the bar panel, `./install.sh` again,
`play --provider spotify <query>` for one shot, or
`echo spotify > ~/.config/play/provider`.

## Use

```bash
play tame impala
play "the less i know the better"
play "currents album"
play lofi hip hop
play --mood "rainy evening jazz"
play --pick daft punk
play --list "blinding lights"
play --browser "bohemian rhapsody"
play --now
play --next
play --toggle
play --stop
```

Tips:

- Open in Chrome/Edge-based browser for best YouTube Music playback if you use `--browser`.
- Saves/state live in `~/.local/state/play/` (`mpv.sock`, `current`, `*.pid`, `play.log`). Just `play --stop` to clear it.

## Omarchy keybindings

Add to `~/.config/hypr/bindings.lua`:

```lua
-- play — Super+Space, type "play", Enter, type what you want, Enter
o.bind("SUPER + ALT + P", "Play music (prompt)", "play --prompt")
o.bind("SUPER + SHIFT + ALT + P", "Stop music", "play --stop")
```

Or add a menu entry in `~/.config/omarchy/extensions/omarchy-menu.jsonc`:

```jsonc
{
  "music.play": { "icon": "", "label": "Play music", "action": "play --prompt" },
  "music.stop": { "icon": "", "label": "Stop music", "action": "play --stop" }
}
```

## Files in this repo

- `play` — the whole player (one bash script, YouTube Music + Spotify)
- `manifest.json` — Omarchy plugin manifest (bar-widget)
- `BarWidget.qml` — bar button driving the panel
- `Panel.qml` — dropdown panel: search bar, controls, provider picker
- `install.sh` — one-shot setup: binary, Super+Space entries, provider choice
- `README.md` — this file
- `LICENSE` — MIT

## Note

Links/music come from YouTube / other people's uploads. You should own or have rights to what you play where required. This repo ships no music files.
