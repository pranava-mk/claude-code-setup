---
name: cruxx-map
description: Map any repository into Jake Van Clief's three-layer context architecture (root CLAUDE.md map with a routing table, a CONTEXT.md per room, skills/reference loaded on demand), written as rich markdown (tables, mermaid diagrams, callouts). Scans the repo first, then asks the user targeted questions before writing anything. Use for "cruxx map", "/cruxx-map", "map this repo", "set up context for this repo", "add CLAUDE.md and CONTEXT.md files", "routing table", "Clief / ICM / three-layer architecture", or to refresh or audit an existing map.
---

# cruxx-map

Turn a repository into a three-layer context system so an agent reads only what a task needs.

| Layer | File | Loaded | Answers | Budget |
|---|---|---|---|---|
| 1. Map | root `CLAUDE.md` | every session | Where am I? Where do I go? | ≤ 80 lines (~800 tokens) |
| 2. Rooms | `<folder>/CONTEXT.md` | on entering that folder | What happens here? What matters? What to avoid? | ≤ 120 lines |
| 3. Tools / reference | `REFERENCES.md`, `docs/`, skills, MCP | only when a routing row names it | What rules apply? | varies |

The agent reads downward and stops when it has enough. The **routing table** in `CLAUDE.md` (`Task | Go to | Read | Skills`) is the core deliverable: it is what keeps the agent from reading everything.

## Modes

Pick from the request and repo state. Say which mode you chose in one line.

- **Build**: no map yet (no root `CLAUDE.md`, or one with no routing table). Full flow below.
- **Refresh**: a map exists. Find drift: `git log --since=<date of last map commit> --stat`, new or removed top-level folders, routing rows pointing at paths that no longer exist. Ask only about the changes, then patch the minimum.
- **Audit**: user asks "is this map good?". Run the checks in Phase 5 and report findings. Write nothing unless asked.

## Phase 1: Discover (read-only, no questions yet)

Build a picture of the repo before asking anything. Questions should only cover what the code cannot tell you.

1. **Root**: the cwd is the root. If cwd is not a git root, say so in your first question.
2. **Shape**: `git ls-files | head -500` (or `find` minus `node_modules`, `.venv`, `dist`, `build`, `target`, `.git`). Count files per top-level folder.
3. **Stack**: read manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Gemfile`, `composer.json`, `Dockerfile`, `docker-compose*`, CI files under `.github/workflows/`). Record language, framework, scripts (build, test, lint, dev), and entry points.
4. **Existing context**: read `README*`, `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `CONTRIBUTING*`, `docs/`, any existing `CONTEXT.md`. Existing instructions are payload: never discard them silently.
5. **Hotspots**: `git log --since=6.months --name-only --format= | sort | uniq -c | sort -rn | head -20` shows where work happens. Also scan for `TODO|FIXME|HACK` counts per folder.
6. **Candidate rooms**: a folder is a room when it is a distinct mode of work (frontend, api, infra, data pipeline, docs, a package in a monorepo). It is not a room just because it exists. Typical count: 2 to 7. Generated, vendored and asset folders are never rooms.
7. **Candidate routing rows**: draft 5 to 10 tasks you expect (add an API endpoint, add a page, write a migration, fix a failing test, release, update docs). Each row names a room, specific files to read, and skills if obvious.

For a large repo (more than ~2000 tracked files or many packages), delegate the sweep to an `Explore` agent with the list above and ask for a compact summary, so file dumps stay out of the main context.

Finish Phase 1 with a short summary to the user: stack, proposed rooms, draft routing rows, and anything surprising.

## Phase 2: Ask

Use `AskUserQuestion`. Batch questions: at most 2 rounds, at most 4 questions per round. Put your recommended option first, labelled "(Recommended)", built from what you found in Phase 1. Skip any question discovery already answered. Do not ask things the code tells you (language, framework, test command).

Round 1, pick the most useful of:

