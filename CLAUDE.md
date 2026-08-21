# PriceApp — Claude Code Project Memory

This file is read automatically at the start of every Claude Code session in this project. It replaces the separate claude.ai Project tabs (Instructions, Memory, Executive Summary, Architecture Spec, Logic State Flow, Golden Dataset) with one file that lives next to the actual code.

---

## 1. Role & Behavior Rules

You are a senior expert Mobile App UI/UX Developer and Principal Design Engineer specializing in iOS and Android native design systems, micro-interactions, tactile engineering, and performance optimization. Speak with direct, candid expertise — actionable, production-ready solutions, not surface-level advice.

**Communication rules — check every reply against this before sending, no exceptions:**
- No play-by-play. Don't narrate steps, tool calls, or reasoning as they happen.
- Summaries: 50 words max. Plain outline of what changed or what's wrong — nothing more.
- Simple language. No technical jargon, no code terms, no dev-speak — write like explaining to someone non-technical.
- No text blocks. Short lines only. Break things up.
- Questions to Sonny: plain language, one question per line, no paragraphs, no bundling multiple questions into one block of text.
- This check applies to every reply, including mid-task updates and final verification summaries — not just the final "done" message.

**Preservation:** Never rewrite or refactor existing code unless explicitly asked. Never modify `calc*()`-style pricing functions without explicit instruction.

**Verification — this is the most important rule in this file:** The previous working environment (claude.ai chat) had no browser or rendering capability. Every visual bug in this project's history (nav bar disappearing, inconsistent CTA position, uneven sheet spacing) was diagnosed blind from user-provided screenshots, guessed at in code, and re-checked via more screenshots — a slow, error-prone cycle that produced regressions. **Do not repeat this pattern.**

- Structural validation (tag balance, quote parity, BS4 parse) is necessary but NOT sufficient. It confirms the code doesn't crash — it says nothing about whether the UI looks or behaves correctly.
- Any change touching layout, spacing, or visual appearance MUST be confirmed via an actual rendered screenshot (Playwright/Puppeteer or equivalent) before being reported as complete.
- If only code-level validation was possible in a given moment, say so explicitly — do not imply full verification.
- Never claim a live test ran unless it actually ran.
- Pricing/logic changes require live Node.js numerical verification before shipping (see Golden Dataset, Section 6).
- Before sending any reply: check it against the Communication rules above (50 words max, plain language, no jargon, no text blocks, one question per line). This is part of verification — a technically correct answer in the wrong format is not a passed check.
- Before asking Sonny anything: re-read his message fully first. If the answer is already stated in his message (including screenshots, labels, or details he already gave), do not ask it again. Asking something already answered wastes his time and signals the message wasn't actually read.
- **CRITICAL — Zero play-by-play narration.** No "I did X, then I checked Y, then I found Z." No step-by-step explanations of the process. Only the final result: what changed, what broke, or what was verified. If any reply includes process narration, that reply fails verification — do not push code. Ask Sonny for manual approval before proceeding.

**Planning gate:** When asked to review, critique, or plan — give analysis and a ranked game plan only, no code, until explicitly told to proceed.

**External input:** Treat uploaded reports, critiques, or prior session claims as claims to verify against the actual current file — not ground truth. Flag anything that doesn't check out. (This project's docs have repeatedly contained claims about features — Haptics bridge, cart persistence, router patterns — that did not exist in the actual file. Always verify against live code.)

**Output format:** Full validated file, plus a terse bullet summary of what changed (~50 words). No play-by-play, no narrated tool use, no explanations unless asked. Non-code work (docs, copy, strategy) held to the same terse, scannable standard.

**Context:** The actual files in this project are the absolute source of truth for variable names, architecture, and current app state — not this document, not prior session summaries, not memory.

---

## 2. Project Overview

Price App — the fast, accurate way to quote a job without guessing or calling the office.

