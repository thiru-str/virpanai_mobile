# Wallet / Cart Recompute — Backend vs Frontend Classification

Context: backend fixes for issues 1–4 + BOGO landed on `feature/wallet`
(virpanai). Web storefront still shows stale state after qty changes. This
doc classifies what is backend vs frontend and tells you exactly what
**cartel_mobile** has to do.

---

## TL;DR

| Issue | Where the **logic** lives | Where the **client** must react |
|------|--------------------------|--------------------------------|
| 1. Wallet not updating on qty change | **Backend** | Re-fetch cart after mutation |
| 2. Platform fee miscomputed with combo + coupon | **Backend** | — |
| 3. Auto-coupon "Applied" UI state stale on qty change | **Backend** sets `is_applied`; **client** must re-fetch the promotions list | Re-fetch promotions on cart pricing change |
| 3b. Pricing details panel not refreshing on qty change | **Client** must re-render with the response cart | Re-fetch / re-render cart |
| 4. Platform fee disappears when auto-coupon removed | **Backend** | — |
| BOGO price mismatches | **Backend** | — |

**Key takeaway**: the heavy lifting (wallet cap, platform fee, coupon
auto-apply, BOGO settle) is all backend. The mobile app's job is just
to **always re-fetch the cart (and the promotions list) after any cart
mutation** and treat the backend response as the source of truth.

The Next.js-specific `router.refresh()` fix on `virpanai_web` is **not
relevant to cartel_mobile** — that was solving a Next.js server-component
cache problem. Flutter doesn't have that issue.

---

## What's already shipped on backend (`virpanai` `feature/wallet`)

1. **`recomputeCartPricing` orchestrator** — runs in this order:
   drop platform fee → recalc wallet → recalc loyalty → re-apply platform
   fee. This guarantees:
   - wallet is capped against fee-less cart total (not inflated)
   - platform fee is computed off the up-to-date wallet
   - loyalty recompute sees the real cart total

2. **Subscriber** `cart-updated-for-last-order-payment_provider-id.ts` calls
   the orchestrator on `cart.updated`.

3. **BOGO middleware** (`validateAutoBuyGetPromo`):
   - Phase C: revokes any active `buyget`-type promo whose trigger qty is
     no longer met, and deletes the auto-added free-item line.
   - Phase A: inline-awaits `recomputeCartPricing` before the cart GET
     response so the cart ships fully reconciled.
   - Free items are now stamped with `metadata.promotion_id` so revoke
     can target them precisely.

---

## The remaining backend gap (likely cause of web still being buggy)

The custom line-item routes only **conditionally** await the recompute
pipeline. They call `syncQtyTieredCartSideEffects(scope, cartId)` which
internally awaits the subscriber only when qty-tiered promo state actually
changes:

```ts
// virpanai/src/api/store/custom-carts/[cart_id]/route.ts
const shouldSyncPaymentState =
  !!paymentCollection?.id &&
  (
    !!recalcResult?.changed ||
    (!!qtyTieredPromo?.active && (paymentSessions.length === 0
      || Number(paymentCollection?.amount || 0) !== Number(cart?.total || 0)))
  )
if (shouldSyncPaymentState) { await cartUpdatedForLastOrderPaymentProviderIdHandler(...) }
```

For a plain qty change with no qty-tier promo, the inline wait is skipped.
Medusa still emits `cart.updated`, our subscriber still runs — but it's
async and **fire-and-forget**. The HTTP response returns first, so the cart
the client receives may have wallet/fee from the pre-mutation state.

### Fix to apply on backend

In each of these three route files, add an unconditional inline call to
`recomputeCartPricing(cartId, providerId, scope)` after
`syncQtyTieredCartSideEffects` and before the cart refetch:

- `virpanai/src/api/store/custom-carts/[cart_id]/line-items/route.ts` (POST add)
- `virpanai/src/api/store/custom-carts/[cart_id]/line-items/[line_id]/route.ts` (POST update, DELETE)

The `providerId` can be resolved from the existing payment session (same
helper as in `validateAutoBuyGetPromo`). Pass `null` if no session yet — the
orchestrator skips fee re-apply but still settles wallet + loyalty.

Once this lands, every line-item mutation API guarantees the response cart
is fully reconciled. Both web and mobile will inherit the fix without any
client changes.

---

## What cartel_mobile needs to do (regardless of the backend gap)

Even with a perfectly settled backend response, the mobile app must follow
these patterns or the cart UI will lie:

### 1. Re-fetch the cart after every mutation
Any of these change cart pricing — always re-read the cart from the API
after they succeed and rebuild the cart UI from the response:

