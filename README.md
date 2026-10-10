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
- Hyprland (`HYPRLAND_INSTANCE_SIGNATURE`) — otherwise it falls back to plain terminal prompts

## Install

### As an Omarchy plugin (recommended)

```bash
omarchy plugin add https://github.com/cyberbuddhy/omarchy-play.git --enable
```

This adds a  button to your bar: left-click asks what to play,
right-click pauses/resumes, middle-click stops. The widget calls the `play`
script below, so the requirements still apply.

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

- `play` — the whole player (one bash script)
- `manifest.json` — Omarchy plugin manifest (bar-widget)
- `BarWidget.qml` — bar button driving the `play` script
- `README.md` — this file
- `LICENSE` — MIT

## Note

Links/music come from YouTube / other people's uploads. You should own or have rights to what you play where required. This repo ships no music files.
