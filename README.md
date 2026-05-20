# claude-code-starter

A one-command setup that configures Claude Code for the way you actually work.

```bash
bash setup.sh
```

Takes 60 seconds. Asks 6 questions. Outputs a fully configured `.claude/` folder.

---

## What this is

Claude Code works out of the box, but it works much better when it knows your stack, your workflow, and how you like to collaborate. This repo gives it that context — without requiring you to read the docs first.

Two paths:

- **Engineer** — stack-aware CLAUDE.md, skills for PRs / reviews / deploys, type-check hooks, a reviewer subagent
- **Founder / Ops** — voice-aware CLAUDE.md, skills for memos / SOPs / meeting prep, prompt patterns for non-technical work

---

## What gets generated

### Everyone
| File | What it does |
|------|-------------|
| `CLAUDE.md` | Project context Claude reads at the start of every session |
| `PROMPTS.md` | Curated prompt patterns for your path |

### Engineer path
| File | What it does |
|------|-------------|
| `.claude/skills/pr-description.md` | Writes PR descriptions in a consistent format |
| `.claude/skills/code-review.md` | Review checklist before merging |
| `.claude/skills/new-component.md` | Stack-aware module / component scaffold |
| `.claude/skills/deploy-checklist.md` | Pre/post deploy checklist (manual or CI/CD) |
| `.claude/hooks/post-tool-use.sh` | Runs tsc / mypy after file edits |
| `.claude/hooks/session-start.sh` | Prints branch + git status at session start |
| `.claude/agents/reviewer.md` | Second Claude that reviews the main agent's work |
| `.claude/settings.json` | Wires hooks up, adds sane default permissions |

### Founder / Ops path
| File | What it does |
|------|-------------|
| `.claude/skills/weekly-update.md` | Status update in your format and voice |
| `.claude/skills/decision-memo.md` | Structured decision doc |
| `.claude/skills/sop-writer.md` | Turns a brain dump into a clean SOP |
| `.claude/skills/meeting-brief.md` | Prep doc before any important meeting |

---

## The 5 levels, briefly

1. **L1 — Raw prompting.** Just you and Claude in a conversation. See `PROMPTS.md`.
2. **L2 — CLAUDE.md.** Project context that Claude reads automatically. See `CLAUDE.md`.
3. **L3 — Skills.** Reusable `/skill` commands. See `.claude/skills/`.
4. **L4 — Hooks.** Automated triggers on tool use, session start, etc. See `.claude/hooks/`.
5. **L5 — Agents.** Subagents with their own instructions. See `.claude/agents/`.

You don't need to understand all five to get value. Start with L1 and L2. The rest is there when you need it.

---

## What to change first

**Engineers:**
1. Open `CLAUDE.md` and fill in the Commands section (`build`, `test`, `lint`)
2. Add your project description
3. Run `/pr-description` on your next PR and see if the format fits

**Founders / Ops:**
1. Open `CLAUDE.md` and fill in "Who I Am"
2. Paste 2-3 sentences of your writing in "My writing style"
3. Try `/decision-memo` on a real decision you're working through

---

## Running setup again

Safe to re-run. It will overwrite existing files. Back up any customisations first.

```bash
bash setup.sh
```