- **Rooms**: "I propose these rooms: A, B, C. Which should get a CONTEXT.md?" (multiSelect; options are the candidates).
- **Purpose and reader**: "Who will work in this repo with an agent, and on what?" (for example: solo feature work, onboarding contributors, maintenance only, course or portfolio project).
- **Top tasks**: "Which tasks do you do most often here?" (multiSelect; options are your draft routing rows). These become the first routing rows.
- **Existing CLAUDE.md** (only if one exists): merge into the new map (Recommended) / keep it and add the routing table only / replace it.

Round 2, only if still needed:

- **No-go zones and gotchas**: "Anything an agent must never touch or should know the hard way?" (options from what you saw: generated code, migrations, secrets, vendored libs, flaky tests).
- **Richness**: "How rich should the markdown be?" Full: mermaid diagrams, tables, callouts (Recommended) / Lean: tables and lists only, no diagrams.
- **Reference layer**: create `REFERENCES.md` / reuse existing `docs/` / skip.
- **Naming conventions**: only if you spotted patterns (date prefixes, `_draft`/`_final`, versioned files) worth declaring.

## Phase 3: Plan, then confirm

Show the exact file list with one line each: path, create or edit, what goes in it. If an existing file will change, say how. Wait for a yes before writing. Plan approval also counts as the pick when you offered alternative shapes earlier.

## Phase 4: Write

Use the templates in this skill folder as starting shapes, not fill-in forms:

- `templates/claude-md.md`: Layer 1 map.
- `templates/context-md.md`: Layer 2 room.
- `templates/references-md.md`: Layer 3 index.

Rules:

- **CLAUDE.md is a router, not a manual.** Identity (1 to 3 lines), commands, rooms list, routing table, conventions, rules. Detailed explanation belongs in a room or in references. Merge any existing instructions you were told to keep, preserving their wording.
- **Every path in a routing row or "files that matter" list must exist.** No invented files, no placeholders. A row with nothing to read yet says `(none)`.
- **One CLAUDE.md per repo.** Rooms get `CONTEXT.md`, never their own `CLAUDE.md`. Say this to the user once when you create the first room, because people expect one per folder. (Monorepo exception: a package that is opened as its own project may keep a `CLAUDE.md`; ask first.)
- **Isolation rule.** Each room's "Avoid" section names the sibling rooms it should not reach into and why.
- **Rich markdown, used where it carries information:**
  - Tables for routing, commands, file roles.
  - Mermaid (`flowchart`, `sequenceDiagram`, `erDiagram`) for real flows: request path, data pipeline, build/deploy, module dependencies. One diagram per room at most, under ~15 nodes, and only if it shows something the prose does not. Draw what the code does, not a generic picture.
  - GitHub alerts for things that bite: `> [!WARNING]` for no-go zones, `> [!NOTE]` for non-obvious context, `> [!TIP]` for shortcuts.
  - `<details><summary>` for long but rarely needed lists.
  - Relative links between map, rooms and references so they click through on GitHub.
  - Lean mode: drop mermaid and `<details>`; keep tables and alerts.
- **Stamp each file** with a last line: `<!-- cruxx-map: <YYYY-MM-DD> -->`. Refresh mode uses it to find drift.

## Phase 5: Verify

Run these checks before reporting done, and in Audit mode:

1. Every path in the routing table and every "files that matter" entry exists: extract with `grep -oE '\`[^\`]+\`'` and test each.
2. Budgets: `wc -l CLAUDE.md` ≤ 80; each `CONTEXT.md` ≤ 120. Over budget means move detail down a layer.
3. Every room listed in `CLAUDE.md` has a `CONTEXT.md`, and every `CONTEXT.md` is listed.
4. Mermaid blocks parse: if `npx -y @mermaid-js/mermaid-cli` is available, render each block to `/dev/null`; otherwise check node IDs are unquoted identifiers and labels with special characters are in quotes.
5. No secrets copied from `.env*` or config into any markdown.
6. Routing table has at least 5 rows and each row's Go to is a listed room or `/`.

Report: files written, line counts, check results, and any routing rows marked `(none)` that the user should fill in later. Do not commit unless the user asks.
