#!/bin/bash
#
# pl - "pick list": pick a line from a file and copy it to the clipboard via OSC52.
#
# Usage:
#   pl [SUBSTRING ...]
#
# Each SUBSTRING narrows the search results (all must match, in any order).
# If exactly one line matches, it is copied immediately. Otherwise an
# fzf menu is shown, pre-seeded with the substrings as the query.

set -euo pipefail

list="${PICK_LIST:-$HOME/ss/herd/all}"

# Let fzf do the filtering. In extended-search mode the query terms are
# AND-ed together; --exact makes each term a substring (not fuzzy) match.
# --select-1 auto-picks when a single line matches (no UI); --exit-0 bails
# immediately when nothing matches.
rc=0
line="$(fzf --prompt='pl> ' --height='40%' --reverse --exact \
            --query="$*" --select-1 --exit-0 < "$list")" || rc=$?

case "$rc" in
  0) ;;                                                # got a selection
  1) echo "pl: no match: $*" >&2; exit 1 ;;            # --exit-0: nothing matched
  130) exit 130 ;;                                     # user cancelled (Esc/^C)
  *) echo "pl: fzf failed (exit $rc)" >&2; exit "$rc" ;;
esac

osc52 () {
        printf "\x1b]52;c;$(base64)\x07"
}

# Copy $line to the clipboard using OSC52.
copy_osc52() {
  local data=$1
  printf '%s' "$data" | osc52
}

copy_osc52 "$line"
echo "copied to clipboard: $line" >&2
