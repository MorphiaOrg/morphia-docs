#!/usr/bin/env python3
"""
adoc2md.py — Convert Morphia/Antora AsciiDoc to Hugo-flavoured Markdown.

Usage:
    python3 bin/adoc2md.py input.adoc [output.md] [--weight N] [--attrs k=v,...]
    python3 bin/adoc2md.py input.adoc   # writes to stdout
"""

import re
import sys
import os
import yaml

# ── Admonition type mapping ───────────────────────────────────────────────────
ADMONITION_TYPES = {
    "NOTE": "note",
    "TIP": "tip",
    "WARNING": "warning",
    "CAUTION": "warning",
    "IMPORTANT": "warning",
}

# ── State constants ───────────────────────────────────────────────────────────
S_NORMAL  = "normal"
S_CODE    = "code"
S_LITERAL = "literal"
S_ADMON   = "admon"
S_TABLE   = "table"
S_EXAMPLE = "example"
S_QUOTE   = "quote"


def load_antora_attrs(antora_yml_path: str) -> dict:
    """Extract asciidoc attribute overrides from an antora.yml file."""
    if not os.path.exists(antora_yml_path):
        return {}
    with open(antora_yml_path, encoding='utf-8') as f:
        data = yaml.safe_load(f)
    attrs = {}
    if isinstance(data, dict):
        attrs['version'] = str(data.get('version', ''))
        asciidoc = data.get('asciidoc', {}) or {}
        for k, v in (asciidoc.get('attributes', {}) or {}).items():
            attrs[k] = str(v)
    return attrs