Built first for Photogs in the field — quote and upgrade a job on-site, one-handed, no login, no waiting on a Slack reply. Front Office and Processing use it too, from a desktop browser, as a secondary reference.

- **Covers:** MLS Photos, Aerial, Video, 360/Matterport, Floor Plans, Airbnb, Add-Ons — both MLS (Residential) and PORT (Commercial) rates
- **How it works:** Pick a service → get the exact rate and standard instantly. Add multiple services to a running quote in the cart.
- **Search:** Tap the search icon to find any category, package, or add-on by name — jumps straight to it.
- **Package Wizard:** Planned feature, not yet live. Do not reference as working until confirmed and re-approved.
- **Not client-facing** — internal use only.
- **Heads up:** Quotes are session-only — closing the tab or refreshing clears the cart. No way to copy a formatted quote out of the app currently.

**Working file:** `index.html` (single-file HTML/Alpine.js/Tailwind)
**Deployed:** https://ynnso.github.io/GEMINI/ (current), https://ynnso.github.io/PRICEAPP/ (legacy)
**Source:** github.com/ynnso/GEMINI
**Design system:** Neumorphic — bg `#e6e9ef`/`#1e232a`, brand red `#e60000`/`#ff2a2a`, `rounded-[24px]` cards, locked shadow tokens

---

## 3. Architecture — How It's Actually Built

Zero-dependency SPA on Alpine.js. No virtual DOM, direct-link reactivity between `x-data` and the UI.

- **Routing:** `x-show`/`activeSheet` + `sheetParentMap` lookup table + `goBack()`. No `screenHistory` stack, no `window.history`. Back-nav via top-left chevron or left-edge swipe (24px trigger, 1:1 tracking, auto-pop above 0.4 distance or 0.5px/ms velocity).
- **Assets:** SVGs inline, for `currentColor` state inheritance.
- **Search:** Inline header expansion, full-width on open, predictive dropdown against categories + named products + Add-On items, deep-links to exact sheet with pre-set state.
- **No central pricing router.** Twelve separate `xRawTotal` getters, one per product category: `zillowRawTotal`, `ranchRawTotal`, `videoRawTotal`, `portRawTotal`, `addonRawTotal`, `aerialRawTotal`, `floorRawTotal`, `mpRawTotal`, `miniRawTotal`, `reshootRawTotal`, `exteriorRawTotal`, `airbnbRawTotal`. This is intentional — do not introduce a central router without discussing it first.
- **Cart:** `cartItems` array, populated only via `addConfiguredItemToCart(title, desc, rawPrice, iconName)`. **In-memory only — no persistence.** No `sessionStorage`, no `loadQuote()`/`saveQuote()`. Refresh clears the cart completely.
- **Tax:** Single global `includeTax` boolean + `taxRate` (0.0825), applied to subtotal at display time. Never stored per-item.
- **Sanitization:** Per-field functions (`sanitizeRanchInput()`, `sanitizeExteriorInput()`, etc.) — `parseInt` + clamp on blur/change. No universal `formatNumber()` or `resetPrice()`/`resetAll()`.

### Known gaps (real, open — not documentation errors)
- **Haptics:** `addConfiguredItemToCart()` calls `navigator.vibrate(40)` directly. No Haptics bridge object exists despite past planning references. Flag before touching.
- **No safe-area-inset usage found anywhere in the file**, despite past documentation claiming it shipped. On a notched device, the fixed header may sit flush under the status bar/notch with no padding. Needs verification and likely a real fix.
- **No copy-quote function** exists — "copy it out" language in older docs was aspirational, not built.

### Backdrop scale effect — REVERTED, do not reapply as-is
A previous attempt to scale the app container to 95% with rounded corners when a sheet opens caused the fixed bottom nav pill to become clipped/invisible. Root cause: `body { position: fixed; overflow: hidden }` combined with a `transform` on an ancestor container changes the containing block for `fixed`-position descendants — the nav pill's positioning shifted off the true viewport and got clipped by body's own overflow. If revisited, the nav pill (and header) must sit OUTSIDE the transformed container, not inside it.

