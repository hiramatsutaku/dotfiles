# pr-quality-loop の進捗を PR の単一コメントに随時反映する

`/pr-quality-loop` は実時間で数十分かかるが進捗がローカルに閉じていたため、
PR にマーカー付き (`<!-- pr-quality-loop-status -->`) のコメントを 1 つ置き、
フェーズ遷移ごとに `PATCH /repos/{owner}/{repo}/issues/comments/{id}` で書き換える方式にした。

新規コメントを積まないのはタイムラインを汚さないため。本文は `jq -n --rawfile` で JSON 化する
（`-F body=@file` の型推論を避け、Markdown のバッククォート・引用符を確実にエスケープするため）。
`gh` が失敗してもループ本体は止めない（fork PR や権限不足でコメントできないことがあるため）。
