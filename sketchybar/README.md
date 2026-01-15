# SketchyBar

macOS 用のカスタマイズ可能なメニューバー。
SoichiroYamane さんの dotfiles をベースにしています。

## Dependencies

```bash
# Core
brew install lua switchaudio-osx nowplaying-cli

# Fonts
brew install --cask sf-symbols font-sf-mono font-sf-pro

# App Font
curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.5/sketchybar-app-font.ttf -o ~/Library/Fonts/sketchybar-app-font.ttf

# SbarLua (Lua bindings for SketchyBar)
git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua && make install && rm -rf /tmp/SbarLua
```

## Setup

```bash
ln -s ~/src/github.com/hiramatsutaku/dotfiles/sketchybar ~/.config/sketchybar

# Build event providers
cd ~/.config/sketchybar/helpers/event_providers && make

# Update app icons
~/.config/sketchybar/icon_updater.sh
```

## Start Service

```bash
brew services start sketchybar
```

## Reference

- https://github.com/FelixKratz/SketchyBar
- https://github.com/SoichiroYamane/dotfiles