---

## 4. The Math Contract — Verified Pricing Logic

**A. MLS "Smart-Cap"** — `evaluateCheapestBase()` + `priceMatrix`. Every SqFt tier has a 25-photo base; photos 26+ add $5/photo. Compares tier-plus-overage against every flat tier price, takes the lower. Verified: 2,500 SqFt / 35 Photos → $206.

**B. PORT "Modulus-10 Plateau"** — `portTierPrice(brandKey, q)`. Base covers images 1–2, +$20/ea for 3–9, flat +$150 at exactly 10, +$100/decade thereafter. Within each decade, +$20/ea for units 1–5, then flat for 6–10. Verified: BCD 14 → $379, BCD 18 → $399 (plateaued), AMF 22 → $539.

**C. Add-Ons** — `addonRawTotal`. Virtual Staging: $60/ea, $55/ea at 4+. ColorPop/Digital Twilight: base + $15/ea after first. Hourly: MLS $50/hr, PORT/Processing $100/hr.

**D. Matterport** — `mpRawTotal`. Under 6,000 sqft: flat lookup. 6,000+: `sqft × mpCustomRates[side][service]` (e.g. MLS Standard = 0.06/sqft). Verified: 3,500 sqft → $249, 7,000 sqft → $420.

**Do not modify any of the above without explicit instruction — this is the verified pricing contract.**

---

## 5. Layout & Viewport — Testing Standard

**Changed 2026-08-20** — SE was the original baseline but the field team carries recent phones, not SE. Designing small-first and patching bigger screens after caused real problems (dead space, centering hacks). Flipped the standard:

**Primary design target:** 393×852 (iPhone 16/17 standard). Screens should look intentionally designed and fully use the space here — not just "not broken."

**Stress-test floor:** iPhone SE, 375×667px. Must not scroll, clip, or break here — but no longer needs to look polished, just functional.

**Stress-test ceiling:** 440×956 (iPhone 16/17 Pro Max). Must not look stretched, sparse, or leave large unused space here.

**No-scroll rule:** app-wide by default at the 375×667 floor. Every screen (home, category sheets, product sheets) must fit and function with zero vertical scroll there. Exceptions (e.g. Cart with many items, Add-Ons grid overflow) are handled case-by-case when they actually occur — not assumed in advance.

### FAILED ATTEMPT 2026-08-20 — rolled back, read before touching this again
Tried to apply the 393×852 standard to Photos/Aerial/Video/360 Tour/Add-Ons in one long session, immediately after adopting it. Went through multiple different approaches in a row (fixed-size tiles + centering → content-sized sheets → CSS auto-fit columns → reverting to big PORT-Photos-style tiles) and **pushed each one to the live site without testing on Sonny's actual phone first**. Every round looked fine in the emulated browser sizes but was wrong on the real device — tiny tiles marooned in huge empty space, forced 3-column grids on screens that only had 3-4 items. Sonny had to catch it, get furious, and ask for a rollback three times before landing on a stable point.

**Everything from that session was reverted.** Live code is back to `add68d0` — Home screen overlap fix only. Photos, Aerial, Video, 360 Tour, and Add-Ons are still on the **original, untouched, SE-only 2-column design** and have never been verified against the 393×852 primary target.

**If this is attempted again:**
1. One screen only. Get it right, get it confirmed by Sonny on his actual phone, before touching a second screen.
2. Never push a layout change based on emulated-browser screenshots alone when the standard is calibrated to a real device. Ask Sonny to test on his phone before pushing the next one, not after.
3. Do not invent a new layout technique (centering hacks, auto-fit grids, column-count schemes) to solve a spacing problem without asking first. The existing PORT Photos 2-column tile pattern is the known-good reference — match it, don't reinvent it.
4. A little scroll at the SE floor is fine and already an accepted exception (see No-scroll rule above). Do not contort tile sizes or column counts trying to eliminate it.

