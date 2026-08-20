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

**Working file:** `PriceAppV10.html` (single-file HTML/Alpine.js/Tailwind)
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
