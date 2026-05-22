"""
migrate_fill_blank.py

Migrates all fill_blank exercises in the A1 grammar JSON files from the old
combined-prompt format to the new structured schema:

  OLD:
    "prompt": "Kasia travels by train. Complete: Jadę ___ (by train). [pociąg → instrumental]"
    "prompt_fa": "کاسیا با قطار می‌رود. کامل کنید: Jadę ___ (با قطار). [pociąg → ابزاری]"

  NEW:
    "context":        "Kasia travels by train. Complete:"
    "context_fa":     "کاسیا با قطار می‌رود. کامل کنید:"
    "sentence":       "Jadę ___ ."
    "translation":    "(by train) [pociąg → instrumental]"
    "translation_fa": "(با قطار) [pociąg → ابزاری]"
    "prompt":         "Jadę ___ ."   ← kept for backward compat, now = sentence
    "prompt_fa":      "Jadę ___ ."   ← same Polish sentence for both langs

Run from the repo root:
    python scripts/migrate_fill_blank.py
"""

import json
import glob
import re
import sys
import os

GLOB = r"assets/content/a1/grammar/*.json"


def split_prompt(prompt: str):
    """
    Returns (context, sentence, translation) from a raw prompt string.

    Format A: "Context. Complete: Polish_start ___ Polish_end (translation). [grammar]"
    Format B: "Polish_start ___ Polish_end. (translation) [grammar]"
    """
    if "___" not in prompt:
        # No blank — treat whole thing as sentence, no context/translation
        return ("", prompt.strip(), "")

    before, after = prompt.split("___", 1)

    # ── Extract context from 'before' ────────────────────────────────────
    last_colon = before.rfind(":")
    if last_colon != -1:
        context = before[:last_colon + 1].strip()
        polish_start = before[last_colon + 1:].lstrip()
    else:
        context = ""
        polish_start = before

    # ── Extract translation from 'after' ─────────────────────────────────
    # Translation/grammar notes start at the first '(' or '[' in 'after'
    p_idx = after.find("(")
    b_idx = after.find("[")

    if p_idx >= 0 and b_idx >= 0:
        split_at = min(p_idx, b_idx)
    elif p_idx >= 0:
        split_at = p_idx
    elif b_idx >= 0:
        split_at = b_idx
    else:
        split_at = -1

    if split_at >= 0:
        polish_end = after[:split_at].rstrip()
        translation = after[split_at:].strip()
    else:
        polish_end = after.rstrip()
        translation = ""

    sentence = f"{polish_start}___{polish_end}".strip()
    return (context, sentence, translation)


def migrate_exercise(ex: dict) -> dict:
    if ex.get("type") != "fill_blank":
        return ex

    # Skip if already migrated
    if "sentence" in ex:
        return ex

    prompt_en = ex.get("prompt", "")
    prompt_fa = ex.get("prompt_fa", "")

    context_en, sentence_en, translation_en = split_prompt(prompt_en)
    context_fa, sentence_fa, translation_fa = split_prompt(prompt_fa)

    # The sentence is always Polish — use the English split (Polish text
    # is identical in both prompt and prompt_fa for the sentence part)
    sentence = sentence_en

    # Build new exercise dict preserving all existing keys in order
    new_ex = {}
    for key in ex:
        if key in ("prompt", "prompt_fa"):
            continue  # we'll re-add them below
        new_ex[key] = ex[key]

    # Insert structured fields after 'order'
    new_ex["context"] = context_en
    new_ex["context_fa"] = context_fa
    new_ex["sentence"] = sentence
    new_ex["translation"] = translation_en
    new_ex["translation_fa"] = translation_fa
    # Keep prompt / prompt_fa pointing to the bare sentence for backward compat
    new_ex["prompt"] = sentence
    new_ex["prompt_fa"] = sentence

    return new_ex


def migrate_file(path: str) -> int:
    """Returns number of exercises migrated."""
    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    key = "exercises" if "exercises" in data else None
    if key is None:
        return 0

    changed = 0
    new_exercises = []
    for ex in data[key]:
        new_ex = migrate_exercise(ex)
        if new_ex is not ex:
            changed += 1
        new_exercises.append(new_ex)

    if changed == 0:
        return 0

    data[key] = new_exercises
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    return changed


def main():
    # Run from repo root
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    pattern = os.path.join(repo_root, GLOB)
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"No files matched: {pattern}")
        sys.exit(1)

    total = 0
    for path in files:
        n = migrate_file(path)
        if n:
            fname = os.path.basename(path)
            print(f"  {fname}: {n} exercise(s) migrated")
            total += n

    print(f"\nDone. {total} fill_blank exercise(s) migrated across {len(files)} files.")


if __name__ == "__main__":
    main()