def convert(text: str, global_attrs: dict = None, pages_dir: str = None) -> tuple:
    """Return (title, markdown_body).

    global_attrs: pre-seeded attributes from antora.yml
    pages_dir:    directory of the source file (for resolving inline includes)
    """
    lines = text.splitlines()
    out = []
    title = ""
    attrs: dict = dict(global_attrs or {})

    state = S_NORMAL
    code_lang = ""
    admon_type = ""
    admon_title = ""
    admon_buf: list = []
    table_buf: list = []
    pending_block_title = ""
    pending_block_attrs = ""
    in_callout_list = False

    i = 0
    while i < len(lines):
        line = lines[i]

        # ── Document attribute definitions (:attr: value) and (:!attr:) ────────
        if state == S_NORMAL:
            m = re.match(r'^:([^:\n]+)!?: *(.*)', line)
            if m:
                key = m.group(1).strip().rstrip('!')
                attrs[key] = m.group(2).strip()
                i += 1
                continue
            # bare :!attr: or :attr:  (no value)
            if re.match(r'^:[^:\n]+!?:$', line):
                i += 1
                continue

        def subst(s):
            def repl(m2):
                return attrs.get(m2.group(1), m2.group(0))
            return re.sub(r'\{([a-zA-Z0-9_-]+)\}', repl, s)

        # ── Conditional blocks ────────────────────────────────────────────────
        if state == S_NORMAL and re.match(r'^ifn?def::', line):
            # skip single-line ifdef::x[content] form
            if re.match(r'^ifn?def::[^\[]*\[.+\]', line):
                i += 1
                continue
            depth = 1
            i += 1
            while i < len(lines) and depth > 0:
                if re.match(r'^ifn?def::', lines[i]):
                    depth += 1
                elif lines[i].startswith('endif::'):
                    depth -= 1
                i += 1
            continue

        if state == S_NORMAL and line.startswith('endif::'):
            i += 1
            continue

        # ── Comments ─────────────────────────────────────────────────────────
        if state == S_NORMAL and re.match(r'^//(?! <)', line):
            i += 1
            continue

        # ── Document title ────────────────────────────────────────────────────
        if state == S_NORMAL and re.match(r'^= [^\n]', line):
            title = line[2:].strip()
            i += 1
            continue

        # ── Section headings ──────────────────────────────────────────────────
        if state == S_NORMAL:
            m = re.match(r'^(={2,6}) (.+)', line)
            if m:
                hashes = '#' * len(m.group(1))
                out.append(f"{hashes} {subst(m.group(2)).strip()}")
                in_callout_list = False
                i += 1
                continue

        # ── Horizontal rule ───────────────────────────────────────────────────
        if state == S_NORMAL and line.strip() == "'''":
            out.append("---")
            i += 1
            continue

        # ── Block attribute line ──────────────────────────────────────────────
        if state == S_NORMAL and re.match(r'^\[', line):
            pending_block_attrs = line.strip()
            i += 1
            continue

        # ── Block title ───────────────────────────────────────────────────────
        if state == S_NORMAL and re.match(r'^\.[A-Za-z]', line) and not line.startswith('..'):
            pending_block_title = line[1:].strip()
            i += 1
            continue

        # ── Inline include of another page: include::page.adoc[] ─────────────
        if state == S_NORMAL and re.match(r'^include::(?!example\$)(?!partial\$)', line):
            m = re.match(r'^include::([^\[]+\.adoc)\[\]?', line)
            if m and pages_dir:
                inc_path = os.path.join(pages_dir, m.group(1))
                if os.path.exists(inc_path):
                    with open(inc_path, encoding='utf-8', errors='replace') as f:
                        inc_text = f.read()
                    _, inc_body = convert(inc_text, global_attrs=global_attrs, pages_dir=pages_dir)
                    out.append('')
                    out.append(inc_body.strip())
                    out.append('')
                    i += 1
                    continue
            # If we can't resolve it, skip
            i += 1
            continue

        # ── Admonition block [NOTE/TIP/…] ==== ───────────────────────────────
        if state == S_NORMAL and pending_block_attrs and line.strip() == '====':
            attr = pending_block_attrs.strip('[]').split(',')[0].upper()
            if attr in ADMONITION_TYPES:
                state = S_ADMON
                admon_type = ADMONITION_TYPES[attr]
                admon_title = attr.title()
                admon_buf = []
                pending_block_attrs = ""
                i += 1
                continue

        # ── Source / listing block ─────────────────────────────────────────────
        if state == S_NORMAL and line.strip() in ('----', '....'):
            lang = ""
            if pending_block_attrs:
                m = re.match(r'\[(?:source|listing)(?:,([^,\]\n]+))?', pending_block_attrs, re.I)
                if m and m.group(1):
                    lang = m.group(1).strip()
            delim = line.strip()
            state = S_CODE if delim == '----' else S_LITERAL
            code_lang = lang
            if pending_block_title:
                out.append(f"**{pending_block_title}**")
                pending_block_title = ""
            out.append(f"```{code_lang}" if code_lang else "```")
            pending_block_attrs = ""
            i += 1
            continue

        # ── Example / quote block ==== ────────────────────────────────────────
        if state == S_NORMAL and line.strip() == '====':
            if '[quote' in pending_block_attrs.lower():
                state = S_QUOTE
            else:
                state = S_EXAMPLE
            pending_block_attrs = ""
            pending_block_title = ""
            i += 1
            continue

        # ── Table |=== ────────────────────────────────────────────────────────
        if state == S_NORMAL and line.strip() == '|===':
            state = S_TABLE
            table_buf = []
            pending_block_attrs = ""
            i += 1
            continue

        # ── Inline admonition ─────────────────────────────────────────────────
        if state == S_NORMAL:
            m = re.match(r'^(NOTE|TIP|WARNING|CAUTION|IMPORTANT): (.+)', line)
            if m:
                atype = ADMONITION_TYPES[m.group(1)]
                atitle = m.group(1).title()
                content = convert_inline(subst(m.group(2)), attrs)
                out.append(f'{{{{< admonition type="{atype}" title="{atitle}" >}}}}')
                out.append(content)
                out.append('{{< /admonition >}}')
                i += 1
                continue

        # ── STATE: TABLE ──────────────────────────────────────────────────────
        if state == S_TABLE:
            if line.strip() == '|===':
                out.extend(render_table(table_buf))
                state = S_NORMAL
            else:
                table_buf.append(line)
            i += 1
            continue

        # ── STATE: ADMON ──────────────────────────────────────────────────────
        if state == S_ADMON:
            if line.strip() == '====':
                body_text = '\n'.join(admon_buf)
                _, body_md = convert(body_text, global_attrs=global_attrs, pages_dir=pages_dir)
                out.append(f'{{{{< admonition type="{admon_type}" title="{admon_title}" >}}}}')
                out.append(body_md.strip())
                out.append('{{< /admonition >}}')
                admon_buf = []
                state = S_NORMAL
            else:
                admon_buf.append(line)
            i += 1
            continue

        # ── STATE: EXAMPLE ────────────────────────────────────────────────────
        if state == S_EXAMPLE:
            if line.strip() == '====':
                state = S_NORMAL
            else:
                out.append(convert_inline(subst(line), attrs))
            i += 1
            continue

        # ── STATE: QUOTE ──────────────────────────────────────────────────────
        if state == S_QUOTE:
            if line.strip() == '====':
                state = S_NORMAL
            else:
                out.append('> ' + convert_inline(subst(line), attrs))
            i += 1
            continue

        # ── STATE: CODE/LITERAL ───────────────────────────────────────────────
        if state in (S_CODE, S_LITERAL):
            end_delim = '----' if state == S_CODE else '....'
            if line.strip() == end_delim:
                out.append('```')
                state = S_NORMAL
                in_callout_list = False
            elif re.match(r'^include::example\$', line):
                # include::example$file[opts] inside a code block
                # Close the current block, emit shortcode, reopen with same lang
                out.append('```')
                m_inc = re.match(r'^include::example\$([^\[\n]+)\[([^\]\n]*)\]', line)
                if m_inc:
                    fname, opts = m_inc.group(1), m_inc.group(2)
                    tag_m = re.search(r'tag=([^\],\s]+)', opts)
                    if tag_m:
                        shortcode = f'{{{{< include-code file="{fname}" tag="{tag_m.group(1)}" >}}}}'
                    else:
                        shortcode = f'{{{{< include-code file="{fname}" >}}}}'
                    out.append(shortcode)
                # Peek ahead — reopen code block only if next non-empty line isn't
                # the closing delimiter
                peek = lines[i + 1] if i + 1 < len(lines) else ''
                if peek.strip() != end_delim and peek.strip():
                    out.append(f'```{code_lang}' if code_lang else '```')
                else:
                    # closing delim follows immediately — skip it and reset state
                    state = S_NORMAL
                    i += 1  # skip the closing delim line
            else:
                # Apply attribute substitutions inside code blocks (e.g. {version})
                out.append(subst(line))
            i += 1
            continue

        # ── Callout annotations <N> text ──────────────────────────────────────
        if state == S_NORMAL:
            m = re.match(r'^<(\d+)> (.*)', line)
            if m:
                num, text = m.group(1), convert_inline(subst(m.group(2)), attrs)
                out.append(f'{{{{< callout-item {num} >}}}}{text}{{{{< /callout-item >}}}}')
                in_callout_list = True
                i += 1
                continue
            if in_callout_list and line.strip():
                in_callout_list = False

        # ── List items ────────────────────────────────────────────────────────
        if state == S_NORMAL:
            m = re.match(r'^(\*+) (.+)', line)
            if m:
                depth = len(m.group(1))
                indent = '  ' * (depth - 1)
                out.append(f"{indent}- {convert_inline(subst(m.group(2)), attrs)}")
                i += 1
                continue

            m = re.match(r'^(\.+) (.+)', line)
            if m:
                depth = len(m.group(1))
                indent = '  ' * (depth - 1)
                out.append(f"{indent}1. {convert_inline(subst(m.group(2)), attrs)}")
                i += 1
                continue

            # Description list term:: (avoid matching URLs)
            m = re.match(r'^([^:]{1,80})::$', line)
            if m and not line.startswith('http') and '://' not in line:
                out.append(f"**{convert_inline(subst(m.group(1)), attrs)}**")
                i += 1
                continue

        # ── Normal line ───────────────────────────────────────────────────────
        if state == S_NORMAL:
            out.append(convert_inline(subst(line), attrs))
            i += 1
            continue

        i += 1

    return title, '\n'.join(out)