- add line item / update qty / remove line item
- apply / remove coupon
- apply / remove wallet split
- apply / remove loyalty points

Don't cache fields like `total`, `subtotal`, `tax_total`, `discount_total`,
`metadata.wallet_split`, `metadata.loyalty_checkout_apply`, or any line item
with `metadata.type === "platform_fee"` beyond the current render.

### 2. Re-fetch the promotions list when cart pricing changes
The "Applied / Eligible / Ineligible" coupon state lives on the
`/store/promotions?cart_id=...` endpoint, **not** on the cart object. The
backend computes `is_applied` per promotion based on the current cart.

If the mobile app caches this list (e.g., for a coupon picker screen), it
must invalidate that cache and re-fetch whenever the cart total / discount /
items change. Otherwise an auto-applied promo (qty-tiered or BOGO) will
keep showing the old applied state.

Fields on each promotion: `code`, `title`, `description`,
`is_eligible`, `is_applied`, `estimated_discount`,
`estimated_discount_display`, `ineligibility_reason`.

### 3. Display platform fee, wallet, and loyalty as separate rows
The backend stores each as either a virtual line item or a metadata field:

- **Platform fee**: a line item with `metadata.type === "platform_fee"`.
  Filter it out of the "products" list and show it as its own summary row
  (`unit_price * quantity`).
- **Wallet (paid)**: `cart.metadata.wallet_split.wallet_amount` (deduction).
  Hide if `cart.metadata.wallet_auto_apply_dismissed === true`.
- **Loyalty discount**: `cart.metadata.loyalty_checkout_apply.discount_amount`
  (deduction). Show only when `points_to_apply > 0`.

The visible "Total" you show the user should be:
```
displayTotal = max(0, cart.total - wallet_amount - loyalty_discount_amount)
```
Note `cart.total` already includes the platform fee line and excludes the
wallet (wallet is metadata-only, not a real line). Don't subtract platform
fee twice.

### 4. BOGO awareness
The free item is added by the backend as a normal line item with
`metadata.auto_added_by_promotion: true` and `metadata.promotion_id: <id>`.
After a successful BOGO trigger, the cart GET will include both the free
line and a `promotions[]` entry of type `buyget`.

When the user reduces qty below the trigger, the next cart GET will return
the cart with the BOGO promo and the free-item line **already removed** by
the backend. Just render whatever the backend says — don't keep your own
copy of the free item.

### 5. Auto-apply dismissal flags
If the mobile UI lets the user opt out of auto-applied promos or
auto-applied wallet, set these cart metadata flags via your existing
update-cart path:

- `cart.metadata.promo_auto_apply_dismissed = true`
- `cart.metadata.wallet_auto_apply_dismissed = true`

The backend honors them and stops auto-applying. They persist on the cart.

---

## Quick checklist for cartel_mobile

- [ ] After every cart mutation, GET cart again (or use the response if you
      trust it post-backend-fix) and rebuild the price summary.
- [ ] Maintain a separate fetch for `/store/promotions?cart_id=...` and
      re-call it whenever the cart pricing changes.
- [ ] Filter line items where `metadata.type === "platform_fee"` out of the
      "items" list; render them in the totals section instead.
- [ ] Read `wallet_split.wallet_amount` from `cart.metadata`, not from a
      line item.
- [ ] Honor `wallet_auto_apply_dismissed` and `promo_auto_apply_dismissed`.
- [ ] Don't surface the free BOGO item as removable — it's controlled by
      the backend and will disappear automatically when the trigger is no
      longer met.

---

## Where to verify on the backend (if you want to confirm the gap)

Files to grep / read in the `virpanai` repo, on `feature/wallet`:

- `src/api/utils/recompute-cart-pricing.ts` — the orchestrator
- `src/api/utils/wallet-split-recalc.ts` — wallet caps
- `src/api/utils/platform-fee.ts` — fee compute (deletes existing fee then
  reapplies; reads `cart.metadata.wallet_split.wallet_amount` to subtract)
- `src/api/utils/loyalty-recalc.ts` — loyalty cap
- `src/api/utils/qty-tiered-promo.ts` — qty-tier evaluator
- `src/api/utils/promo-validator.ts` — `validateAutoBuyGetPromo` (BOGO)
- `src/subscribers/cart/cart-updated-for-last-order-payment_provider-id.ts` —
  ties it all together on `cart.updated`
- `src/api/store/custom-carts/[cart_id]/route.ts` — `syncQtyTieredCartSideEffects`
- `src/api/store/custom-carts/[cart_id]/line-items/route.ts` and
  `.../line-items/[line_id]/route.ts` — the routes that need the
  unconditional inline `recomputeCartPricing` call.
