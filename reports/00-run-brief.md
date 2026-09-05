# Run brief — holdings deep dive

**Status:** queued, not yet run. Written 2026-09-04 (evening ET) by the
session that built this system, for the fresh session that will execute it.
That conversation's context does not survive the restart — this file is the
handoff.

**Read `CLAUDE.md` first.** It holds rule zero, the numbers rules, the
no-recommendations policy, and the account-classification rules. This file
is the run-specific scope layered on top of it, not a replacement for it.

---

## ⚠️ Every figure in this file is stale. Re-fetch everything.

The numbers below are recorded so you can follow the *reasoning* behind the
scope decisions — which tickers are worth researching, and why some were
cut. They are **not** values to report.

CLAUDE.md's numbers rule is absolute and applies to this run: every price,
position size, cost basis, and P&L figure in the output comes from a tool
call made **during that run**, with its own timestamp. Do not copy a single
number out of this file into the report.

Also re-verify the triage itself. It was done at the 2026-09-04 close. If
the restart happens after settlement, the three expired contracts may no
longer appear in `get_option_positions` at all, and the position set may
have changed for other reasons. Confirm the current position list before
acting on the name lists below.

---

## The run

Five agents, all of them — this is the case that justifies the full roster.

**Sequencing:** `holdings` runs and finishes **first**, then its position
list is passed to `filings`, `calendar`, and `news` so they work from real
tickers instead of guessing. `red-team` runs **last**, after the other four
have reported.

### holdings

All four accounts. Every position, **including the three option contracts
that expired on 2026-09-04** (JPM, FCX, SPCX 09-04) if they still appear.

The expirations are deliberately in scope — the user wants them visible.
**Do not clean them out of the report as noise.**

Report cost basis, realized P&L, and live unrealized P&L per position.
Taxable and Roth reported separately, never combined (see Account rules
below).

### filings

**Only these five: CRDO, INTC, IREN, MMED, PBR.** See triage below for why
the others were cut.

Capped, deliberately — this is the most expensive agent in the run:
- **MD&A and risk factors only.** Not whole documents, not every section.
- Most recent filing diffed against the prior comparable one.
- Report what changed. **Skip anything unchanged** — but say that a section
  was checked and found unchanged, rather than silently omitting it.

### calendar

Same five names. Every earnings date in the **next 60 days**.

### news

Same five names. **~3 articles each**, last 30 days. Every claim carries a
source and a date, or it is explicitly flagged unsourced.

### red-team

Waits for the other four. **Starts from their output.** Reaches for a tool
only to verify or falsify something one of them actually claimed — no
parallel investigation, no independent research thread. See
`.claude/agents/red-team.md`, which is written to constrain exactly this.

Breaking conditions only. Never directives. Gets the last word in the
report body.

---

## Position triage (2026-09-04 close — re-verify before relying on it)

Why the five names, and not everything held:

**Cut — expired 2026-09-04.** Three option positions expired the day this
brief was written, all marked ~$0.01 against $0.00 bids, all carrying
non-zero `pending_expiration_quantity`:

- JPM 09-04
- FCX 09-04
- SPCX 09-04

Filings and earnings research against dead contracts is wasted spend. They
remain **fully in scope for `holdings`** — just not for filings/calendar/news.

**Cut — derivative products without their own filings.**

- **METU** appears to be a leveraged single-stock ETP tracking META, not an
  operating company. No 10-K of its own, no earnings date.
- **SPCX 09-18** — same question depending on its structure. Verify before
  spending anything on it; if it's an ETP, cut it from filings/calendar for
  the same reason.

These two are the reason the filings list isn't just "everything in the
account." An agent handed the raw position list would burn tokens
discovering that a 2x ETP has no MD&A.

**In scope for filings / calendar / news — the five that support the work:**

| Ticker | Why it's in |
|---|---|
| CRDO | Largest single equity position by value |
| INTC | Option position on a real operating company |
| IREN | Option position, operating company |
| MMED | Equity position, operating company |
| PBR | Equity position, operating company |

By position value at the time of triage, CRDO and INTC were the two largest
of these — worth weighting effort toward if the caps bind.

---

## Account rules (full version in CLAUDE.md — this is the summary)

Call `get_accounts` fresh. Do not hardcode four accounts, or any account
number, from this file. If a fifth appears, it gets labeled **unknown and
flagged**, never silently dropped.

- **Position report: all four accounts appear**, each labeled with its
  classification (taxable self-directed / taxable agentic / Roth IRA /
  managed).
- **Thesis work: taxable accounts only.** The managed "Smart Income"
  account appears in the position report for completeness but is **excluded
  from the thesis-driven research** — the user doesn't pick its holdings, so
  there's no decision for an agent to inform.
- **Tax lots and realized P&L: taxable accounts only.**
- **Roth is never merged into a combined realized-P&L number.** Different
  tax treatment makes a blended figure misleading, not merely imprecise.
  Totals go out as **separate taxable and Roth lines**.

At the time of triage the Roth was empty ($0.00 across the board) and the
managed account held only cash. Both still appear in the position report.
Re-verify; do not assume they're still empty.

---

## Output

Write to `reports/YYYY-MM-DD-holdings-deep-dive.md`, dated the day the run
actually happens.

Standard format from CLAUDE.md, with **one deliberate change**:

> **The Open Questions section goes at the TOP of the report, not the
> bottom.** What the team could not resolve is the part the user most wants
> to see. This is an explicit instruction and overrides the ordering in
> CLAUDE.md's Output section.

Report structure:

1. **Open Questions** — what the team couldn't resolve: tool failures,
   missing data, unreconciled disagreements between agents
2. What each agent found, with timestamps on every figure
3. The red-team case (last in the body — it gets the final word)

**No recommendations. No price targets.** Applies to every agent including
red-team, whose job is falsifiable breaking conditions ("this fails if X"),
never directives ("so do Y").

---

## Cost

Estimated **~300–550k tokens** total across five teammates plus
orchestration, midpoint ~400k. The user has approved the run and asked to
**target the low end, near 300k**.

`filings` and `news` are the entire variance. The caps above — MD&A and risk
factors only, ~3 articles per name — are what hold the total near 300k
rather than 400k. **Both caps are approved and should be enforced, not
treated as guidance.**

Rough per-agent expectation: holdings 40–70k, filings 80–200k (capped:
target the low end), calendar 25–40k, news 60–130k (capped: target the low
end), red-team 45–80k, orchestration 30–60k.

---

## Note on why this file exists

The five agents (`holdings`, `filings`, `calendar`, `news`, `red-team`) were
written to `.claude/agents/` in the previous session, but agent definitions
load at session start — so that session could not spawn them. It could have
run the deep dive with `general-purpose` agents seeded with the same
prompts, but that would have made the per-agent read-only tool scoping
advisory prompt text instead of enforced config. The user chose to restart
rather than run the first real deep dive on a degraded version.

So: **this run should be executed with the real file-based agents.** If
`holdings` still isn't a spawnable agent type after the restart, stop and
say so rather than falling back to `general-purpose` — the fallback is the
specific thing this restart was meant to avoid.