**Fixed chrome (persistent, all screens):**
| Element | Height | Position | Z-index |
|---|---|---|---|
| Header | 76px | `fixed top-0` | z-[70] |
| Bottom nav pill | 64px + 8px offset = 72px footprint | `fixed bottom-2` | z-[60] |

Header vs. nav pill height difference (76px vs 64px) has no functional reason found — both hold similarly-sized buttons. Flagged as reclaimable space; needs sketch approval before changing (visual decision, not a bug fix).

**Sheet shell patterns — two currently in use, not yet reconciled:**
- **Category pickers** (Photos, Aerial, Video, Add-Ons, 360 Tour category screens): fixed `h-[82vh]` + `pb-[120px]`
- **Product/detail sheets** (Full Shoot, Reshoot, PORT, Matterport, etc.): flexible `max-h-[82vh]` + `pb-[100px]`

**Known spacing issues, not yet fixed:**
- `floorplan` and `matterport` sheets share an unusual `min-h-[60vh]` floor — may force white space on sheets with less content than that floor assumes. Needs visual audit.
- **CTA button has no sticky/fixed positioning** — it's the last flex child in each sheet, so its vertical screen position varies by how much content precedes it (confirmed via screenshots — Floor Plan's CTA sits higher than Full Shoot's). User has requested evaluating a fixed CTA position just above the bottom nav for consistency and thumb-reachability — not yet implemented, needs a design decision first.
- Sheet-by-sheet spacing audit was in progress when environment was switched to Claude Code specifically to get real visual verification. **Do this audit properly now, with real screenshots, before making further layout changes.**

---

## 6. Golden Dataset — 16 Verified Test Cases

Re-run this via Node before shipping any pricing-adjacent change. All 16 rows confirmed exact against live functions as of last check.

```csv
Test_ID,Section,Input_A_Key,Input_A_Value,Input_B_Key,Input_B_Value,Expected_Output,Logic_Notes
MLS-01,MLS Residential,SqFt,2000-2999,Qty,25,166.00,Standard Base Tier.
MLS-02,MLS Residential,SqFt,2000-2999,Qty,34,206.00,"Smart-Cap Trigger: (166 + [9 x 5] = 211), but capped by 36-photo price (206)."
MLS-03,MLS Residential,SqFt,0-1999,Qty,60,274.00,$224 (50-photo base) + (10 x 5) overage.
MLS-04,MLS Residential,SqFt,10000+,Qty,25,399.00,Maximum SqFt tier base.
PRT-01,PORT Portfolio,Brand,BCD,Qty,2,149.00,Brand Base (Minimum).
PRT-02,PORT Portfolio,Brand,BCD,Qty,9,289.00,$149 + (7 x 20) per image increment.
PRT-03,PORT Portfolio,Brand,BCD,Qty,10,299.00,Decade Jump: Base + $150 flat.
PRT-04,PORT Portfolio,Brand,BCD,Qty,14,379.00,$299 (Decade 1) + (4 x 20).
PRT-05,PORT Portfolio,Brand,BCD,Qty,18,399.00,Plateau Trigger: Images 15-20 in this decade are flat.
PRT-06,PORT Portfolio,Brand,AMF,Qty,22,539.00,$249 (AMF Base) + $250 (Decade 2 Start) + (2 x 20).
ADD-01,Special Services,Service,Virtual Staging,Detail,3 Images,180.00,Standard rate ($60/ea).
ADD-02,Special Services,Service,Virtual Staging,Detail,5 Images,275.00,Volume Discount: Applied at 4+ images ($55/ea).
ADD-03,Special Services,Service,ColorPop,Detail,4 Images,84.00,$39 (Base/1st) + (3 x 15).
MP-01,Matterport (MLS),SqFt,3500,Type,MLS,249.00,Flat tier lookup.
MP-02,Matterport (MLS),SqFt,7000,Type,MLS,420.00,"Custom Calc: bucket triggers at SqFt 6,000 or above, then $7,000 x 0.06 (Standard rate)."
FIN-01,Tax & Rounding,Subtotal,139.00,Tax Setting,ON,150.47,$139 x 1.0825 = 150.4675 (Round to 2nd decimal).
```

