declare global {
  interface Window {
    Telegram: {
      WebApp: {
        initData: string
        colorScheme: 'light' | 'dark'
        themeParams: Record<string, string>
        BackButton: {
          show(): void
          hide(): void
          onClick(cb: () => void): void
          offClick(cb: () => void): void
        }
        MainButton: {
          text: string
          show(): void
          hide(): void
          enable(): void
          disable(): void
          setText(text: string): void
          onClick(cb: () => void): void
          offClick(cb: () => void): void
          showProgress(leaveActive?: boolean): void
          hideProgress(): void
        }
        expand(): void
        ready(): void
        CloudStorage: {
          setItem(key: string, value: string, cb?: (err: Error | null, success: boolean) => void): void
          getItem(key: string, cb: (err: Error | null, value: string) => void): void
          getItems(keys: string[], cb: (err: Error | null, values: Record<string, string>) => void): void
          removeItem(key: string, cb?: (err: Error | null, success: boolean) => void): void
          removeItems(keys: string[], cb?: (err: Error | null, success: boolean) => void): void
          getKeys(cb: (err: Error | null, keys: string[]) => void): void
        }
      }
    }
  }
}

const tg = () => window.Telegram?.WebApp

export function getInitData(): string {
  return tg()?.initData ?? ''
}

export function expandApp() {
  tg()?.expand()
}

export function ready() {
  tg()?.ready()
}

export function useTelegramTheme() {
  const params = tg()?.themeParams ?? {}
  const isDark = tg()?.colorScheme === 'dark'

  const themeOverrides = {
    common: {
      ...(params.bg_color && { bodyColor: params.bg_color }),
      ...(params.text_color && { textColor1: params.text_color, textColor2: params.text_color }),
      ...(params.hint_color && { textColor3: params.hint_color, placeholderColor: params.hint_color }),
      ...(params.button_color && {
        primaryColor: params.button_color,
        primaryColorHover: params.button_color,
        primaryColorPressed: params.button_color,
        primaryColorSuppl: params.button_color,
      }),
      ...(params.secondary_bg_color && {
        cardColor: params.secondary_bg_color,
        modalColor: params.secondary_bg_color,
        popoverColor: params.secondary_bg_color,
        tableColor: params.secondary_bg_color,
      }),
      ...(params.link_color && { infoColor: params.link_color }),
    },
  }

  return { themeOverrides, isDark }
}

export function useBackButton() {
  return {
    show: () => tg()?.BackButton.show(),
    hide: () => tg()?.BackButton.hide(),
    onClick: (cb: () => void) => tg()?.BackButton.onClick(cb),
    offClick: (cb: () => void) => tg()?.BackButton.offClick(cb),
  }
}

export function useMainButton() {
  return {
    show: () => tg()?.MainButton.show(),
    hide: () => tg()?.MainButton.hide(),
    enable: () => tg()?.MainButton.enable(),
    disable: () => tg()?.MainButton.disable(),
    setText: (text: string) => tg()?.MainButton.setText(text),
    onClick: (cb: () => void) => tg()?.MainButton.onClick(cb),
    offClick: (cb: () => void) => tg()?.MainButton.offClick(cb),
    showProgress: () => tg()?.MainButton.showProgress(),
    hideProgress: () => tg()?.MainButton.hideProgress(),
  }
}
