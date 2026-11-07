// このセッションで人が入力したプロンプトを、プロンプトの上の帯に新しい順で出す。
// 帯は 1 つしかないので、ほかの mod（issue-dash など）が描いたものは next(e) で受け取って下に並べる。
// next(e) がエンジン自身の描画を返したとき、それを width を付けた Box の中に置くと木ごと拒否されるので、width は自分の枠にだけ付ける
import { atom, read, update } from 'claude-code'

const SHOWN = 10
const KEPT = 20
const TEXT_KEPT = 500

const prompts = atom({ plugin: 'prompt-history', key: 'prompts' }, [])

function hhmm(iso) {
  const d = new Date(new Date(iso).getTime() + 9 * 3600_000)
  const p = (n) => String(n).padStart(2, '0')
  return `${p(d.getUTCHours())}:${p(d.getUTCMinutes())}`
}

export function register(on) {
  on('prompt.submit', async ($, e, next) => {
    if (e.origin.kind === 'composer' && !e.command && !e.isMeta && e.text.trim() !== '') {
      const sent = { at: new Date().toISOString(), text: e.text.slice(0, TEXT_KEPT) }
      await update($, prompts, (list) => [sent, ...list].slice(0, KEPT))
    }
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)
    const shown = (await read($, prompts)).slice(0, SHOWN)
    if (shown.length === 0) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const below = await next(e)

    const row = (p, i) =>
      Box({
        key: 'prompt-' + i,
        flexDirection: 'row',
        columnGap: 1,
        children: [
          Box({ width: 5, flexShrink: 0, children: [Text({ dimColor: true, children: [hhmm(p.at)] })] }),
          Box({
            flexGrow: 1,
            flexShrink: 1,
            children: [Text({ wrap: 'truncate-end', children: [p.text.replace(/\s+/g, ' ').trim()] })],
          }),
        ],
      })

    return Box({
      flexDirection: 'column',
      children: [
        Box({
          flexDirection: 'column',
          width: e.props.bodyColumns,
          borderStyle: 'round',
          borderColor: 'gray',
          paddingX: 1,
          children: [
            Box({
              flexDirection: 'row',
              columnGap: 1,
              children: [Text({ bold: true, children: ['入力履歴'] }), Text({ dimColor: true, children: [`直近 ${shown.length} 件`] })],
            }),
            ...shown.map(row),
          ],
        }),
        below,
      ],
    })
  })
}
