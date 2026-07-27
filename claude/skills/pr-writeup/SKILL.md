---
name: pr-writeup
description: >-
  PR の内容から self-contained な「PR 説明書」HTML を生成する。レビュアーに PR
  の背景・変更内容・レビュー観点を 1 ファイルで俯瞰してもらいたい時、「PR を HTML
  にして」「PR 説明書を作って」と頼まれた時に使う。
---

# pr-writeup

PR の内容を、ブラウザで開ける 1 ファイルの「PR 説明書」HTML として生成するスキル。Markdown の PR 本文では分散してしまう背景・差分・レビュー観点を、サイドナビ付きの構造化ドキュメントとして俯瞰できるようにする。

## 対象 PR の解決

まずデフォルトブランチを取得する: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`（以下 `<base>`）。

1. 引数に PR 番号があればそれを使う
2. 引数がなければ現在ブランチの PR を解決する: `gh pr view --json number,state`。`state` が `OPEN` 以外（クローズ・マージ済み）の場合は過去の PR なので採用せず、次のドラフトモードに進む
3. PR が存在しなければ **ドラフトモード**: `git fetch origin <base>` した上で、`git diff $(git merge-base origin/<base> HEAD)`（未コミットの変更も含めて merge-base と比較する）と `git log origin/<base>..HEAD --oneline` を入力に、PR 作成前の説明書として生成する。ローカルの `<base>` は stale なことがあるので基点にしない。未追跡ファイルは `git diff` に現れないため、`git ls-files --others --exclude-standard` で列挙して内容を Read し、新規ファイルとして説明に含める

## データ収集

```bash
gh pr view <番号> --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,url,commits
gh pr diff <番号>
```

- diff だけで変更の意図が読み取れないファイルは、該当ソースを Read して文脈を補完する
- PR 本文・リンクされた issue（`Closes #xxx` 等）があれば「Why」セクションの材料にする

## HTML の仕様

**1 ファイル・self-contained** で生成する。外部 CSS / JS / フォント / CDN / 画像への参照を一切含めない（社外ネットワークなしでも開けること）。本文は日本語で書く。

PR 本文・diff・コミットメッセージ由来のテキストは必ず HTML エスケープして埋め込む。`<script>` 等の実行可能コードを HTML に含めず、JS なしで成立させる（開閉は `<details>` など HTML 標準機能で実現する）。生成した HTML は `open` で即ブラウザ表示されるため、外部由来テキストの生埋め込みはローカルでのスクリプト実行につながる。

### セクション構成

上から順に以下を配置する。`id` を振り、サイドナビからアンカーリンクする。

1. **ヘッダー** — PR タイトル、メタデータ行（`head → base` ブランチ、`+追加/-削除` 行数、変更ファイル数、作者、PR URL へのリンク）
2. **TL;DR** — 左ボーダー（clay 色）で強調した 2〜4 文の要約
3. **Why** — 「Before」「After」の 2 カラム対比パネル。Before は現状の課題、After はこの PR 後の状態を箇条書きで
4. **File-by-file** — ファイルごとの `<details>` 開閉式カード。`<summary>` にファイルパス（モノスペース）+ 変更種別バッジ（new / mod / del）+ `±行数`。中身は「何をなぜ変えたか」の説明と、要点となる差分の抜粋
5. **Where to focus** — レビューで重点的に見てほしい箇所の番号付きリスト。ファイルパス・行の参照つきで、なぜそこがリスクかを書く
6. **Test plan** — 実施済み・未実施の検証項目をチェックボックス（`☑` / `☐`）で
7. **Rollout** — デプロイ順序・マイグレーション・ロールバック手順など展開時の注意。単純な PR では省略してよい

### レイアウト・スタイル

- 右側に `position: sticky` の縦型サイドナビ（セクションへのアンカー）。`max-width: 768px` 以下では非表示にする
- 配色は CSS 変数で定義する:
  - `--ivory: #FAF9F5`（ページ背景）
  - `--slate: #141413`（本文・コードブロック背景）
  - `--clay: #D97757`（強調・削除 diff）
  - `--olive: #788C5D`（成功・追加 diff）
- フォント階層: 見出し（h1/h2）はセリフ、本文はサンセリフ、メタデータ・コード・ファイルパスはモノスペース。いずれもシステムフォントスタック（`Georgia, serif` / `-apple-system, sans-serif` / `ui-monospace, monospace` 等）を使う
- コードブロックは slate 背景の明色文字。`<span>` + クラスで簡易シンタックスハイライトする: `.kw`（キーワード = clay）、`.str`（文字列 = olive）、`.cm`（コメント = グレー）、`.add`（追加行 = olive 系背景）、`.del`（削除行 = clay 系背景 + 打ち消し線）
- 横幅の広い diff やテーブルはコンテナ側に `overflow-x: auto` を付け、ページ全体を横スクロールさせない

## 出力

- 出力先: `${TMPDIR:-/tmp}/pr-writeup/<リポジトリ名>-pr-<番号>.html`（ドラフトモードは `<リポジトリ名>-<ブランチ名>.html`。ブランチ名に含まれる `/` は `-` に置換する）。リポジトリの作業ツリー内には書き出さない（gitignore 状況がリポジトリごとに異なるため）
- 生成後 `open <ファイルパス>` でブラウザ表示し、ユーザにファイルパスを報告する
