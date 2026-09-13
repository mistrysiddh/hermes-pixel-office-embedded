/**
 * Pixel Office (embedded) — docks the live Hermes Pixel Office
 * (http://127.0.0.1:8113) as an iframe pane inside the desktop app,
 * plus a statusbar chip showing the live agent count.
 * Plain ESM, uncompiled — jsx() calls, not JSX syntax.
 * Only these imports resolve: @hermes/plugin-sdk, react, react/jsx-runtime.
 */

import { cn, haptic, host, Tip } from '@hermes/plugin-sdk'
import { jsx } from 'react/jsx-runtime'
import { useEffect, useState } from 'react'

const ID = 'pixel-office-view'
const OFFICE_URL = 'http://127.0.0.1:8113'

function OfficePane() {
  return jsx('iframe', {
    src: OFFICE_URL,
    title: 'Hermes Pixel Office',
    className: 'h-full w-full border-0',
    style: { background: 'transparent' }
  })
}

function OfficeChip() {
  const [count, setCount] = useState(null)

  useEffect(() => {
    let alive = true
    const poll = async () => {
      try {
        const res = await fetch(`${OFFICE_URL}/state`, { cache: 'no-store' })
        const data = await res.json()
        if (alive) setCount(Array.isArray(data.agents) ? data.agents.length : null)
      } catch {
        if (alive) setCount(null)
      }
    }
    poll()
    const t = setInterval(poll, 5000)
    return () => {
      alive = false
      clearInterval(t)
    }
  }, [])

  return jsx(Tip, {
    label: count === null ? 'Pixel Office \u2014 unreachable' : `Pixel Office \u2014 ${count} agent(s) live`,
    children: jsx('button', {
      className: cn(
        'inline-flex h-full items-center gap-1 px-1.5 text-[0.6875rem] transition-colors',
        'text-(--ui-text-tertiary) hover:bg-(--chrome-action-hover) hover:text-foreground'
      ),
      type: 'button',
      onClick: () => {
        haptic('tap')
        host.notify({
          kind: 'info',
          message: count === null
            ? 'Pixel Office is unreachable \u2014 is the pixel-office plugin running?'
            : `Pixel Office: ${count} agent(s) currently visible.`
        })
      },
      children: count === null ? '\u26AA office' : `\uD83C\uDFE2 office (${count})`
    })
  })
}

export default {
  id: ID,
  name: 'Pixel Office (embedded)',
  register(ctx) {
    ctx.register({
      id: 'pane',
      area: 'panes',
      title: 'pixel office',
      data: { placement: 'right', width: '340px' },
      render: () => jsx(OfficePane, {})
    })

    ctx.register({
      id: 'chip',
      area: 'statusBar.right',
      order: 150,
      render: () => jsx(OfficeChip, {})
    })
  }
}