def convert_inline(s: str, attrs: dict = None) -> str:
    """Convert inline AsciiDoc markup to Markdown."""
    if attrs is None:
        attrs = {}

    # include::example$file[] or include::example$file[tag=name] → shortcode
    def include_repl(m):
        fname, opts = m.group(1), m.group(2)
        tag_m = re.search(r'tag=([^\],\s]+)', opts)
        if tag_m:
            return f'{{{{< include-code file="{fname}" tag="{tag_m.group(1)}" >}}}}'
        return f'{{{{< include-code file="{fname}" >}}}}'
    s = re.sub(r'include::example\$([^\[\n]+)\[([^\]\n]*)\]', include_repl, s)
    # include::partial$... → omit
    s = re.sub(r'include::partial\$[^\[\n]+\[[^\]\n]*\]', '', s)

    # xref:page.adoc[Text] or xref:page.adoc#anchor[Text]
    def xref_repl(m):
        page = re.sub(r'\.adoc(#.*)?$', lambda x: x.group(1) or '', m.group(1))
        text = m.group(2).strip()
        if not text:
            text = page.split('#')[0].replace('-', ' ').replace('_', ' ').title()
        anchor = ''
        if '#' in page:
            page, anchor = page.split('#', 1)
            anchor = '#' + anchor.lower().replace(' ', '-')
        return f'[{text}](../{page}/{anchor})'
    s = re.sub(r'xref:([^\[\n]+\.adoc[^\[\n]*)\[([^\]\n]*)\]', xref_repl, s)

    # link:url[Text] — handles both absolute URLs and relative paths (javadoc etc.)
    def link_repl(m):
        url, text = m.group(1), m.group(2).strip()
        if not text:
            text = url.split('/')[-1] or url
        return f'[{text}]({url})'
    s = re.sub(r'link:([^\[\n]+)\[([^\]\n]*)\]', link_repl, s)

    # https?://url[Text]
    s = re.sub(r'(https?://[^\[\s<>]+)\[([^\]\n]+)\]',
               lambda m: f'[{m.group(2)}]({m.group(1)})', s)

    # <<anchor,text>> or <<anchor>>
    def anchor_repl(m):
        parts = m.group(1).split(',', 1)
        anchor = parts[0].strip().replace(' ', '-').lower()
        text = parts[1].strip() if len(parts) > 1 else parts[0].strip()
        return f'[{text}](#{anchor})'
    s = re.sub(r'<<([^>\n]+)>>', anchor_repl, s)

    # anchor:id[]
    s = re.sub(r'anchor:([^\[\n]+)\[\]', '', s)

    # Bold: *text* (not ** list)
    s = re.sub(r'(?<!\*)\*\*([^*\n]+)\*\*(?!\*)', r'**\1**', s)  # already **bold**
    s = re.sub(r'(?<![*\w])\*([^*\n]+)\*(?![*\w])', r'**\1**', s)

    # Italic: _text_ or __text__
    s = re.sub(r'__([^_\n]+)__', r'_\1_', s)
    s = re.sub(r'(?<![_\w])_([^_\n]+)_(?![_\w])', r'_\1_', s)

    # Monospace passthrough: +text+
    s = re.sub(r'(?<!\+)\+([^+\n]+)\+(?!\+)', r'`\1`', s)

    # path/to/something[Link text] where path starts with / or http — catch stragglers
    def path_link_repl(m):
        url, text = m.group(1), m.group(2).strip()
        if not text:
            return m.group(0)
        return f'[{text}]({url})'
    s = re.sub(r'(/[^\[\s<>]+|https?://[^\[\s<>]+)\[([^\]\n]+)\]', path_link_repl, s)

    # Remove leftover {attr} references
    s = re.sub(r'\{[a-zA-Z0-9_-]+\}', '', s)

    return s