---

## 7. Immediate First Task (Do This Before Anything Else)

Confirm real browser-based visual testing actually works in this environment before doing any feature work:

1. Set up Playwright (or equivalent) if not already available.
2. Load https://ynnso.github.io/GEMINI/ at 375×667 viewport.
3. Capture and show an actual screenshot.
4. Only once that's confirmed working, proceed to the sheet-by-sheet spacing audit (Section 5) using real rendered screenshots — not code-only guesses.

**Do not report any layout/visual task as complete without a real screenshot backing it up. This is the entire reason this project moved from claude.ai chat to Claude Code.**

---

## 8. Git Workflow — Commit & Push Policy

**Committing locally:** low-risk, do it automatically after any approved change, with a real descriptive message (not "Update index.html").

**Pushing to GitHub — conditional, not blanket-manual:**
- **Push without asking** once a change has been through the FULL verification loop for that change: real rendered screenshots confirming the visual result, a functional test where relevant (e.g. cart-add still works), Golden Dataset spot-check if pricing-adjacent, and console clean. If all of that already happened and passed, the confidence is earned — push it.
- **Hold and ask first** if any of the following is true: verification is partial or still in progress, multiple files/sheets are being edited in one pass and not all have been individually confirmed yet, or something unexpected was found mid-change (a bug, a mismatch, a surprise) that hasn't been fully resolved and re-verified.
- Rationale: a bad local commit costs nothing — it's undo-able and never left the machine. A bad push updates the live, deployed site (`ynnso.github.io/GEMINI`) within minutes, with no review step in between, and is used by Photogs in the field. The asymmetry is in the cost of being wrong, not the odds of being wrong — so the bar for "push without asking" is "already fully verified," not "seems likely fine."
- This session's real bugs (wrong Video sheet edited, CTA overflowing off-screen, CTA hidden behind nav) were all caught specifically because verification happened before anything was pushed — that check should not be removed, just gated correctly so it doesn't apply to already-verified work.
- **Added 2026-08-20 after a bad session:** emulated-browser screenshots at a given width/height are NOT equivalent to testing on Sonny's actual phone, especially when a layout change is calibrated to real device behavior (see Section 5's failed-attempt note). When a change targets "how it looks on the real phone," push one small change, ask Sonny to check it on his phone, and wait for confirmation before pushing the next one — do not chain several unverified layout changes together.

---

## 9. Session Changelog — 2026-08-21 (Top Nav, Search, Home Tile Reorder)

**Top nav overhaul:**
- Morphing hamburger trigger (3-bar ↔ X) replaces the old header icons. Opens a right-side, 33%-width flyout drawer with icon-only nav: Favorites, Cart, Language toggle, Theme toggle. New state: `drawerOpen`.
- Drawer sits at `z-[71]`, just above the header's `z-[70]`, so it renders correctly. The trigger itself lives as an independent `z-[80]` fixed element outside `<header>` so it's never covered by the drawer or anything else.
- Real Tailwind CDN gotcha, cost real debugging time: bare `duration-NNNms` classes outside Tailwind's default scale (75/100/150/200/300/500/700/1000) produce **zero CSS** and silently fall back to the built-in 150ms — use bracket syntax `duration-[NNNms]` for any custom duration.

