---
name: convex-dev-resend
risk: safe
source: https://github.com/get-convex/resend
description: Official Convex + Resend integration with queueing, batching, idempotency, and webhook-driven delivery tracking.
---

# Convex + Resend

Use the official `@convex-dev/resend` component to send transactional emails from Convex with queueing, batching, retries, and delivery tracking.

## When to Use

- The user wants resilient email delivery from Convex functions.
- The user needs non-blocking bulk sends that respect Resend rate limits.
- The user asks for webhook-based status tracking (`delivered`, `bounced`, `opened`, etc.).
- The user needs idempotent retries to prevent duplicate emails.

## Core Workflow

1. Install and register the component in `convex/convex.config.ts`.
2. Instantiate `Resend` once in a Convex module (for example `convex/email/send.ts`).
3. Send emails via `resend.sendEmail(ctx, payload)` from mutations/actions.
4. Mount webhook endpoint in `convex/http.ts` and set `RESEND_WEBHOOK_SECRET`.
5. Add cleanup cron for old finalized emails.
6. For production, set `testMode: false` explicitly.

## Setup

```bash
npm install @convex-dev/resend
```

```ts
// convex/convex.config.ts
import { defineApp } from 'convex/server';
import resend from '@convex-dev/resend/convex.config.js';

const app = defineApp();
app.use(resend);

export default app;
```

## Copy-Paste Example

```ts
// convex/email/send.ts
import { v } from 'convex/values';
import { Resend } from '@convex-dev/resend';

import { components } from '../_generated/api';
import { internalAction } from '../_generated/server';

export const resend = new Resend(components.resend, {
  // Keep true in dev/sandbox, set to false in production.
  testMode: true,
});

export const sendWelcomeEmail = internalAction({
  args: {
    to: v.string(),
    username: v.string(),
  },
  returns: v.null(),
  handler: async (ctx, args) => {
    await resend.sendEmail(ctx, {
      from: 'CEL <onboarding@resend.dev>',
      to: args.to,
      subject: 'Bienvenue sur CEL',
      html: `<p>Salut ${args.username}, bienvenue.</p>`,
    });
    return null;
  },
});
```

## Webhook Wiring

```ts
// convex/http.ts
import { httpRouter } from 'convex/server';
import { httpAction } from './_generated/server';
import { resend } from './email/send';

const http = httpRouter();

http.route({
  path: '/resend-webhook',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
    return await resend.handleResendEventWebhook(ctx, req);
  }),
});

export default http;
```

Set these environment variables in Convex deployment:

- `RESEND_API_KEY`
- `RESEND_WEBHOOK_SECRET`

## Production Checklist

- Set `testMode: false` before sending to real recipients.
- Verify domain/sender in Resend dashboard.
- Configure webhook with `email.*` events.
- Track failures with `resend.status(ctx, emailId)`.
- Add periodic cleanup via `components.resend.lib.cleanupOldEmails`.

## Troubleshooting

- **400/401 from Resend**: Validate `RESEND_API_KEY` in Convex environment.
- **Webhook signature errors**: Check `RESEND_WEBHOOK_SECRET` and endpoint URL.
- **No emails to real inboxes**: Ensure `testMode` is disabled.
- **Need attachments/custom features**: Use `sendEmailManually` with Resend SDK.

## Limitations

- `sendEmail` follows Resend batch API constraints.
- Attachments and niche options may require `sendEmailManually`.
- React Email rendering requires a Convex Node action (`'use node';`).
- This skill does not manage DNS/domain verification in Resend.

## Related Skills

- `convex-best-practices`
- `email-systems`
- `react-email`

## Resources

- [Package](https://www.npmjs.com/package/%40convex-dev%2Fresend)
- [Source + README](https://github.com/get-convex/resend)
- [Component Directory](https://www.convex.dev/components/resend)
- [Convex Components Docs](https://docs.convex.dev/components)
