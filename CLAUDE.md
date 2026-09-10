# CLAUDE.md — Podcasterium

## Language rule (permanent, non-negotiable)

**Everything persisted to disk in this repository is written in English. 100 %.
No exceptions.**

This covers: source code (identifiers, comments, doc comments, log messages,
error strings), commit messages, pull request titles and bodies, Markdown
documentation, ARB/i18n *template* files, YAML/JSON/config comments, scripts
and their `--help` output, test names, issue and changelog text, asset file
names, and anything else that ends up in `git`.

Rationale: Podcasterium is a **fully open-source project intended for a
global audience**. Anyone in the world must be able to read, run, review and
contribute to it without knowing Croatian.

This is the explicit opposite of the upstream project `domovina.ai`
(`/Users/ms/git/domovinatv/domovina.ai`), where code comments, docs and
commits are in Croatian. When porting or merging anything from upstream,
**translate it** — do not carry Croatian text into this repository.

What the rule does **not** cover:

- The owner prompts in Croatian and may want chat replies in Croatian. That
  is conversation, not persistence — reply in whatever language the owner
  uses, but write to disk in English.
- Localized *translation* files for end users (e.g. `app_hr.arb`) naturally
  contain Croatian strings. The **template** file is English
  (`app_en.arb`), and every key name, description and placeholder comment is
  English.
- Code identifiers inherited verbatim from upstream that are still in
  Croatian (e.g. the `/glasanje` route) may be cited in docs as-is while they
  exist; new identifiers are English, and inherited ones are renamed when the
  feature is touched.
- Quoted proper nouns and product names (DOMOVINA.ai, Magisterium, Pinka,
  e-Osobna, ITalk d.o.o.) stay as they are.

Before finishing any task that writes files, check:

```bash
# should return nothing (crude check for Croatian diacritics in tracked text)
git grep -nI '[čćžšđČĆŽŠĐ]' -- ':!*.arb' ':!*hr*.md' | head
```

If a file must legitimately contain Croatian (a Croatian translation file, a
quoted Croatian source), say so in the file header.

## Project context

Podcasterium is a global, brand-neutral fork of the Flutter application
DOMOVINA.ai — watch, listen to and **read** podcasts (video plus AI article
by chapter, diarized speakers, person hub, keyword and semantic search,
Android TV, background audio). See `README.md` and `docs/` for the analysis
and the plan. No application code exists in this repository yet.

Relationship to upstream: `docs/08-white-label-architecture.md` — upstream
extracts its `lib/` into a `podcast_core` package; this repository is a thin
white-label shell that depends on that package by pinned git tag and holds
**no application code** (only `main.dart`, a `BrandConfig`, platform
directories, brand and store assets). Never copy core files into this repo.

## Documentation rules (inherited from upstream, kept)

- Documentation is verified, not trusted. Every `lib/…`, `android/…`,
  `ios/…`, `web/…`, `scripts/…` path cited in `docs/` refers to the upstream
  repository and must exist there on the day of writing. Check with
  `./scripts/verify-doc-refs.sh` run from the upstream repo against these
  files.
- Every number with a decimal, and every count, has a command that
  reproduces it (see `docs/00-source-app-analysis.md` §9).
- Effort estimates are labelled as estimates.

## Git

- Commit messages in English, imperative mood, with a scope prefix
  (`docs:`, `brand:`, `android:`, `ios:`, `web:`, `ci:`).
- End commit messages with the AI co-author trailer required by the session.
- One semantic commit per logical change (one document, one config change),
  not one commit per session.
- Commits are GPG-signed (`commit.gpgsign=true`, key
  `F9968089DBE3338732A53F663420E392053523AF`). Two gotchas measured on
  10 Sep 2026:
  - If the key is locked, `git commit` blocks on a pinentry prompt that a
    non-interactive shell never sees. Check first with
    `echo x | gpg --batch --pinentry-mode error -u <key> --clearsign`;
    if it fails, the owner unlocks the key in a terminal, then retry.
  - Do **not** wrap `git commit` in `timeout` (coreutils) — the commit hangs
    even with an unlocked key. Run `git commit` plainly, with `</dev/null`.
- The `verify-doc-refs.sh` check and the diacritics grep run before every
  docs commit.
