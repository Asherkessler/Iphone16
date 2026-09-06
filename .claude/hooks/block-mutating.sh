#!/usr/bin/env bash
# PreToolUse hook, fired only for tools matching mcp__Me__.* (see settings.json matcher).
#
# Rule zero: this research assistant never places, cancels, or exercises
# anything, and never rehearses or edits account state either. Enforced as
# default-deny, not a list of forbidden prefixes — any mcp__Me__ tool that is
# not a read is blocked, including tools that don't exist yet.
#
# The allow pattern is ^mcp__Me__(get_|search$|run_scan$):
#   get_       prefix match — the server's read convention, covers ~45 tools
#              and every future get_* it ships
#   search     EXACT match only
#   run_scan   EXACT match only
#
# search and run_scan are read-only but don't follow the get_ convention, so
# they need naming. That is two literals, not a maintained list, and the
# important property survives: anything new is denied unless it is a get_.
# Both are anchored with $ so a future mcp__Me__search_and_replace or
# mcp__Me__run_scan_delete does NOT inherit the exception.
set -euo pipefail

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

# Not a Robinhood tool (shouldn't happen given the matcher, but be defensive).
if [[ "$tool_name" != mcp__Me__* ]]; then
  exit 0
fi

# Read-only tools: get_* (prefix), plus search and run_scan (exact). Everything
# else is denied by default — see the header for why these two are named.
if [[ "$tool_name" =~ ^mcp__Me__(get_|search$|run_scan$) ]]; then
  exit 0
fi

echo "Rule zero: '$tool_name' is not a read-only Robinhood tool (allowed: get_*, search, run_scan). This research assistant never trades, cancels, exercises, rehearses an order, or writes to your account — structurally, not by discretion. Blocked." >&2
exit 2
