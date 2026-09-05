#!/usr/bin/env bash
# PreToolUse hook, fired only for tools matching mcp__Me__.* (see settings.json matcher).
#
# Rule zero: this research assistant never places, cancels, or exercises
# anything, and never rehearses or edits account state either. Enforced as
# default-deny, not a list of forbidden prefixes — any mcp__Me__ tool that is
# not a read (get_*) call is blocked, including tools that don't exist yet.
set -euo pipefail

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

# Not a Robinhood tool (shouldn't happen given the matcher, but be defensive).
if [[ "$tool_name" != mcp__Me__* ]]; then
  exit 0
fi

# Read-only tools are named mcp__Me__get_*. Everything else is denied by default.
if [[ "$tool_name" =~ ^mcp__Me__get_ ]]; then
  exit 0
fi

echo "Rule zero: '$tool_name' is not a read-only (get_*) Robinhood tool. This research assistant never trades, cancels, exercises, rehearses an order, or writes to your account — structurally, not by discretion. Blocked." >&2
exit 2
