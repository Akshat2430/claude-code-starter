#!/usr/bin/env bash
set -e

# ── helpers ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
say()  { echo -e "${BLUE}→${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }

echo ""
echo -e "${BOLD}claude-code-starter${NC}"
echo "────────────────────"
echo ""

# ── shared questions ──────────────────────────────────────────────────────────
read -p "  Your name or company name: " NAME
echo ""
echo "  Solo or team?"
echo "  1) Solo   2) Team"
read -p "  [1/2]: " _team
[[ "$_team" == "2" ]] && TEAM="team" || TEAM="solo"

echo ""
echo "  Engineer or Founder / Ops?"
echo "  1) Engineer   2) Founder / Ops"
read -p "  [1/2]: " _role
[[ "$_role" == "2" ]] && ROLE="founder" || ROLE="engineer"

DATE=$(date +%Y-%m-%d)

# ── branch questions ──────────────────────────────────────────────────────────
if [[ "$ROLE" == "engineer" ]]; then

  echo ""
  echo "  Stack?"
  echo "  1) Node / TypeScript   2) Python   3) Other"
  read -p "  [1/2/3]: " _stack
  case "$_stack" in
    2) STACK="Python" ;;
    3) read -p "  Describe your stack: " STACK ;;
    *) STACK="Node / TypeScript" ;;
  esac

  echo ""
  echo "  CI pipeline?"
  echo "  1) Yes   2) No"
  read -p "  [1/2]: " _ci
  [[ "$_ci" == "1" ]] && CI="yes" || CI="no"

  echo ""
  echo "  Deploy process?"
  echo "  1) Manual   2) Automated (CI/CD)"
  read -p "  [1/2]: " _deploy
  [[ "$_deploy" == "2" ]] && DEPLOY="automated" || DEPLOY="manual"

else

  echo ""
  echo "  Primary output?"
  echo "  1) Decisions & memos   2) Content & comms   3) Ops & SOPs"
  read -p "  [1/2/3]: " _output
  case "$_output" in
    2) OUTPUT="content & comms" ;;
    3) OUTPUT="ops & SOPs" ;;
    *) OUTPUT="decisions & memos" ;;
  esac

  echo ""
  echo "  Do you work with a team on Claude?"
  echo "  1) Yes   2) No, just me"
  read -p "  [1/2]: " _collab
  [[ "$_collab" == "1" ]] && COLLAB="team" || COLLAB="personal"

  echo ""
  echo "  Tools you live in?"
  echo "  1) Notion   2) Google Docs   3) Email / plain text   4) Other"
  read -p "  [1/2/3/4]: " _tools
  case "$_tools" in
    1) TOOLS="Notion" ;;
    2) TOOLS="Google Docs" ;;
    3) TOOLS="email / plain text" ;;
    *) read -p "  Which tools: " TOOLS ;;
  esac

fi

echo ""
say "Generating your .claude/ folder..."
echo ""

mkdir -p .claude/skills .claude/hooks .claude/agents

# ══════════════════════════════════════════════════════════════════════════════
# ENGINEER PATH
# ══════════════════════════════════════════════════════════════════════════════
if [[ "$ROLE" == "engineer" ]]; then

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────
cat > CLAUDE.md << EOF
# CLAUDE.md — ${NAME}
> Stack: ${STACK} | ${TEAM} | Updated: ${DATE}

## Project
<!-- What this does, who it's for, what it doesn't do. Fill this in. -->

## Stack
- Runtime: ${STACK}
- Test: <!-- fill in: jest / pytest / vitest / etc -->
- Lint: <!-- fill in: eslint / ruff / etc -->

