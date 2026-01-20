# Claude Code

Claude Code の設定ファイル。

## Setup

```bash
ln -sfn ~/src/github.com/hiramatsutaku/dotfiles/claude/skills ~/.claude/skills
```

## Skills

### /codex-review

OpenAI Codex を使用して未コミットの変更をコードレビューする。

```bash
# 前提条件
npm install -g @openai/codex
```

## Commands

### /obsidian

セッションの作業内容を Obsidian 用にまとめる。
