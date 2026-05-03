#!/usr/bin/env bash
# migrate.sh — Clone the morphia repo and seed branches/ with converted Markdown.
#
# Usage:
#   REMOTE_REPO=https://github.com/MorphiaOrg/morphia.git bin/migrate.sh [branch ...]
#   bin/migrate.sh                 # defaults to master 2.5.x 2.4.x
#
# Requires: git, python3 (with pyyaml), sed
#
# Run once for the initial seed. Edit branches/ directly afterwards.

set -euo pipefail

REPO="${REMOTE_REPO:-https://github.com/MorphiaOrg/morphia.git}"
CLONE_DIR="build/morphia-src"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_BRANCHES="master 2.5.x 2.4.x"
BRANCHES=("${@:-$DEFAULT_BRANCHES}")
if [[ ${#BRANCHES[@]} -eq 1 && "${BRANCHES[0]}" == *" "* ]]; then
  read -ra BRANCHES <<< "${BRANCHES[0]}"
fi

check_deps() {
  for cmd in git python3; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: $cmd is required."; exit 1; }
  done
  python3 -c "import yaml" 2>/dev/null || pip install --quiet pyyaml
}

clone_or_update() {
  cd "$ROOT_DIR"
  if [[ ! -d "$CLONE_DIR/.git" ]]; then
    echo "Cloning $REPO ..."
    git clone "$REPO" --no-single-branch --depth 1 --filter=blob:none --sparse "$CLONE_DIR"
  fi
  echo "Fetching all branches ..."
  git -C "$CLONE_DIR" sparse-checkout set docs/
  git -C "$CLONE_DIR" fetch --all --quiet
}

# Parse nav.adoc and return ordered page names with their depth
# Output: "<depth> <page-stem>" per line
parse_nav() {
  local nav_file="$1"
  python3 - "$nav_file" <<'PYEOF'
import re, sys
nav = open(sys.argv[1]).read()
weight = 10
for line in nav.split('\n'):
    m = re.match(r'^(\*+)\s+xref:([^\[]+\.adoc)[^\]]*\[', line)
    if m:
        depth = len(m.group(1))
        page = re.sub(r'\.adoc$', '', m.group(2))
        print(f"{weight} {page}")
        weight += 10
PYEOF
}

migrate_branch() {
  local branch="$1"
  cd "$ROOT_DIR"
  local dest_dir="branches/$branch"
  local src_root="$CLONE_DIR/docs"
  local src_pages="$src_root/modules/ROOT/pages"
  local src_examples="$src_root/modules/ROOT/examples"
  local antora_yml="$src_root/antora.yml"
  local nav_adoc="$src_root/modules/ROOT/nav.adoc"

  echo ""
  echo "==> Migrating branch: $branch"
  git -C "$CLONE_DIR" checkout "$branch" --quiet 2>/dev/null \
    || { echo "  SKIP: branch $branch not found"; return; }
  git -C "$CLONE_DIR" pull --rebase --quiet 2>/dev/null || true

  [[ -d "$src_pages" ]] || { echo "  SKIP: no docs/modules/ROOT/pages found"; return; }

  # Extract version (major.minor)
  local version=""
  version=$(python3 -c "
import yaml, sys
d = yaml.safe_load(open('$antora_yml'))
v = str(d.get('version',''))
import re; m = re.match(r'(\d+\.\d+)', v)
print(m.group(1) if m else '')
" 2>/dev/null || true)
  if [[ -z "$version" ]]; then
    # Fallback: derive from branch name
    version=$(echo "$branch" | sed 's/\.x$//' | grep -oP '\d+\.\d+' || echo "0.0")
  fi
  echo "  Version: $version"

  # Write .version file
  echo "$version" > "$dest_dir/.version"

  # Build weight map from nav.adoc
  declare -A WEIGHT_MAP
  if [[ -f "$nav_adoc" ]]; then
    while IFS=" " read -r wt page; do
      WEIGHT_MAP["$page"]="$wt"
    done < <(parse_nav "$nav_adoc")
  fi

  # Pages included inline by parent pages (skip as standalone)
  declare -A INLINE_PAGES
  for inline in query-filters update-operators aggregation-stages aggregation-expressions morphia-2.5-3.0-table; do
    INLINE_PAGES["$inline"]=1
  done

  # Convert each .adoc page
  local count=0
  while IFS= read -r -d '' adoc; do
    local rel="${adoc#$src_pages/}"
    local stem="${rel%.adoc}"

    # Skip nav.adoc
    [[ "$stem" == "nav" ]] && continue

    # Determine output path
    local md_out
    if [[ "$stem" == "index" ]]; then
      md_out="$dest_dir/_index.md"
    else
      md_out="$dest_dir/$stem.md"
    fi

    # Determine weight from nav
    local weight="${WEIGHT_MAP[$stem]:-50}"
    # Pages that exist but are NOT in nav (inline-included) get a high weight
    [[ -n "${INLINE_PAGES[$stem]:-}" ]] && weight=999

    python3 "$SCRIPT_DIR/adoc2md.py" \
      "$adoc" "$md_out" \
      --weight "$weight" \
      --antora-yml "$antora_yml" \
      --attrs "docsRef=https://docs.mongodb.com/manual" \
      2>/dev/null

    (( count++ )) || true
  done < <(find "$src_pages" -name "*.adoc" -print0)

  echo "  Converted $count page(s)."

  # Rename index.md → _index.md if the direct conversion didn't produce it
  [[ -f "$dest_dir/index.md" && ! -f "$dest_dir/_index.md" ]] \
    && mv "$dest_dir/index.md" "$dest_dir/_index.md"

  # Copy example source files
  if [[ -d "$src_examples" ]]; then
    mkdir -p "$dest_dir/examples"
    cp -r "$src_examples/." "$dest_dir/examples/"
    echo "  Copied $(ls "$src_examples" | wc -l) example file(s)."
  fi

  # Update Critter references in the converted Markdown
  echo "  Removing Critter references..."
  find "$dest_dir" -name "*.md" -exec sed -i \
    -e 's/\[Critter\]([^)]*critter[^)]*)/Morphia/gi' \
    -e 's/critter[[:space:]]*integration[[:space:]]*plan/Morphia integrated type-safe criteria/gi' \
    -e '/critter-integration-plan/d' \
    {} \;

  echo "  Done → $dest_dir"
}

# ── Main ──────────────────────────────────────────────────────────────────────
check_deps
cd "$ROOT_DIR"
mkdir -p build

clone_or_update

for branch in "${BRANCHES[@]}"; do
  migrate_branch "$branch"
done

# Regenerate version data
echo ""
echo "Regenerating data/versions.yaml ..."
make data/versions.yaml

echo ""
echo "Migration complete."
echo "Review branches/ and run 'make site' to build."
