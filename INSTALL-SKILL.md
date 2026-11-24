# Install a skill from this repo (instructions for an AI agent)

You are an AI coding agent. The user asked you to install Agent Skills from
the public repo `pranava-mk/claude-code-setup`. Follow these steps in order.

## Step 0: Let the user pick

Show the user this list and ask which skills to install. They can pick one,
several, or all. Use your question UI if you have one; otherwise print the
list and wait for the reply.

| Skill | What it does |
|---|---|
| `cruxx-learn-ultra` | Turns a topic, repo or docs into one HTML course at the learner's level, every fact linked to its source |
| `cruxx-map` | Maps a repo into a three-layer context structure (CLAUDE.md router, CONTEXT.md per area, references) |
| `find-skills` | Finds and installs agent skills from skills.sh |

Do Steps 1 to 3 for each skill the user picks. Below, `<skill>` means that
skill's name.

## Rules

- Write files only in the skill folders named in this document.
- Do not run commands other than the ones in this document.
- If a step fails, tell the user which step failed and the exact error.

## Step 1: Use the skills CLI if Node.js is available

If you can run shell commands and `npx` exists, run:

```bash
npx -y skills add https://github.com/pranava-mk/claude-code-setup/tree/main/claude/.claude/skills/<skill> -g -y
```

This installs the skill for every agent the CLI finds on this machine.
Then go to Step 3.

If `npx` does not exist or the command fails, go to Step 2.

## Step 2: Install by hand

1. Find the user-level skills folder for the tool you are running in:

   | Tool | Folder |
   |---|---|
   | Claude Code | `~/.claude/skills/` |
   | Kiro (IDE and CLI) | `~/.kiro/skills/` |
   | OpenAI Codex | `~/.agents/skills/` |
   | Cursor | `~/.cursor/skills/` |
   | GitHub Copilot (CLI, VS Code) | `~/.copilot/skills/` |
   | Gemini CLI | `~/.gemini/skills/` |
   | OpenCode | `~/.config/opencode/skills/` |
   | Windsurf / Devin Local | `~/.config/devin/skills/` |
   | Cline | `~/.cline/skills/` |
   | Amp | `~/.config/agents/skills/` |
   | Roo Code | `~/.roo/skills/` |
   | Goose, and any other tool | `~/.agents/skills/` |

   On Windows, `~` is `%USERPROFILE%`.

2. Download this file:

   `https://raw.githubusercontent.com/pranava-mk/claude-code-setup/main/claude/.claude/skills/<skill>/SKILL.md`

   With a shell: `curl -fsSL <url> -o <folder>/<skill>/SKILL.md` (create the
   folder first). Without a shell: fetch the URL and write the content
   unchanged to `<folder>/<skill>/SKILL.md`.

3. Also put a copy in `~/.agents/skills/<skill>/SKILL.md`. Many tools read
   this shared folder.

If your tool does not support skills: add one line to its global rules or
custom instructions: "When the user asks for `<skill>`, read
`~/.agents/skills/<skill>/SKILL.md` and follow it."

## Step 3: Check and report

1. Open the installed `SKILL.md`. The first line must be `---`, and the
   frontmatter must contain `name: <skill>`.
2. Tell the user:
   - the folders you wrote to,
   - to start a new session (or reload the tool) so the skill loads,
   - how to use it: type `/<skill>` where the tool has slash commands, or
     say "use <skill>" (for example, "use cruxx-learn-ultra to teach me Rust").
