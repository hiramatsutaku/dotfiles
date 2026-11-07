export type SentPrompt = { at: string; text: string }

declare module 'claude-code' {
  interface PluginState {
    'prompt-history': { prompts: SentPrompt[] }
  }
}