## Commands
<!-- Fill these in. Claude uses them to run, test, and lint your code. -->
- Build: \`\`
- Test:  \`\`
- Lint:  \`\`

## Rules
- No comments unless the WHY is non-obvious
- Prefer editing existing files to creating new ones
- No backwards-compat hacks for removed code
- Don't add error handling for scenarios that can't happen
- Don't add features beyond what the task requires
- Three similar lines is better than a premature abstraction

## Commit style
- Imperative mood: "add X", "fix Y", "remove Z"
- No type prefixes unless your tooling requires them

## What to change first
1. Fill in the Commands section above
2. Add your project description
3. Remove any rules that don't apply
EOF
ok "CLAUDE.md"

# ── skills/pr-description.md ──────────────────────────────────────────────────
cat > .claude/skills/pr-description.md << 'EOF'
# Skill: PR Description

Write a pull request description for the current branch.

## Steps
1. Run `git log main..HEAD --oneline` to see commits
2. Run `git diff main..HEAD --stat` to see files changed
3. Write a description using the format below

## Format

### What
<!-- 2-3 bullets on what changed — code changes, not outcomes -->

### Why
<!-- 1-2 sentences on the motivation. Link to issue if there is one. -->

### Test plan
- [ ] <!-- what to verify manually -->
- [ ] <!-- edge cases -->

### Notes
<!-- Migrations, feature flags, breaking changes. Remove section if empty. -->

## Rules
- If it's a fix, say what was broken and why
- Keep "What" to actual changes, not implementation details
- No bullet for "updated tests" — that's implied
EOF
ok ".claude/skills/pr-description.md"

# ── skills/code-review.md ─────────────────────────────────────────────────────
cat > .claude/skills/code-review.md << 'EOF'
# Skill: Code Review

Review the staged diff or a specified file before merging.

## Steps
1. Read the diff: `git diff` or `git diff main..HEAD`
2. Work through the checklist
3. Output: blocking issues, non-blocking issues, one-line summary

## Checklist
- [ ] Does it do what it says it does?
- [ ] Are there unhandled edge cases?
- [ ] Any dead code or leftover debug output?
- [ ] Security issues? (injection, auth, secrets in code)
- [ ] Does the naming make sense without comments?
- [ ] Are tests present for new behaviour?
- [ ] Would this surprise someone reading it in 6 months?

## Output format
**Blocking:** (list, or "none")
**Non-blocking:** (list, or "none")
**Summary:** one sentence verdict
EOF
ok ".claude/skills/code-review.md"

# ── skills/new-component.md (stack-aware) ─────────────────────────────────────
if [[ "$STACK" == "Node / TypeScript" ]]; then
cat > .claude/skills/new-component.md << 'EOF'
# Skill: New Component

Scaffold a new TypeScript module or React component.

## Steps
1. Ask: what does this component/module do?
2. Ask: where does it live in the project?
3. Create the file with the structure below
4. Create a test file alongside it

## TypeScript module
```ts
// src/{name}.ts
export function {name}() {
  // implementation
}
```

## React component
```tsx
// src/components/{Name}.tsx
interface {Name}Props {
  // props
}

export function {Name}({ }: {Name}Props) {
  return <div></div>
}
```

## Rules
- No default exports
- Props interface always named `{Component}Props`
- Co-locate the test: `{name}.test.ts` or `{name}.test.tsx`
- No comments unless the logic is genuinely non-obvious
EOF
elif [[ "$STACK" == "Python" ]]; then
cat > .claude/skills/new-component.md << 'EOF'
# Skill: New Module

Scaffold a new Python module.

## Steps
1. Ask: what does this module do?
2. Ask: where does it live in the project?
3. Create the file and a matching test file

## Module
```python
# src/{name}.py
from __future__ import annotations


def {name}():
    pass
```

## Test
```python
# tests/test_{name}.py
from src.{name} import {name}


def test_{name}():
    pass