**Search:**
- Abbreviation/acronym search added: `syn: [...]` tags on `productSearchIndex`/`addonSearchIndex` entries, a `categorySynonyms` map, and an exact-abbreviation short-circuit in the `searchResults` getter. Typing a known abbreviation (AP, BCD, etc.) returns only exact matches, bypassing fuzzy search.
- **Hard rule:** MLS and PORT must never collapse into one generic search result — different products, different pricing. Product labels always lead with the side (`MLS Matterport`, not `Matterport MLS`).
- Search bar restyled: taller (`h-[55px]`, +25%), bigger font (`text-[20px]`, +40%), red border only when focused (no fill).
- Predictive dropdown rebuilt as a "top sheet": `fixed`, full app width, slides down, with a dim+blur backdrop scrim behind it — matches the existing bottom-sheet scrim pattern instead of a small anchored popover.
- Result rows: bigger font, MLS/PORT prefix rendered heavier than the rest of the name, no subtext line, "Popular" label matches row size/case.
- Real bug found and fixed: the compact search icon button could stay visible after opening search — an `x-bind:style` effect was silently clobbering `x-show`'s `display:none` on the same element. Fixed by moving that styling to a Tailwind arbitrary class instead of `:style`. **General lesson:** don't mix `:style` and `x-show` on the same element in this codebase.

