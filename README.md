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

## What's in your `.claude/` folder

Every primitive has a job. Here's what each one does and when to use it.

| Primitive | Loads | Use for |
|-----------|-------|---------|
| `CLAUDE.md` | Always, every session | Project context, rules, commands — things Claude needs to know by default |
| `CLAUDE.local.md` | Always (gitignored) | Personal overrides, shortcuts, reminders — never committed |
| `.claude/rules/` | When file paths match `globs:` | Language or domain conventions that should only apply to specific files |
| `.claude/skills/` | Described at startup; full content loads on invocation | Reusable workflows: `/pr-description`, `/code-review`, etc. |
| `.claude/hooks/` | Triggered by events, runs outside the model loop | Zero context cost automation: type-check after edit, print context at session start |
| `.claude/agents/` | Spawned explicitly | Subagents that work independently and report back — use for isolation, not coordination |
| `.claude/output-styles/` | Referenced manually | Custom system-prompt sections for response format control |
| `.mcp.json` | At startup (version controlled) | Team-shared MCP server config — tools everyone on the project should have |
| `.claude/settings.json` | Always | Permissions, hook wiring, model defaults — committed and shared |
| `.claude/settings.local.json` | Always (gitignored) | Personal permission overrides — separate from `CLAUDE.local.md`, which is for instructions |

**`CLAUDE.local.md` vs `settings.local.json`:** `CLAUDE.local.md` is for instructions ("when I ask for a draft, start with bullet points"). `settings.local.json` is for settings (permissions you want locally but not on CI). They're different files for different purposes.

---

## What gets generated

### Everyone
| File | What it does |
|------|-------------|
| `CLAUDE.md` | Project context Claude reads every session |
| `CLAUDE.local.md` + `CLAUDE.local.md.template` | Personal instructions (gitignored) |
| `PROMPTS.md` | Curated prompt patterns for your path |
| `.claude/rules/typescript.md` | TS conventions (path-scoped: only loads for `.ts`/`.tsx` files) |
| `.claude/rules/python.md` | Python conventions (path-scoped: only loads for `.py` files) |
| `.claude/output-styles/concise.md` | Short-response system prompt section |

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

## Combining features

These four combinations do more together than separately:

**CLAUDE.md + Skills** — CLAUDE.md sets the context that's always true; skills carry the workflow details that only load when invoked. Keep CLAUDE.md lean by moving anything reference-like into a skill.

**Skills + MCP** — A skill can call MCP tools. Write a skill that queries your database, hits your internal API, or reads from Notion — the skill provides the workflow, the MCP server provides the access.

**Hook + MCP** — A hook can trigger an MCP tool call on every file edit. Useful for linting, schema validation, or syncing state without any context cost to the conversation.

**Writer / Reviewer (two sessions)** — Session A writes. Session B reviews with no shared context. Claude won't be biased toward code it just wrote. Brief Session B explicitly — it has nothing from Session A.

---

## The 5 levels, briefly

1. **L1 — Raw prompting.** Just you and Claude in a conversation. See `PROMPTS.md`.
2. **L2 — CLAUDE.md.** Project context that Claude reads automatically. See `CLAUDE.md`.
3. **L3 — Skills.** Reusable `/skill` commands. See `.claude/skills/`.
4. **L4 — Hooks.** Automated triggers on tool use, session start, etc. See `.claude/hooks/`.
5. **L5 — Agents.** Subagents with their own instructions. See `.claude/agents/`.

You don't need all five to get value. Start with L1 and L2. Add the rest when you have a specific problem they solve.

---

## What to change first

**Engineers:**
1. Open `CLAUDE.md` — fill in the Commands section (`build`, `test`, `lint`) and the project description
2. Open `CLAUDE.local.md` — add your personal shortcuts and reminders
3. Run `/pr-description` on your next PR and adjust the format if it doesn't fit

**Founders / Ops:**
1. Open `CLAUDE.md` — fill in "Who I Am" and paste 2-3 sentences of your writing in "My writing style"
2. Open `CLAUDE.local.md` — add your personal preferences and anything the team file shouldn't contain
3. Try `/decision-memo` on a real decision you're working through — see if the format fits

---

## Running setup again

Safe to re-run. It will overwrite generated files. Back up any customisations first.

```bash
bash setup.sh
```
