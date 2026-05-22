"""
patch_content_fixes.py

Fixes content-level issues found in A1 fill_blank exercises after migration:
  - Scrambled context (ch06-l02-ex07 had colon inside "(f: starsza siostra)")
  - Empty context fields (ch03, ch08)
  - Sentences missing trailing period
  - Misplaced periods inside translation: "(by train). [pociąg →" → "(by train) [pociąg →"
  - Unfilled "?" placeholders in translations (ch02-l02, ch02-l04)
  - context capitalisation / wording
"""

import json
import glob
import sys
import os

PATCHES = {
    # ── ch02 ──────────────────────────────────────────────────────────────
    "a1-ch02-l02-ex02": {
        "translation":    "[kobieta → nominative plural]",
        "translation_fa": "[kobieta → جمع فاعلی]",
    },
    "a1-ch02-l04-ex02": {
        "translation":    "[mama → genitive: mamy]",
        "translation_fa": "[mama → مضاف‌الیهی: mamy]",
    },

    # ── ch03 ──────────────────────────────────────────────────────────────
    "a1-ch03-l03-ex02": {
        "context":    "Complete the sentence:",
        "context_fa": "جمله را کامل کنید:",
    },
    "a1-ch03-l04-ex02": {
        "context":    "Complete the sentence:",
        "context_fa": "جمله را کامل کنید:",
    },

    # ── ch04 ──────────────────────────────────────────────────────────────
    "a1-ch04-l02-ex07": {
        "context":    "Tomek tells the price. Complete:",
        "context_fa": "تامک قیمت را می‌گوید. کامل کنید:",
    },
    "a1-ch04-l04-ex07": {
        "sentence":       "Poproszę pięć ___.",
        "prompt":         "Poproszę pięć ___.",
        "prompt_fa":      "Poproszę pięć ___.",
        "translation":    "[kawa → genitive plural]",
        "translation_fa": "[kawa → مضاف‌الیهی جمع]",
    },

    # ── ch06 ──────────────────────────────────────────────────────────────
    # Scrambled — original had "(f: starsza siostra)" so split hit the wrong ":"
    "a1-ch06-l02-ex07": {
        "context":        "Ania goes with her older sister. Complete:",
        "context_fa":     "آنیا با خواهر بزرگ‌ترش می‌رود. کامل کنید:",
        "sentence":       "w pokoju ___ siostry.",
        "prompt":         "w pokoju ___ siostry.",
        "prompt_fa":      "w pokoju ___ siostry.",
        "translation":    "(in an older sister's room) [starsza → f locative adj]",
        "translation_fa": "(در اتاق خواهر بزرگ‌تر) [starsza → صفت مکانی مؤنث]",
    },

    # ── ch07 ──────────────────────────────────────────────────────────────
    "a1-ch07-l01-ex02": {
        "sentence":       "Jadę ___.",
        "prompt":         "Jadę ___.",
        "prompt_fa":      "Jadę ___.",
        "translation":    "(by train) [pociąg → instrumental]",
        "translation_fa": "(با قطار) [pociąg → ابزاری]",
    },
    "a1-ch07-l01-ex07": {
        "sentence":       "Jadę do biura ___.",
        "prompt":         "Jadę do biura ___.",
        "prompt_fa":      "Jadę do biura ___.",
        "translation":    "(by car) [samochód → instrumental]",
        "translation_fa": "(با ماشین) [samochód → ابزاری]",
    },
    "a1-ch07-l04-ex06": {
        "sentence":       "Nie lubię ___.",
        "prompt":         "Nie lubię ___.",
        "prompt_fa":      "Nie lubię ___.",
        "translation":    "(chocolate — negation) [czekolada → genitive]",
        "translation_fa": "(شکلات — منفی) [czekolada → مضاف‌الیهی]",
    },

    # ── ch08 ──────────────────────────────────────────────────────────────
    "a1-ch08-l01-ex02": {
        "context":    "Complete the sentence:",
        "context_fa": "جمله را کامل کنید:",
    },
    "a1-ch08-l02-ex02": {
        "context":        "Complete the sentence:",
        "context_fa":     "جمله را کامل کنید:",
        "sentence":       "Idę do ___.",
        "prompt":         "Idę do ___.",
        "prompt_fa":      "Idę do ___.",
        "translation":    "(to the cinema) [kino → genitive]",
        "translation_fa": "(به سینما) [kino → مضاف‌الیهی]",
    },
    "a1-ch08-l02-ex06": {
        "sentence":       "Jadę na ___.",
        "prompt":         "Jadę na ___.",
        "prompt_fa":      "Jadę na ___.",
        "translation":    "(to the airport) [lotnisko → accusative after na]",
        "translation_fa": "(به فرودگاه) [lotnisko → مفعولی بعد از na]",
    },
    "a1-ch08-l03-ex02": {
        "context":        "Complete the sentence:",
        "context_fa":     "جمله را کامل کنید:",
        "sentence":       "Nie mam ___.",
        "prompt":         "Nie mam ___.",
        "prompt_fa":      "Nie mam ___.",
        "translation":    "(I don't have a car) [samochód → genitive after negation]",
        "translation_fa": "(ماشین ندارم) [samochód → مضاف‌الیهی پس از منفی]",
    },
    "a1-ch08-l03-ex06": {
        "sentence":       "Nie mam ___.",
        "prompt":         "Nie mam ___.",
        "prompt_fa":      "Nie mam ___.",
        "translation":    "(passport) [paszport → genitive]",
        "translation_fa": "(پاسپورت) [paszport → مضاف‌الیهی]",
    },
    "a1-ch08-l04-ex02": {
        "context":    "Complete the sentence:",
        "context_fa": "جمله را کامل کنید:",
    },
    "a1-ch08-l04-ex06": {
        "sentence":       "Jest tutaj sześć ___.",
        "prompt":         "Jest tutaj sześć ___.",
        "prompt_fa":      "Jest tutaj sześć ___.",
        "translation":    "(six shops) [sklep → genitive plural]",
        "translation_fa": "(شش مغازه) [sklep → مضاف‌الیهی جمع]",
    },

    # ── ch09 ──────────────────────────────────────────────────────────────
    "a1-ch09-l01-ex02": {
        "sentence":       "Pomagam ___.",
        "prompt":         "Pomagam ___.",
        "prompt_fa":      "Pomagam ___.",
        "translation":    "(I help my brother) [brat → dative]",
        "translation_fa": "(به برادرم کمک می‌کنم) [brat → دادی]",
    },

    # ── ch10 ──────────────────────────────────────────────────────────────
    "a1-ch10-l04-ex02": {
        "sentence":       "Jestem ___.",
        "prompt":         "Jestem ___.",
        "prompt_fa":      "Jestem ___.",
        "translation":    "(I am a student — m, instrumental after być) [student]",
        "translation_fa": "(دانشجو هستم — م، ابزاری بعد از być) [student]",
    },
}


def patch_file(path: str, patches: dict) -> int:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    key = "exercises" if "exercises" in data else None
    if key is None:
        return 0

    changed = 0
    for ex in data[key]:
        ex_id = ex.get("id", "")
        if ex_id in patches:
            for field, value in patches[ex_id].items():
                ex[field] = value
            changed += 1

    if changed == 0:
        return 0

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return changed


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    pattern = os.path.join(repo_root, "assets/content/a1/grammar/*.json")
    files = sorted(glob.glob(pattern))

    total = 0
    for path in files:
        n = patch_file(path, PATCHES)
        if n:
            fname = os.path.basename(path)
            print(f"  {fname}: {n} patched")
            total += n

    print(f"\nDone. {total} exercise(s) patched.")


if __name__ == "__main__":
    main()