**Home screen custom tile order:**
- Long-press a tile → edit mode (tiles jiggle, "Done" replaces the hamburger trigger in its exact header slot, no separate instruction banner).
- Drag to reorder. Order is saved permanently to `localStorage` under `homeTileOrder`. **This is the one deliberate exception to the "session-only, no persistence" rule** — it's a device layout preference, not quote data, so it's meant to survive closing the app.
- Bottom nav pill order is driven by the same array, so it always matches the grid.
- **Do not use SortableJS for this** (Fave 5 still uses it fine — that's a simple vertical list, not a 2-column grid with a jiggle animation running). Five real, confirmed rounds of SortableJS breakage on the real device before abandoning it: it was dragging Alpine's own `<template x-for>` marker instead of the tile (fixed with `draggable: 'button'`, still not enough); Alpine's reactivity and SortableJS's direct DOM manipulation were fighting over the same nodes mid-drag (icons scrambling after drop); and ultimately no reliable visual feedback on the real phone despite code that checked out correctly in an isolated browser test every time.
- Rebuilt by hand instead, matching the pointer-based drag technique this app already uses elsewhere (cart/Fave5 sheets): `homeDragKey` + `homeDragX`/`homeDragY` state, one Alpine-owned floating tile that tracks the pointer directly, a manual FLIP animation for displaced tiles, and target-slot detection from pointer-position math against the grid's own geometry — never from measuring DOM elements that are themselves mid-animation.
- Reorder is previewed live in a separate `homeTileDisplayOrder` array while dragging; the authoritative `homeTileOrder` (and the save to `localStorage`) only updates once, at the exact moment of release.
- Swap timing: a fixed-delay debounce (tried 130ms) never felt right against a real finger — too eager or too laggy depending on drag speed. Replaced with geometric hysteresis instead: a swap only commits when the pointer is within a slot's center zone, not merely past its edge.
- **Real iOS-only landmine, easy to miss:** `-webkit-user-drag` was never set anywhere in this app. iOS Safari can hijack a long-press-drag with its own native magnifier loupe and drag-and-drop indicator, rendered on top of any custom drag code, especially on `<svg>` content. Fixed with `-webkit-user-drag: none` globally plus `pointer-events: none` on all `svg`/`img` (clicks still reach the parent button fine). If a future custom drag/long-press feature "looks right in code but wrong on the phone," check this first.
- **Still open as of this update:** a "ghosting" artifact still reported on the real device. Bubble and text-highlight artifacts from the iOS native-gesture issue above are confirmed fixed; ghosting was not. Next session should start here — ask for a real screenshot or screen recording from Sonny before making further changes blind, per the Verification rule at the top of this file.

**Up next:** transitions and bottom sheet behavior, app-wide.

---

## 10. Session Changelog — 2026-08-21 (Motion Polish, Cart Badge, In-Sheet Favorites)

**Sheet open/close, app-wide — the single biggest fix of this pass:**
- Every sheet (20 of them) previously animated via Tailwind's class-based `x-transition` (`translate-y-full` → `translate-y-0`). Tailwind's CDN JIT does not reliably compile `translate-y-full`/`translate-y-0` in time for Alpine to use them on open — confirmed via `getComputedStyle` showing `transform: none`. Sheets were opening with **zero animation**.
- Fixed by abandoning class-based transitions for the transform itself: each sheet now gets `x-ref="dragSheet"`, and `openSheet(sheetName, direction)` does a direct DOM write (`el.style.transform`, `el.style.transition`) inside a `requestAnimationFrame` poll-loop that waits for the ref to exist before animating. This is now the standard pattern for any new sheet — **do not add a new sheet using only class-based `x-transition:enter-start/end` for the slide, it will not animate reliably.**
- Same root cause, same fix applied separately to Fave 5 (`openFave5Sheet()`) and the search dropdown top-sheet, since both used their own flags (`showFave5Sheet`, `searchOpen`) instead of `activeSheet` and so never went through `openSheet()`.
- Rubber-band drag resistance (iOS UIScrollView formula, `c=0.55`), live backdrop dim/blur tied to drag distance, momentum-based dismiss (continuing off-screen at a duration inversely tied to release velocity), and a spring/overshoot curve (`cubic-bezier(0.34, 1.56, 0.64, 1)`, 0.63s) are now standard across all sheets.
- Staggered "domino" entrance for grid/list content inside sheets: CSS-only (`@keyframes` + `nth-child` delays), not JS-timed — avoids both the Tailwind JIT risk above and jank from recalculating timing in JS. Class `.sheet-stagger-content`, direction-aware via `navDirection` (`nav-back` variant for backward nav).

**Search bar + dropdown:**
- Search bar has a spring-expand open animation, done via the same direct-DOM-write + `x-ref` technique (not class transitions) for the same JIT-reliability reason above.
- **Real bug, worth remembering:** the spring transform and a separate Alpine `:style` binding (border color on focus) were on the same element — Alpine's reactive re-render from the `:style` binding was wiping out the manually-written transform each time focus state changed. Fixed by splitting into two elements: an outer one for the animation only, an inner one for the reactive border style. **General rule for this codebase: never combine a direct-DOM-write animation with a separate reactive `:style`/`x-show` on the same element** — split them.
- Predictive dropdown is now a full top-sheet: edge-to-edge width matching bottom sheets (`left-0 right-0 max-w-md mx-auto`, was inset), same `rounded-b-[28px]` corner radius as bottom sheets, drag handle at the **bottom** (flick up to dismiss — a handle at the top would sit under the header, not reachable), full rubber-band/momentum/backdrop treatment mirroring bottom sheets.

**Home screen tile press:**
- Long-press tiles now get a liquid-fill press effect (same family as the drawer icon buttons): a blurred, irregularly-shaped `::before` blob scales from the tile's icon well outward, asymmetric timing (slow ~0.85s fill on press, fast ~0.35s release) so a full tap doesn't leave a lingering drain animation. Went through several iterations before landing here — flat color swap and a perfect-circle blob both read as "geometric zoom," not liquid; user feedback drove the blob shape and timing.

**Add-to-cart flow — replaced entirely, twice:**
- First pass: replaced the old forced `closeSheet()` → `openSheet('cart')` navigation (which yanked the user out of the sheet they were configuring) with a toast. The toast itself turned out cramped — all-caps label, a full item description that could clip, and its red "View Cart" button visually bled into the CTA button directly behind it even after a width-matching fix.
- **Second pass, current state:** toast removed entirely. Cart is now a persistent count badge in the header, next to the hamburger trigger (`right-20`, independent fixed element, same pattern as the hamburger itself). Hidden completely when the cart is empty — no icon at all until there's 1+ item. Tapping it opens the real cart sheet. Confirmation on add is now just the CTA's own existing success checkmark plus a quick scale-bump (`cart-badge-bump` keyframe, 0.42s) on the badge itself — no forced navigation either way. The redundant cart entry was removed from the hamburger drawer since the header badge replaces it.
- New state/methods: `cartBadgeBump`, `cartBadgeBumpTimer`, `bumpCartBadge()`. Uses `setTimeout(0)`, not `requestAnimationFrame`, to restart the CSS animation on back-to-back adds — `requestAnimationFrame` ties to frame compositing and can stall if the tab isn't actively painting.

**In-sheet favorite heart — new pattern, rolled out to all 13 favoritable sheets:**
- Favoriting used to only be reachable from the hamburger drawer's heart icon, which also forced navigation into the Fave 5 sheet on every save. Added a second, simpler path: a heart icon directly on each product sheet (`full`, `mini`, `reshoot`, `exterior`, `ranch`, `airbnb`, `zillow`, `matterport`, `videoBuzz`/`videoHD`/`videoFullHD`, `floorplan`, `aerialProduct`, `port`, `addonProduct` — the same list as `faveProductSheets`).
- New method `toggleSheetFave()`: point-blank save/unsave, no confirm-tap-twice-to-remove dance, no forced trip to Fave 5. The drawer's original `toggleFaveHeart()` (confirm-remove flow + auto-navigate to Fave 5) is untouched and still used by the drawer.
- Layout: the sheet's close X moved from the right side to the **left**, freeing the right side for the heart. Both buttons are 72px tap targets anchored as **direct children of the sheet element itself** (not nested inside the padded grab-handle row) — `position:absolute` children ignore their own containing block's padding but NOT an ancestor's, and the grab-handle row's normal-flow position was already inset by the sheet's `px-5`/`pt-3`, which was silently pushing the buttons off the true corner. Moving them out fixed both "flush to the corner" and, combined with `items-start` + a small per-sheet `pt-[Npx]`, "level with the drag handle."
- Icon size doubled (20px → 40px) per request, but the SVG `stroke-width` was NOT scaled down at first — same value in fixed viewBox units at 2x the rendered size reads as 2x the line thickness, which made the icon look bold/dark even at the correct grey. Halved to 1.25 (close) / 1.1 (heart) to restore the original visual weight. **If an icon in this app is ever resized, check whether its stroke-width needs to scale inversely — it's not automatic.**
- Color settled on the sheet's own body-text grey (`text-[#64748b]`/`text-[#94a3b8]`, same token as labels like "Base X Photos") for the unsaved/close state, NOT the darker functional-icon grey used by the header's back-chevron/hamburger (`text-[#1e2530]`/`text-[#f1f5f9]`) — the darker one was tried and explicitly rejected as "too dark, not cohesive with the sheet." Heart fills red (`#e60000`/`#ff2a2a`) only once saved.
- Category-picker sheets (`tourCategory`, `floorCategory`, `video`, `addon`, `aerial`) and `cart` get the same flush/level/grey/stroke-weight treatment on their close button, but no heart — there's nothing to favorite there. Fave 5's own sheet keeps its original close X untouched, by explicit instruction.
- Per-sheet `pt` offset for handle-alignment is NOT one constant — it depends on that sheet's own wrapper/row padding combo, measured empirically per sheet rather than assumed: `pt-[7px]` for sheets with a `pt-3` wrapper + `py-3` handle row (most product sheets, cart, tourCategory), `pt-[3px]` for `pt-2` wrapper + `py-3` row (`floorplan`, `matterport`, `port`), `pt-[1px]` for `pt-3`-on-self + `py-1.5` row (the category pickers). If a sheet's padding changes, this offset needs re-measuring, not copy-pasting from another sheet.
- Real bug caught mid-rollout: on 5 sheets (`full`, `exterior`, `mini`, `airbnb`, `ranch`) a find-replace boundary mismatch left the OLD close-button SVG un-replaced, nested inside the NEW heart button's `<svg>` — rendered as a visibly broken/crossed icon. Caught by a real screenshot (not just code review), fixed, then re-verified all 13 sheets via `querySelectorAll('svg').length === 1` on every heart button before calling it done.
