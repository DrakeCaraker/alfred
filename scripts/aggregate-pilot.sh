#!/usr/bin/env bash
# Aggregate pilot telemetry across all participants
# Reads .pilot/telemetry/*.json and prints summary report
set -uo pipefail

PILOT_DIR=".pilot/telemetry"

if [ ! -d "$PILOT_DIR" ]; then
    echo "No pilot telemetry directory found at $PILOT_DIR"
    exit 1
fi

json_files=$(find "$PILOT_DIR" -name '*.json' -not -name '.gitkeep' 2>/dev/null)

if [ -z "$json_files" ]; then
    echo "No telemetry files found in $PILOT_DIR"
    exit 0
fi

python3 << 'PYEOF'
import json, os, sys
from collections import Counter, defaultdict
from pathlib import Path

pilot_dir = Path(".pilot/telemetry")
files = sorted(pilot_dir.glob("*.json"))

if not files:
    print("No telemetry files found.")
    sys.exit(0)

users = []
errors = []

for f in files:
    try:
        data = json.loads(f.read_text())
        users.append(data)
    except (json.JSONDecodeError, OSError) as e:
        errors.append(f"{f.name}: {e}")

if errors:
    print(f"WARNING: {len(errors)} file(s) could not be parsed:")
    for e in errors:
        print(f"  - {e}")
    print()

print("=" * 60)
print("ALFRED PILOT TELEMETRY — AGGREGATE REPORT")
print("=" * 60)
print()

# --- Overview ---
total_users = len(users)
total_sessions = sum(len(u.get("sessions", [])) for u in users)
all_dates = []
for u in users:
    for s in u.get("sessions", []):
        if "date" in s:
            all_dates.append(s["date"])

all_dates.sort()
date_range = f"{all_dates[0]} to {all_dates[-1]}" if all_dates else "n/a"

print(f"1. OVERVIEW")
print(f"   Participants: {total_users}")
print(f"   Total sessions: {total_sessions}")
print(f"   Date range: {date_range}")
print(f"   Note: Collection is best-effort — some sessions may be missed")
print(f"         (rapid exits, interruptions). Any recorded session is preserved.")
print()

# --- Persona distribution ---
personas = Counter(u.get("persona", "unknown") for u in users)
print(f"2. PERSONA DISTRIBUTION")
for p, c in personas.most_common():
    pct = c / total_users * 100
    print(f"   {p}: {c} ({pct:.0f}%)")
print()

# --- Coding level distribution ---
levels = Counter(u.get("coding_level", "unknown") for u in users)
print(f"3. CODING LEVEL DISTRIBUTION")
for l, c in levels.most_common():
    pct = c / total_users * 100
    print(f"   {l}: {c} ({pct:.0f}%)")
print()

# --- Pattern graduation funnel ---
pattern_graduated = Counter()
pattern_total = Counter()
sessions_to_graduate = defaultdict(list)

for u in users:
    for s in u.get("sessions", []):
        ps = s.get("patterns_state", {})
        for pname, pstate in ps.items():
            pattern_total[pname] += 1
            if pstate.get("graduated", False):
                pattern_graduated[pname] += 1
        for g in s.get("graduated_this_session", []):
            sessions_to_graduate[g].append(s.get("session_number", 0))

all_patterns = sorted(set(list(pattern_total.keys()) + list(pattern_graduated.keys())))
print(f"4. PATTERN GRADUATION FUNNEL")
if all_patterns:
    for p in all_patterns:
        grad = pattern_graduated.get(p, 0)
        total = max(pattern_total.get(p, 1), 1)
        rate = grad / total_users * 100 if total_users > 0 else 0
        avg_sessions = ""
        if p in sessions_to_graduate and sessions_to_graduate[p]:
            avg = sum(sessions_to_graduate[p]) / len(sessions_to_graduate[p])
            avg_sessions = f" (avg {avg:.1f} sessions to graduate)"
        print(f"   {p}: {grad}/{total_users} users ({rate:.0f}%){avg_sessions}")
else:
    print("   No pattern data yet")
print()

# --- Command frequency ---
all_commands = Counter()
for u in users:
    for s in u.get("sessions", []):
        for cmd in s.get("commands_used", []):
            all_commands[cmd] += 1

print(f"5. COMMAND FREQUENCY")
if all_commands:
    for cmd, c in all_commands.most_common(15):
        print(f"   {cmd}: {c}")
else:
    print("   No command data yet")
print()

# --- Engagement trends ---
sessions_per_day = Counter()
duration_dist = Counter()
for u in users:
    for s in u.get("sessions", []):
        if "date" in s:
            sessions_per_day[s["date"]] += 1
        duration_dist[s.get("duration_bucket", "unknown")] += 1

print(f"6. ENGAGEMENT TRENDS")
if sessions_per_day:
    avg_per_day = total_sessions / len(sessions_per_day)
    print(f"   Active days: {len(sessions_per_day)}")
    print(f"   Avg sessions/day: {avg_per_day:.1f}")
print(f"   Duration distribution:")
for d, c in duration_dist.most_common():
    pct = c / total_sessions * 100 if total_sessions > 0 else 0
    print(f"     {d}: {c} ({pct:.0f}%)")
print()

# --- Feedback count ---
feedback_dir = Path(".pilot/feedback")
feedback_count = len(list(feedback_dir.glob("*.md"))) if feedback_dir.exists() else 0
print(f"7. FEEDBACK")
print(f"   Feedback files: {feedback_count}")
if feedback_count > 0:
    print(f"   See .pilot/feedback/ for details")
print()

# --- Schema version check ---
versions = Counter(u.get("_schema_version", "unknown") for u in users)
print(f"8. SCHEMA VERSIONS")
for v, c in versions.most_common():
    print(f"   v{v}: {c} file(s)")
if len(versions) > 1:
    print("   WARNING: Mixed schema versions detected!")
print()

print("=" * 60)
PYEOF