def render_table(rows: list) -> list:
    """Naive AsciiDoc → GFM pipe table conversion."""
    cells = []
    col_count_hint = None
    options_seen = False

    for row in rows:
        # Skip cols= options lines
        if re.match(r'^\[', row):
            # Try to extract col count from cols="1,2,3" or cols="a,b,c"
            m = re.search(r'cols="([^"]+)"', row)
            if m:
                col_count_hint = len(m.group(1).split(','))
            options_seen = True
            continue
        row = row.strip()
        if not row:
            continue
        if row.startswith('|'):
            parts = re.split(r'(?<!\|)\|(?!\|)', row)[1:]
            cells.extend([p.strip() for p in parts if p.strip() or p == ''])

    if not cells:
        return []

    ncols = col_count_hint or max(2, len(cells) // max(1, len(rows) // 2))
    ncols = max(1, ncols)

    result = []
    row_chunks = [cells[j:j+ncols] for j in range(0, len(cells), ncols)]

    if not row_chunks:
        return []

    def fmt_row(r):
        padded = r + [''] * (ncols - len(r))
        return '| ' + ' | '.join(convert_inline(c) for c in padded) + ' |'

    result.append(fmt_row(row_chunks[0]))
    result.append('|' + '---|' * ncols)
    for r in row_chunks[1:]:
        result.append(fmt_row(r))

    return result


def make_front_matter(title: str, weight: int, description: str = "") -> str:
    safe_title = title.replace('"', '\\"')
    lines = ["---", f'title: "{safe_title}"']
    if description:
        safe_desc = description.replace('"', '\\"')
        lines.append(f'description: "{safe_desc}"')
    lines.append(f"weight: {weight}")
    lines.append("---")
    return '\n'.join(lines)


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output', nargs='?')
    parser.add_argument('--weight', type=int, default=50)
    parser.add_argument('--attrs', default='')
    parser.add_argument('--antora-yml', default='')
    args = parser.parse_args()

    global_attrs = {}
    if args.antora_yml:
        global_attrs.update(load_antora_attrs(args.antora_yml))
    if args.attrs:
        for kv in args.attrs.split(','):
            if '=' in kv:
                k, v = kv.split('=', 1)
                global_attrs[k.strip()] = v.strip()

    with open(args.input, 'r', encoding='utf-8', errors='replace') as f:
        text = f.read()

    pages_dir = os.path.dirname(os.path.abspath(args.input))
    title, body = convert(text, global_attrs=global_attrs, pages_dir=pages_dir)

    fm_title = title or os.path.splitext(os.path.basename(args.input))[0].replace('-', ' ').title()
    result = make_front_matter(fm_title, args.weight) + '\n\n' + body.strip() + '\n'

    if args.output:
        os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(result)
    else:
        sys.stdout.write(result)


if __name__ == '__main__':
    main()
