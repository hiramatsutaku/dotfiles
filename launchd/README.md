# launchd

macOS の launchd ジョブ定義ファイル。

## セットアップ

`~/Library/LaunchAgents/` へ symlink を作成してジョブを登録する。

```bash
# symlink 作成
ln -sf ~/src/github.com/hiramatsutaku/dotfiles/launchd/com.hiramatsutaku.daily-report.plist \
  ~/Library/LaunchAgents/com.hiramatsutaku.daily-report.plist

# ジョブを登録
launchctl load ~/Library/LaunchAgents/com.hiramatsutaku.daily-report.plist
```

## ジョブ一覧

| ファイル | 内容 | スケジュール |
|---------|------|------------|
| `com.hiramatsutaku.daily-report.plist` | `/daily-report` スキルを自動実行 | 毎日 0:00 |

## 確認・デバッグ

```bash
# ジョブ一覧に登録されているか確認
launchctl list | grep hiramatsutaku

# 手動でトリガーして動作確認（即時実行）
launchctl start com.hiramatsutaku.daily-report

# ログ確認
tail -f ~/Library/Logs/daily-report.log
```

## 注意事項

- macOS スリープ中は実行されない（0時にスリープしていた場合はスキップされる）
- Slack OAuth トークンが期限切れになると日報が不完全になる → ログで定期確認
