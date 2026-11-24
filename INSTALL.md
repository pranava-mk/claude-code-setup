# Install this setup (instructions for an AI agent)

You are an AI coding agent. The user asked you to install parts of the public
repo `pranava-mk/claude-code-setup`. Follow these steps in order.

Raw files are at:
`https://raw.githubusercontent.com/pranava-mk/claude-code-setup/main/<path>`

## Rules

- Before you change an existing file, copy it to `<file>.bak-<YYYYMMDD>`.
- Write files only in the folders named in this document.
- Do not run commands other than the ones in this document.
- Do not overwrite the user's own settings. Merge.
- If a step fails, stop that part, tell the user which step failed and the
  exact error, then continue with the next part.

## Step 0: Find your tool and let the user pick

1. Find out which tool you run in (Claude Code, Kiro, Codex, Cursor, and so on).
2. If the user's prompt names one part (for example "only the agents"), do
   only that part. Otherwise show this list and ask which parts to install.
   Use your question UI if you have one; otherwise print the list and wait.

| Part | What it is | Works in |
|---|---|---|
| Skills | `cruxx-learn-ultra`, `cruxx-map`, `find-skills` | Any agent with skills |
| Subagents | `implementer`, `verifier`, `fast-worker`, `arch-maintenance`, `design-fetch` | Claude Code |
| Settings | model, effort, plugins, theme, voice, hooks (`settings.json`) | Claude Code |
| Status line | ccstatusline layout and its npm package | Claude Code |

If you are not Claude Code, offer only Skills. Tell the user that the other
parts are Claude Code config.

## Part 1: Skills

Read `INSTALL-SKILL.md` from this repo and follow it.

## Part 2: Subagents (Claude Code)

1. Download each file to `~/.claude/agents/<name>.md`:
   - `claude/.claude/agents/implementer.md`
   - `claude/.claude/agents/verifier.md`
   - `claude/.claude/agents/fast-worker.md`
   - `claude/.claude/agents/arch-maintenance.md` (Arch Linux only: ask first)
   - `claude/.claude/agents/design-fetch.md`
2. If a file with the same name exists, show the user the difference and ask
   before you replace it.

## Part 3: Settings (Claude Code)

1. Download `claude/.claude/settings.json` from this repo.
2. Read the user's `~/.claude/settings.json` (it may not exist).
3. Merge: add the keys from the repo file that the user's file does not have.
   For keys that are in both files with different values, ask the user which
   value to keep.
4. Skip these keys unless their condition is true:
   - `hooks.SessionStart` with `herdr-agent-state.sh`: only if `herdr` is
     installed (`command -v herdr`). Then run `herdr integration install claude`.
   - `statusLine`: only if the user also picked the status line (Part 4).
5. Change every `/home/cruxx` in the values to the user's home folder.
6. Tell the user that the `caveman` plugin installs from its marketplace the
   next time Claude Code starts.

## Part 4: Status line (Claude Code)

Needs Node.js. If `node` does not exist, tell the user and skip this part.

1. Download `claude/.claude/tools/package.json` and
   `claude/.claude/tools/package-lock.json` to `~/.claude/tools/`.
2. Run `npm --prefix ~/.claude/tools ci`.
3. Download `ccstatusline/.config/ccstatusline/settings.json` to
   `~/.config/ccstatusline/settings.json`.
4. In `~/.claude/settings.json`, set:

   ```json
   "statusLine": {
     "type": "command",
     "command": "<node> <home>/.claude/tools/node_modules/ccstatusline/dist/ccstatusline.js",
     "padding": 0,
     "refreshInterval": 60
   }
   ```

   `<node>` is the absolute path from `command -v node`. `<home>` is the
   user's home folder.

## Step 5: Report

Tell the user:

- each part you installed, and the files you wrote or changed,
- the backups you made,
- what you skipped, and why,
- to restart the tool so the changes load.
