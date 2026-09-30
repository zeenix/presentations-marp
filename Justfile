# The Marp CLI that generates the HTML. Override it with e.g. `just marp=marp`.
marp := "npx --yes @marp-team/marp-cli"

# Regenerate the HTML of each presentation whose Markdown changed since its HTML was generated.
html:
    #!/usr/bin/env bash
    set -euo pipefail

    # Whether the HTML at $2 is out of date with respect to the Markdown at $1.
    stale() {
        [[ -e $2 ]] || return 0

        # For files as they were committed, the file times are those of the checkout that wrote
        # them, in whichever order it did, so compare when each was last committed instead.
        if git ls-files --error-unmatch -- "$1" "$2" &>/dev/null &&
            git diff --quiet HEAD -- "$1" "$2"; then
            [[ $(git log -1 --format=%ct -- "$1") -gt $(git log -1 --format=%ct -- "$2") ]]
        else
            [[ $1 -nt $2 ]]
        fi
    }

    git ls-files --cached --others --exclude-standard -- '*.md' | while read -r src; do
        grep -qsx 'marp: true' "$src" || continue

        html=${src%.md}.html
        if stale "$src" "$html"; then
            {{ marp }} --no-stdin "$src" -o "$html" </dev/null
        fi
    done
