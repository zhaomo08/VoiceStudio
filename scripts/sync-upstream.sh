#!/usr/bin/env bash
# Fork workflow (see FORK.md):
#   main    = pure mirror of debpalash/VoiceStudio main, fast-forward only
#   develop = our own work; upstream changes enter only via `git cherry-pick -x`
#
#   scripts/sync-upstream.sh           fast-forward main, list upstream commits not yet picked
#   scripts/sync-upstream.sh --list    only list (no fetch/push)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

[[ "$(git remote get-url origin)" == *github.com/zhaomo08/VoiceStudio* ]] || { echo "origin is not zhaomo08/VoiceStudio" >&2; exit 1; }
[[ "$(git remote get-url upstream)" == *github.com/debpalash/VoiceStudio* ]] || { echo "upstream is not debpalash/VoiceStudio" >&2; exit 1; }

if [[ "${1:-}" != --list ]]; then
  git fetch --prune upstream main
  git fetch --prune origin
  # Update main without checking it out; fails (no force) if main has local commits.
  git merge-base --is-ancestor main upstream/main || { echo "main has diverged from upstream/main; refusing." >&2; exit 1; }
  git branch -f main upstream/main
  git push origin main
fi

# Upstream lands work as PR merges on main, so walk first-parent history since develop forked
# and hide commits already recorded by `cherry-pick -x` trailers on develop.
# ponytail: trailer matching only; commits picked without -x will show as pending.
base="$(git merge-base develop main)"
picked="$(git log develop --format=%b | sed -n 's/.*cherry picked from commit \([0-9a-f]\{40\}\).*/\1/p' | sort -u)"

pending=0
while read -r sha subject; do
  grep -qx "$sha" <<<"$picked" && continue
  parents=$(git rev-list --parents -n1 "$sha" | wc -w)
  flag=""; (( parents > 2 )) && flag=" [merge: -m 1]"
  echo "${sha:0:10} ${subject}${flag}"
  pending=$((pending + 1))
done < <(git log --first-parent --reverse --format='%H %s' "$base..main")

echo "---"
echo "main @ $(git rev-parse --short=8 main); $pending upstream commit(s) not picked into develop."
echo "Pick with: git switch develop && git cherry-pick -x [-m 1] <sha>"
