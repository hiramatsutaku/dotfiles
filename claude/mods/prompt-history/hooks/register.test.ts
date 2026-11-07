import { expect, test } from 'claude-code/testing'
import type { On } from 'claude-code'
import type { Engine } from 'claude-code/testing'

const BAND = {
  plugin: 'prompt-history',
  component: 'AbovePrompt',
  props: { hasSurvey: false, isWorking: false, maxRows: 30, bodyColumns: 100, scroll: { offset: 0, bodyRows: 29 }, view: {} },
} as const

const answerBandAsEngine = (on: On) =>
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return Text({ children: ['下の帯'] })
  })

const submit = ($: Engine, text: string, extra: object = {}) =>
  $.prompt.submit({ text, wait: false, origin: { kind: 'composer' }, ...extra } as Parameters<Engine['prompt']['submit']>[0])

for (const surface of ['terminal', 'desktop'] as const) {
  test(`${surface}: 入力がまだ無いときは帯を描かない`, async ($, on) => {
    // Arrange
    answerBandAsEngine(on)

    // Act
    const ui = await $.ui.mount({ ...BAND, surface })

    // Assert
    expect(await ui.find({ text: '入力履歴' })).toBeUndefined()
    expect(await ui.find({ text: '下の帯' })).toBeDefined()
  })

  test(`${surface}: 人が Enter で送った入力だけを新しい順に出し、下の帯も残す`, async ($, on) => {
    // Arrange
    answerBandAsEngine(on)
    on('prompt.submit', (_$, e) => ({ text: e.text }))

    // Act
    await submit($, '最初の\n入力')
    await submit($, '/issues', { command: { name: 'issues', args: '' } })
    await submit($, 'メタの入力', { isMeta: true })
    await submit($, '通知の入力', { origin: { kind: 'task-notification' } })
    await submit($, '二番目の入力')
    const ui = await $.ui.mount({ ...BAND, surface })
    const texts = (await ui.findAll({ type: 'Text' })).map((el) => el.text)

    // Assert
    expect(texts).toContain('入力履歴')
    expect(texts).toContain('直近 2 件')
    const first = texts.indexOf('最初の 入力')
    const second = texts.indexOf('二番目の入力')
    expect(second).toBeGreaterThan(-1)
    expect(first).toBeGreaterThan(second)
    expect(texts).not.toContain('メタの入力')
    expect(texts).not.toContain('通知の入力')
    expect(texts).not.toContain('/issues')
    expect(texts).toContain('下の帯')
  })

  test(`${surface}: 11 件以上送っても新しい 10 件だけを出す`, async ($, on) => {
    // Arrange
    answerBandAsEngine(on)
    on('prompt.submit', (_$, e) => ({ text: e.text }))
    for (let i = 1; i <= 11; i++) await submit($, `入力${i}`)

    // Act
    const ui = await $.ui.mount({ ...BAND, surface })
    const texts = (await ui.findAll({ type: 'Text' })).map((el) => el.text)

    // Assert
    expect(texts).toContain('入力11')
    expect(texts).toContain('入力2')
    expect(texts).not.toContain('入力1')
  })

  test(`${surface}: survey が帯を使っているときは描かない`, async ($, on) => {
    // Arrange
    answerBandAsEngine(on)
    on('prompt.submit', (_$, e) => ({ text: e.text }))
    await submit($, '入力')

    // Act
    const ui = await $.ui.mount({ ...BAND, surface, props: { ...BAND.props, hasSurvey: true } })

    // Assert
    expect(await ui.find({ text: '入力履歴' })).toBeUndefined()
    expect(await ui.find({ text: '下の帯' })).toBeDefined()
  })
}
