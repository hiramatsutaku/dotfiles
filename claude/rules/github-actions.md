GitHub Actions のワークフローファイル (.github/workflows/*.yml) を作成・編集する際:

- サードパーティ action の `uses` にはタグではなくコミットハッシュ (full SHA) を指定する
- ハッシュの後ろにバージョンをパッチバージョンまでコメントする
- 例: `uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1`
- YAML コメントを多めに書く。各ステップや設定ブロックの意図・背景がわかるようにする
