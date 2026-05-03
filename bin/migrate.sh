#!/usr/bin/env bash
# migrate.sh — Initial seed: clone the morphia repo and convert AsciiDoc → Markdown.
#
# Usage:
#   REMOTE_REPO=https://github.com/MorphiaOrg/morphia.git bin/migrate.sh [branch ...]
#
# If no branches are specified, migrates: master 2.5.x 2.4.x
# Requires: git, pandoc (>= 3.0), sed, awk
#
# After migration the branches/ folders become the source of truth.
# Run this script only once for the initial seed; edit files in branches/ directly afterwards.

set -euo pipefail

REPO="${REMOTE_REPO:-https://github.com/MorphiaOrg/morphia.git}"
CLONE_DIR="build/morphia-src"
BRANCHES=("${@:-master 2.5.x 2.4.x}")
# Support space-separated string from env
if [[ ${#BRANCHES[@]} -eq 1 && "${BRANCHES[0]}" == *" "* ]]; then
  read -ra BRANCHES <<< "${BRANCHES[0]}"
fi

check_deps() {
  for cmd in git pandoc sed awk; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: $cmd is required but not found."; exit 1; }
  done
  local pv
  pv=$(pandoc --version | head -1 | awk '{print $2}')
  echo "pandoc $pv found"
}

clone_or_update() {
  if [[ ! -d "$CLONE_DIR/.git" ]]; then
    echo "Cloning $REPO ..."
    git clone "$REPO" --no-single-branch --depth 1 "$CLONE_DIR"
  else
    echo "Fetching latest from $REPO ..."
    git -C "$CLONE_DIR" fetch --all --quiet
  fi
}

# Convert a single AsciiDoc file to Markdown, writing to $DEST.
convert_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  # pandoc converts AsciiDoc → CommonMark
  pandoc \
    --from=asciidoc \
    --to=commonmark+pipe_tables+fenced_code_attributes \
    --wrap=none \
    --output="$dest" \
    "$src"

  # Post-processing: translate Antora xref: links → relative markdown links
  sed -i \
    -e 's|xref:\([^[]*\)\[\([^]]*\)\]|[\2](\1.md)|g' \
    "$dest"

  # Post-processing: translate include::example$<file>[] → Hugo shortcode
  sed -i \
    -e 's|include::example\$\([^[]*\)\[\]|{{< include-code file="\1" >}}|g' \
    "$dest"

  # Post-processing: translate AsciiDoc callout markers in code blocks.
  # Markers like // <1> are left as-is (plain comments); annotation lines
  # "<1> Some text" below the block become callout-item shortcodes.
  # This is handled by a small awk program.
  awk '
    /^\s*<[0-9]+>/ {
      n = $0
      sub(/^\s*<([0-9]+)>/, "", n)
      num = $0
      sub(/^\s*</, "", num); sub(/>.*/, "", num)
      sub(/^\s*<[0-9]+>\s*/, "", n)
      print "{{< callout-item " num " >}}" n "{{< /callout-item >}}"
      next
    }
    { print }
  ' "$dest" > "${dest}.tmp" && mv "${dest}.tmp" "$dest"
}

migrate_branch() {
  local branch="$1"
  local dest_dir="branches/$branch"
  local src_docs="$CLONE_DIR/docs/modules/ROOT/pages"
  local src_examples="$CLONE_DIR/docs/modules/ROOT/examples"

  echo ""
  echo "==> Migrating branch: $branch"

  git -C "$CLONE_DIR" checkout "$branch" --quiet
  git -C "$CLONE_DIR" pull --rebase --quiet

  if [[ ! -d "$src_docs" ]]; then
    echo "  WARNING: $src_docs not found; skipping."
    return
  fi

  # Extract version from pom.xml (major.minor only)
  local version=""
  if [[ -f "$CLONE_DIR/pom.xml" ]]; then
    version=$(awk '/<version>/{gsub(/<\/?version>/,""); gsub(/[[:space:]]/,""); v=$0}
                   /<\/project>/{print v; exit}' "$CLONE_DIR/pom.xml" 2>/dev/null | head -1)
    version=$(echo "$version" | sed 's/-SNAPSHOT//' | sed 's/\([0-9]*\.[0-9]*\).*/\1/')
  fi
  [[ -z "$version" ]] && version=$(echo "$branch" | sed 's/\.x$//' | sed 's/^master$/dev/')
  echo "  Version: $version"
  echo "$version" > "$dest_dir/.version"

  # Convert pages
  local count=0
  while IFS= read -r -d '' adoc; do
    local rel="${adoc#$src_docs/}"
    local md_rel="${rel%.adoc}.md"
    # nav.adoc → skip (will be reconstructed from page weights)
    [[ "$rel" == "nav.adoc" ]] && continue
    convert_file "$adoc" "$dest_dir/$md_rel"
    (( count++ ))
  done < <(find "$src_docs" -name "*.adoc" -print0)
  echo "  Converted $count page(s)."

  # Copy example source files
  if [[ -d "$src_examples" ]]; then
    mkdir -p "$dest_dir/examples"
    cp -r "$src_examples/." "$dest_dir/examples/"
    echo "  Copied examples."
  fi

  # Rename index.adoc → _index.md if present
  [[ -f "$dest_dir/index.md" && ! -f "$dest_dir/_index.md" ]] && mv "$dest_dir/index.md" "$dest_dir/_index.md"

  echo "  Done."
}

# ── Main ──

check_deps
mkdir -p build
clone_or_update

for branch in "${BRANCHES[@]}"; do
  migrate_branch "$branch"
done

echo ""
echo "Migration complete. Review branches/ and adjust front matter / links as needed."
echo "Run 'make site' to build the Hugo site."
