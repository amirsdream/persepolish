"""
fix_fill_blank_sentences.py

Second-pass cleaner for fill_blank exercises after migrate_fill_blank.py.

Problem: some `sentence` fields still contain an English/Persian narrative
sentence BEFORE the Polish sentence, e.g.:

    "sentence": "Piotr is a doctor. On ___ lekarzem."

The narrative "Piotr is a doctor." should live in `context`, not `sentence`.

Rule: if `sentence` contains '. ' before '___', split at the LAST '. '
before '___' — everything before it moves to the front of `context`,
everything from the split onward stays as `sentence`.

We also infer context_fa using a simple pattern dictionary for the most
common narrative suffixes (Complete → Kامل کنید, etc.).

Run from the repo root:
    python scripts/fix_fill_blank_sentences.py
"""

import json
import glob
import sys
import os

GLOB = "assets/content/a1/grammar/*.json"

# Common English instruction suffixes → Persian equivalents
INSTRUCTION_FA = {
    "complete:": "کامل کنید:",
    "complete the sentence:": "جمله را کامل کنید:",
    "fill in:": "پر کنید:",
    "fill in the blank:": "جای خالی را پر کنید:",
    "says:": "می‌گوید:",
    "says to kasia:": "به کاسیا می‌گوید:",
    "says to tomek:": "به تامک می‌گوید:",
}


def to_fa_instruction(context_en: str) -> str:
    """Best-effort: replace known English instruction tail with Persian."""
    lower = context_en.lower()
    for en, fa in INSTRUCTION_FA.items():
        if lower.endswith(en):
            prefix = context_en[: len(context_en) - len(en)].rstrip()
            return (prefix + " " + fa).strip() if prefix else fa
    # Generic fallback: append the standard Persian instruction
    return context_en + " کامل کنید:"


def split_sentence(sentence: str):
    """
    If `sentence` has '. ' before '___', return (narrative, polish).
    Otherwise return ('', sentence).
    """
    blank_idx = sentence.find("___")
    if blank_idx < 0:
        return ("", sentence)

    before = sentence[:blank_idx]
    last_period_space = before.rfind(". ")
    if last_period_space < 0:
        return ("", sentence)

    narrative = sentence[: last_period_space + 1].strip()   # "Piotr is a doctor."
    polish = sentence[last_period_space + 2 :]               # "On ___ lekarzem."
    return (narrative, polish)


def fix_exercise(ex: dict) -> dict:
    if ex.get("type") != "fill_blank":
        return ex

    sentence = ex.get("sentence", "")
    narrative, clean_sentence = split_sentence(sentence)

    if not narrative:
        return ex  # nothing to fix

    # Build updated context
    old_context = ex.get("context", "").strip()
    if old_context:
        new_context = f"{narrative} {old_context}"
    else:
        new_context = f"{narrative} Complete:"

    # Build updated context_fa
    old_context_fa = ex.get("context_fa", "").strip()
    if old_context_fa and old_context_fa not in (
        "جمله را کامل کنید:",
        "کامل کنید:",
    ):
        # already has real Persian context — keep it but note the narrative is missing
        new_context_fa = old_context_fa
    else:
        new_context_fa = to_fa_instruction(new_context)

    new_ex = dict(ex)
    new_ex["context"] = new_context
    new_ex["context_fa"] = new_context_fa
    new_ex["sentence"] = clean_sentence
    new_ex["prompt"] = clean_sentence
    new_ex["prompt_fa"] = clean_sentence
    return new_ex


def fix_file(path: str) -> int:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    key = "exercises" if "exercises" in data else None
    if key is None:
        return 0

    changed = 0
    new_exercises = []
    for ex in data[key]:
        new_ex = fix_exercise(ex)
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
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    pattern = os.path.join(repo_root, GLOB)
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"No files matched: {pattern}")
        sys.exit(1)

    total = 0
    for path in files:
        n = fix_file(path)
        if n:
            fname = os.path.basename(path)
            print(f"  {fname}: {n} exercise(s) fixed")
            total += n

    if total == 0:
        print("No exercises needed fixing.")
    else:
        print(f"\nDone. {total} exercise(s) fixed across A1 grammar files.")


if __name__ == "__main__":
    main()
