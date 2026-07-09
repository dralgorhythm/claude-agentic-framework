#!/usr/bin/env bash
# Cut a release: stamp CHANGELOG, bump plugin.json, commit, tag, push, GitHub Release.
#
# Usage:   ./scripts/release.sh X.Y.Z ["Release title"]   [--dry-run]
# Example: ./scripts/release.sh 3.0.0 "Zero-install modernization"
#
# What a release IS (see docs/releasing.md):
#   1. CHANGELOG [Unreleased] section stamped as [X.Y.Z] - YYYY-MM-DD (fresh stub re-inserted)
#   2. .claude-plugin/plugin.json version = X.Y.Z  (plugin users receive updates at this moment)
#   3. commit "release: vX.Y.Z" + annotated tag vX.Y.Z, pushed to origin
#   4. GitHub Release with the stamped CHANGELOG section as its body
#
# --dry-run prints what would happen and changes nothing. That is the only flag.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

fail() { echo "release: $1" >&2; exit 1; }

# --- args ---------------------------------------------------------------
VERSION="${1:-}"; shift || true
TITLE=""; DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) TITLE="$arg" ;;
  esac
done
[ -n "$VERSION" ] || fail "usage: ./scripts/release.sh X.Y.Z [\"Release title\"] [--dry-run]"
echo "$VERSION" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' || fail "'$VERSION' is not X.Y.Z semver"
TAG="v$VERSION"
[ -n "$TITLE" ] && FULL_TITLE="$TAG — $TITLE" || FULL_TITLE="$TAG"

# --- preflight (each failure is a one-line reason) -----------------------
command -v gh >/dev/null 2>&1      || fail "gh CLI not found"
command -v python3 >/dev/null 2>&1 || fail "python3 not found"
gh auth status >/dev/null 2>&1     || fail "gh is not authenticated (run: gh auth login)"

BRANCH="$(git branch --show-current)"
[ "$BRANCH" = "main" ]                     || fail "must run on main (currently on '$BRANCH')"
[ -z "$(git status --porcelain)" ]         || fail "working tree is not clean"
git fetch origin main --quiet
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || fail "main is not up to date with origin/main (pull first)"

git rev-parse "$TAG" >/dev/null 2>&1 && fail "tag $TAG already exists"
LAST_TAG="$(git tag --list 'v*' --sort=-v:refname | head -1)"
if [ -n "$LAST_TAG" ]; then
  HIGHEST="$(printf '%s\n%s\n' "${LAST_TAG#v}" "$VERSION" | sort -V | tail -1)"
  [ "$HIGHEST" = "$VERSION" ] || fail "$VERSION is not greater than latest tag $LAST_TAG"
fi

grep -q '^## \[Unreleased\]$' CHANGELOG.md || fail "CHANGELOG.md has no '## [Unreleased]' section"
UNRELEASED_BODY="$(awk '/^## \[Unreleased\]$/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | sed '/^<!--/d' | sed '/^[[:space:]]*$/d')"
[ -n "$UNRELEASED_BODY" ] || fail "the [Unreleased] section is empty — nothing to release"

./scripts/check-invariants.sh >/dev/null || fail "framework invariants are red (run ./scripts/check-invariants.sh)"

# --- plan ----------------------------------------------------------------
DATE="$(date +%F)"
echo "Release plan:"
echo "  version   : $VERSION (tag $TAG, after ${LAST_TAG:-<none>})"
echo "  title     : $FULL_TITLE"
echo "  CHANGELOG : stamp [Unreleased] -> [$VERSION] - $DATE (+ fresh stub)"
echo "  plugin    : .claude-plugin/plugin.json version -> $VERSION"
echo "  publish   : commit + annotated tag + push + GitHub Release"
if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "--dry-run: no changes made. Release notes would be:"
  echo "$UNRELEASED_BODY"
  exit 0
fi

# --- stamp CHANGELOG ------------------------------------------------------
python3 - "$VERSION" "$DATE" <<'PYEOF'
import re, sys
version, date = sys.argv[1], sys.argv[2]
s = open('CHANGELOG.md').read()
# drop the instructional comment from the section being released (and its trailing blank line)
s = re.sub(r'\n<!-- Add entries under [^>]*? at release time\. -->\n\n?', '\n', s, count=1)
# stamp the heading and re-insert a fresh stub above it
stamped = (
    "## [Unreleased]\n\n"
    "<!-- Add entries under Breaking / Added / Changed / Deprecated / Removed / Fixed / Security. "
    "scripts/release.sh stamps this section with a version and date at release time. -->\n\n"
    f"## [{version}] - {date}"
)
s = s.replace("## [Unreleased]", stamped, 1)
open('CHANGELOG.md','w').write(s)
PYEOF

# --- bump plugin.json (targeted replace; preserves formatting) -------------
python3 - "$VERSION" <<'PYEOF'
import re, sys
version = sys.argv[1]
p = '.claude-plugin/plugin.json'
s = open(p).read()
s2 = re.sub(r'"version": "[^"]+"', f'"version": "{version}"', s, count=1)
assert s != s2, "version field not found in plugin.json"
open(p,'w').write(s2)
PYEOF

# --- commit, tag, push ------------------------------------------------------
git add CHANGELOG.md .claude-plugin/plugin.json
git commit -q -m "release: $TAG"
git tag -a "$TAG" -m "$FULL_TITLE"
git push origin main "$TAG"

# --- GitHub Release ----------------------------------------------------------
NOTES="$(awk -v v="$VERSION" '$0 ~ "^## \\["v"\\]"{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | sed '/^<!--/d')"
if [ -n "$LAST_TAG" ]; then
  NOTES="$NOTES

**Full Changelog**: https://github.com/dralgorhythm/claude-agentic-framework/compare/$LAST_TAG...$TAG"
fi
printf '%s\n' "$NOTES" | gh release create "$TAG" --title "$FULL_TITLE" --notes-file -

echo ""
echo "Released $TAG."
echo "  Raw adopters : git pull their clone and re-run scripts/init-framework.sh (or pin with: git checkout $TAG)"
echo "  Plugin users : /plugin update now delivers $VERSION"