```

## Rules
- One public function or class per module unless tightly coupled
- Type hints on all public functions
- No comments unless the logic is genuinely non-obvious
EOF
else
cat > .claude/skills/new-component.md << 'EOF'
# Skill: New Component

Scaffold a new module or component.

## Steps
1. Ask: what does this do?
2. Ask: where does it live?
3. Create the file following existing conventions in the codebase
4. Create a test file alongside it

## Rules
- Match the style of existing files before introducing new patterns
- No comments unless the WHY is non-obvious
- Co-locate tests with the code they test
EOF
fi
ok ".claude/skills/new-component.md"

# ── skills/deploy-checklist.md ────────────────────────────────────────────────
if [[ "$DEPLOY" == "automated" ]]; then
cat > .claude/skills/deploy-checklist.md << 'EOF'
# Skill: Deploy Checklist

Run through this before merging to main / triggering a deploy.

## Pre-merge
- [ ] Tests pass locally
- [ ] No secrets or credentials in the diff
- [ ] No debug output or console.logs left in
- [ ] Migration scripts tested if schema changed
- [ ] Feature flag in place if this is a risky change

## Post-deploy
- [ ] CI pipeline green
- [ ] Check error rates / logs in the first 10 minutes
- [ ] Smoke test the critical path
- [ ] Rollback plan identified

## If something breaks
1. Rollback first, investigate second
2. Don't push a fix to a broken deploy without understanding the cause
EOF
else
cat > .claude/skills/deploy-checklist.md << 'EOF'
# Skill: Deploy Checklist

Run through this before every manual deploy.

## Before you deploy
- [ ] Tests pass locally
- [ ] Build succeeds
- [ ] No secrets or credentials in the diff
- [ ] No debug output left in
- [ ] Migration scripts ready if schema changed
- [ ] You know how to roll back

## Deploy steps
<!-- Fill in your actual steps here -->
1.
2.
3.

## After deploy
- [ ] Smoke test the critical path
- [ ] Check logs for errors
- [ ] Confirm with someone if this is a shared environment

## If something breaks
1. Rollback first, investigate second
2. Don't push a hotfix without understanding the root cause
EOF
fi
ok ".claude/skills/deploy-checklist.md"

# ── hooks/post-tool-use.sh ────────────────────────────────────────────────────
if [[ "$STACK" == "Node / TypeScript" ]]; then
cat > .claude/hooks/post-tool-use.sh << 'EOF'
#!/usr/bin/env bash
# PostToolUse — runs tsc after .ts/.tsx file edits
TOOL="$CLAUDE_TOOL_NAME"
FILE="$CLAUDE_TOOL_OUTPUT_FILE_PATH"
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
    npx tsc --noEmit 2>&1 | head -20
  fi
fi
EOF
elif [[ "$STACK" == "Python" ]]; then
cat > .claude/hooks/post-tool-use.sh << 'EOF'
#!/usr/bin/env bash
# PostToolUse — runs mypy after .py file edits
TOOL="$CLAUDE_TOOL_NAME"
FILE="$CLAUDE_TOOL_OUTPUT_FILE_PATH"
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  if [[ "$FILE" == *.py ]]; then
    python -m mypy "$FILE" 2>&1 | head -20
  fi
fi
EOF
else
cat > .claude/hooks/post-tool-use.sh << 'EOF'
#!/usr/bin/env bash
# PostToolUse — replace the body with your stack's type check or lint command
TOOL="$CLAUDE_TOOL_NAME"
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  : # add your check here
fi
EOF
fi
chmod +x .claude/hooks/post-tool-use.sh
ok ".claude/hooks/post-tool-use.sh"

# ── hooks/session-start.sh ────────────────────────────────────────────────────
cat > .claude/hooks/session-start.sh << 'EOF'
#!/usr/bin/env bash
# SessionStart — prints git context at the top of every session
echo "── session context ──────────────────────────────"
echo "Branch:      $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
echo "Changed:     $(git status --short 2>/dev/null | wc -l | tr -d ' ') files"
echo "Last commit: $(git log -1 --format='%s (%ar)' 2>/dev/null || echo 'none')"
echo "─────────────────────────────────────────────────"
EOF
chmod +x .claude/hooks/session-start.sh
ok ".claude/hooks/session-start.sh"

# ── agents/reviewer.md ────────────────────────────────────────────────────────
cat > .claude/agents/reviewer.md << 'EOF'
# Agent: Reviewer

A second Claude that reviews the main agent's work before it's shipped.

## When to use
Call this agent before committing work that touches:
- Auth, payments, or data migrations
- Any path you're not fully confident in
- Non-trivial refactors that could silently change behaviour

## Invocation
> /reviewer — review what I just wrote

## What this agent does
1. Reads the current diff or files you point it to
2. Applies the code-review checklist (`.claude/skills/code-review.md`)
3. Returns: blocking issues, non-blocking issues, one-line verdict

## What this agent does NOT do
- It does not make changes
- It does not have context from your session — brief it explicitly

## How to brief it well
> Review the changes in `src/auth.ts`. Context: replacing the JWT library
> because the old one doesn't support RS256. Main risk: token expiry handling.

The more specific the brief, the more useful the review.
EOF
ok ".claude/agents/reviewer.md"

# ── PROMPTS.md ────────────────────────────────────────────────────────────────
cat > PROMPTS.md << 'EOF'
# PROMPTS.md — Engineering Prompt Patterns

Raw prompting done right. These work. Use them as-is or adapt them.

---

## Debugging

> Here's the error: [paste]. Here's the relevant code: [paste].
> I've already tried: [what you tried]. What's wrong?

Don't describe the error — paste it. Don't ask Claude to guess — tell it what you tried.

---

## Implementing a feature

> Add [feature] to [file/component].
> Constraints: [what it must not break, what it must use].
> Don't refactor anything outside the scope of this task.

The last line matters. Without it Claude will "helpfully" clean up adjacent code.

---

## Reviewing before commit

> Review the diff below. Flag anything blocking. Be brief.
> [paste diff]

---

## Writing a test

> Write a test for [function] in [file].
> Cover: [case 1], [case 2], [edge case].
> Use [jest/pytest/your framework]. Match the style of existing tests.

---

## Explaining unfamiliar code

> Explain what [function/file] does. Assume I understand [language] but not this codebase.
> Focus on: what it does, what calls it, what could go wrong.

---

## Refactoring

> Refactor [function] to [goal].
> Do not change behaviour. Do not change the public interface.
> Show me the diff, not the full file.

---

## When Claude is going in circles

> Stop. What's the actual problem here? State it in one sentence before doing anything else.

---

## The fast path for small tasks

> In [file], [do X]. Nothing else.

Short tasks don't need context. Over-explaining makes Claude hedge.
EOF
ok "PROMPTS.md"

# ── settings.json ─────────────────────────────────────────────────────────────
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-tool-use.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  },
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm run *)",
      "Bash(npx tsc *)"
    ]
  }
}
EOF
ok ".claude/settings.json"

# ══════════════════════════════════════════════════════════════════════════════
# FOUNDER / OPS PATH
# ══════════════════════════════════════════════════════════════════════════════
else

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────
cat > CLAUDE.md << EOF
# CLAUDE.md — ${NAME}
> Role: Founder / Ops | ${TEAM} | Updated: ${DATE}

## Who I Am
<!-- Your role, context, and what you're optimising for. Fill this in. -->

## Output Defaults
- Format: ${TOOLS}
- Tone: direct, specific, no filler
- Length: as short as the content allows
- Primary output: ${OUTPUT}

## Rules
- Never: "Great question!", excessive em dashes, generic takes, padding
- Sound like someone who's done the work, not read about it
- Specific over vague — always
- If unsure, present options with a clear recommendation
- Only ask before irreversible actions (sending, deleting, publishing)

## My writing style
<!-- Paste 2-3 sentences you've written that sound like you. Claude will match them. -->

## What to change first
1. Fill in "Who I Am" — one paragraph, your actual context
2. Paste examples of your writing in "My writing style"
3. Remove rules that don't apply
EOF
ok "CLAUDE.md"

# ── skills/weekly-update.md ───────────────────────────────────────────────────
cat > .claude/skills/weekly-update.md << EOF
# Skill: Weekly Update

Draft a weekly status update in ${NAME}'s voice.

## Steps
1. Ask: what happened this week? (bullet dump is fine)
2. Ask: what's blocked or at risk?
3. Ask: who is the audience? (team / investors / board)
4. Draft using the format below

## Format

**Week of [date]**

**Done**
- [achievement + why it matters]

**In progress**
- [what, expected completion]

**Blocked / needs input**
- [blocker + what you need from who]

**Next week**
- [1-3 priorities]

## Rules
- Lead with outcomes, not activities ("closed 3 deals" not "had sales calls")
- Flag risks early — don't bury them
- One paragraph max per section
- Output format: ${TOOLS}
EOF
ok ".claude/skills/weekly-update.md"

# ── skills/decision-memo.md ───────────────────────────────────────────────────
cat > .claude/skills/decision-memo.md << 'EOF'
# Skill: Decision Memo

Turn a decision you're wrestling with into a structured memo.

## Steps
1. Ask: what's the decision? What's the deadline?
2. Ask: what options are you considering?
3. Ask: what's the context and constraints?
4. Draft below

## Format

**Decision:** [one sentence]
**By:** [date] | **Owner:** [who decides]

**Context**
[2-3 sentences. Why does this need to be decided now?]

**Options**

| Option | Pros | Cons |
|--------|------|------|
| A | | |
| B | | |

**Recommendation**
[Which option, and why. Be direct.]

**If we're wrong**
[What does a bad outcome look like? How do we catch it early?]

## Rules
- One recommendation, clearly stated — don't hedge
- "If we're wrong" forces you to think about reversibility
- Keep it under one page
EOF
ok ".claude/skills/decision-memo.md"

# ── skills/sop-writer.md ──────────────────────────────────────────────────────
cat > .claude/skills/sop-writer.md << 'EOF'
# Skill: SOP Writer

Turn a brain dump or process description into a clean SOP.

## Steps
1. Ask: what's the process? (paste raw notes, transcript, anything)
2. Ask: who will follow this? (new hire / experienced team / external)
3. Ask: what goes wrong most often?
4. Draft below

## Format

# [Process Name]

**Owner:** [role, not person]
**Frequency:** [when this is done]
**Time required:** [estimate]

## Prerequisites
- [what you need before starting]

## Steps
1. [action — specific, imperative]
2. [action]
3. [action]

## Common mistakes
- [mistake → correct action]

## If something goes wrong
[Who to contact, what to escalate]

## Rules
- Steps are actions, not descriptions ("click X", not "the button for X")
- If a step has a gotcha, add it as a sub-bullet immediately after
- "Common mistakes" is the most-read section — make it useful
EOF
ok ".claude/skills/sop-writer.md"

# ── skills/meeting-brief.md ───────────────────────────────────────────────────
cat > .claude/skills/meeting-brief.md << 'EOF'
# Skill: Meeting Brief

Generate a prep document before an important meeting.

## Steps
1. Ask: who is the meeting with and what's the context?
2. Ask: what do you need to get out of it?
3. Ask: what's the relationship history, if any?
4. Draft below

## Format

**Meeting:** [with who, about what]
**Date / time:**
**Goal:** [the one thing you need to leave with]

**Context**
[Background. What have they said before? What do they care about?]

**Your ask**
[State it simply. Don't bury the ask in context.]

**Likely objections**
- [objection → your response]

**What success looks like**
[Specific outcome, not "a good conversation"]

**What failure looks like**
[So you know when to stop and regroup]

## Rules
- One goal per meeting — if there are three, pick the most important
- Write the ask before writing the context
- "Likely objections" forces preparation, not improvisation
EOF
ok ".claude/skills/meeting-brief.md"

# ── PROMPTS.md ────────────────────────────────────────────────────────────────
cat > PROMPTS.md << EOF
# PROMPTS.md — Founder / Ops Prompt Patterns

These work. Use them as-is or adapt them.

---

## Writing in your voice

> Write [thing] in my voice. Here's an example of how I write: [paste 3-5 sentences].
> Topic: [topic]. Audience: [who will read this]. Goal: [what you want them to do or feel].

The example is the most important part. Without it, you get generic AI prose.

---

## Making a decision

> I'm deciding between [A] and [B]. Context: [1-2 sentences].
> Constraints: [what I can't change]. What do you recommend and why?

Don't ask "what are the pros and cons" — that's a list, not a recommendation.

---

## Turning notes into a document

> Here are my raw notes on [topic]: [paste].
> Turn this into a clean [memo / SOP / brief]. Audience: [who]. Format: ${TOOLS}.
> Don't add anything I didn't say. Don't remove specifics.

The last line stops Claude from padding or genericising your content.

---

## Preparing for a hard conversation

> I need to have a conversation with [role] about [topic].
> Context: [situation]. What I want to achieve: [goal].
> What are the 3 most likely ways this goes wrong, and how do I prepare for them?

---

## Drafting a message you've been avoiding

> I need to [say X] to [person/group]. I've been avoiding it because [reason].
> Draft a message that's direct but not aggressive. Keep it under [N] sentences.

---

## Getting unstuck

> I'm stuck on [problem]. Here's what I know: [context].
> Here's what I've tried: [attempts]. What am I missing?

Always say what you've tried. It stops Claude from suggesting things you've already ruled out.

---

## The fast path for small tasks

> [Do X]. Context: [one sentence]. Output format: ${TOOLS}.

Short tasks don't need long prompts. Over-explaining makes Claude hedge.
EOF
ok "PROMPTS.md"

fi  # end role branch

# ── README.md (shared) ────────────────────────────────────────────────────────
cat > README.md << 'READMEEOF'
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
READMEEOF
ok "README.md"

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Done.${NC} Files created:"
echo ""
find . -not -path './.git/*' -not -name '.DS_Store' | sort | grep -v "^\.$" | sed 's|^\./||' | awk '{print "  " $0}'
echo ""
echo "Next: open CLAUDE.md and fill in the two marked sections."
echo ""
