# Claude Code

Claude Code の設定ファイル。

## Setup

```bash
ln -sfn ~/src/github.com/hiramatsutaku/dotfiles/claude/skills ~/.claude/skills
ln -sfn ~/src/github.com/hiramatsutaku/dotfiles/claude/commands ~/.claude/commands
ln -sfn ~/src/github.com/hiramatsutaku/dotfiles/claude/scripts ~/.claude/scripts
```

## Skills

### /codex-review

OpenAI Codex を使用して未コミットの変更をコードレビューする。

```bash
# 前提条件
npm install -g @openai/codex
```

### /prompt-review

AIエージェントの対話履歴（Claude Code, GitHub Copilot Chat, Cline, Roo Code, Windsurf, Antigravity, OpenCode）を分析し、技術理解度・プロンプティングパターン・AI依存度をレポートする。

```bash
# 前提条件
python3 --version  # Python 3.10+
```

### /x-search

X (Twitter) 上のリアルタイムな情報・意見を xAI API で検索・要約する。

```bash
# 前提条件
export XAI_API_KEY=your-api-key
```

## Commands

### /coderabbit-review

現在のブランチのPRに対する CodeRabbit AI のレビューコメントを取得・要約する。

### /obsidian

セッションの作業内容を Obsidian 用にまとめる。
