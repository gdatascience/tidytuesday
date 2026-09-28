# Writing Style: Sound Human, Not AI

All human-readable prose in this project must read like a person wrote it, not a
language model. This applies to every place a reader (especially a TidyTuesday
maintainer reviewing a submission) sees words: `intro.md`, dataset dictionaries,
`meta.yaml` (titles + image alt text), week `README.md` blurbs and narrative,
social posts, PR titles and descriptions, and the text baked into chart titles,
subtitles, and captions.

Context: the TidyTuesday maintainer has flagged past submissions as sounding too
much like AI (em-dashes and similar tells). Take this seriously, because it
affects whether submissions are accepted.

## Hard rules

- **Never use em-dashes (—) or en-dashes (–) in prose.** Use a period, a comma,
  a colon, or parentheses instead. En-dashes in numeric ranges are also out;
  write "0 to 100" not "0–100", and "2014 to 2019" not "2014–2019".
- **Avoid the em-dash-as-dramatic-pause move entirely**, even rewritten with
  commas (e.g. "the twist, it turns out, is..."). Just state the point plainly.
- **No unicode math/symbol shorthand in prose or chart text.** Write "about 0.01"
  not "≈ 0.01", "and" not "&" in sentences (an ampersand inside a citation like
  "Felten, Raj & Seamans" is fine).
- **Cut the AI throat-clearing and stock flourishes.** Phrases to avoid:
  "The twist:", "What stands out is", "It's worth noting", "Notably,",
  "In today's world", "dive into", "delve", "unpack", "landscape", "realm",
  "testament to", "at the end of the day", scare-quoted "dream quadrant" style
  labels, and overly balanced "not only X but also Y" / "X, meanwhile Y"
  constructions used just for rhythm.
- **Avoid the rule-of-three cadence** and perfectly parallel sentence structures
  that AI tends to fall into. Vary sentence length. Let some sentences be short.

## Positive guidance

- Write plainly and directly, like explaining the dataset to a colleague.
- First person is good ("I joined three sources", "I used the crosswalk").
- Prefer concrete numbers and specific major/occupation names over abstract
  summary language.
- Contractions are fine and read as more human ("don't", "it's").
- Read a draft out loud in your head. If a sentence sounds like a press release
  or a model's summary, rewrite it shorter and blunter.

## Before submitting or publishing prose, check

1. Scan the submission/text files for em-dash and en-dash and confirm zero. Use
   Python for the check, since the zsh `$'\u2014'` escape silently fails to match
   and gives a false all-clear:
   ```bash
   python3 - <<'PY'
   import glob
   for f in glob.glob("tt_submission/*.md") + glob.glob("tt_submission/*.yaml"):
       t = open(f, encoding="utf-8").read()
       n = t.count("\u2014") + t.count("\u2013")
       if n: print(f, n)
   PY
   ```
   Any file that prints has dashes left to fix. No output means clean.
2. Re-scan chart scripts (`make_image.R` and any plotting `.R`) for the escaped
   forms `\u2014`, `\u2013`, and `\u2248`. They hide in `subtitle`/`caption`
   strings and render into the final PNG:
   ```bash
   grep -n 'u2014\|u2013\|u2248' *.R
   ```
3. Skim for the stock phrases listed above and remove them.

This check is part of the dataset-curation and blog-post finalization workflows,
not an optional extra.
