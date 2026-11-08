#!/usr/bin/env bash
# Applies the usage-saving Claude Code setup to ALL projects (user-level ~/.claude).
# Safe to re-run: keeps your other settings and only sets "model".
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/agents"

# 1) Default model = opusplan (Opus in Plan Mode, Sonnet otherwise), merged into existing settings.
node -e '
const fs = require("fs");
const p = process.argv[1];
let s = {};
if (fs.existsSync(p)) {
  fs.copyFileSync(p, p + ".bak");
  s = JSON.parse(fs.readFileSync(p, "utf8") || "{}");
}
s.model = "opusplan";
fs.writeFileSync(p, JSON.stringify(s, null, 2) + "\n");
' "$CLAUDE_DIR/settings.json"

# 2) Haiku subagent for small tasks, available in every project.
cat > "$CLAUDE_DIR/agents/quick-helper.md" <<'AGENT'
---
name: quick-helper
description: Fast, low-cost helper for small, well-defined tasks — finding files, grepping for a symbol, reading and summarizing a file, small mechanical edits (rename, typo, formatting), or running a single command and reporting its output. Use proactively for these instead of the main model. Do NOT use for design decisions, multi-file refactors, or debugging that needs deep reasoning.
model: haiku
tools: Read, Grep, Glob, Bash, Edit, Write
---

You are a fast helper for small, focused tasks.

- Do exactly the task you were given; do not expand scope.
- Keep your final report short: what you did, file paths with line numbers, and any command output that matters.
- If the task turns out to need real design or deep debugging, stop and say so instead of guessing.
AGENT

echo "Done:"
echo "  $CLAUDE_DIR/settings.json  -> model = opusplan"
echo "  $CLAUDE_DIR/agents/quick-helper.md  -> Haiku subagent"
