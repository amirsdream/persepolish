"""
patch_context_fa.py

Patches context_fa (and where needed, sentence) for fill_blank exercises
that still have English text in context_fa after the migration scripts.

Each entry: exercise_id → {field: new_value, ...}
"""

import json
import glob
import sys
import os

PATCHES = {
    # ch01-l01
    "a1-ch01-l01-ex02": {
        "context": "Piotr is a doctor. Complete:",
        "context_fa": "پیوتر یک دکتر است. کامل کنید:",
    },
    # ch01-l02
    "a1-ch01-l02-ex02": {
        "context": "Kacper and his classmates are students. Complete:",
        "context_fa": "کاکپر و هم‌کلاسی‌هایش دانشجو هستند. کامل کنید:",
    },
    # ch01-l03
    "a1-ch01-l03-ex02": {
        "context": "Your group is from Poland. Complete:",
        "context_fa": "گروه شما از لهستان است. کامل کنید:",
    },
    # ch01-l04
    "a1-ch01-l04-ex02": {
        "context": "You are pointing to a window. Complete:",
        "context_fa": "شما به یک پنجره اشاره می‌کنید. کامل کنید:",
    },
    "a1-ch01-l04-ex07": {
        "context": "Kasia sees a boy's name — Tomek. What gender is it?",
        "context_fa": "کاسیا یک اسم پسرانه می‌بیند — Tomek. جنس دستوری آن چیست؟",
        "sentence": "It ends in a consonant so its gender is ___.",
    },
    # ch02-l01
    "a1-ch02-l01-ex02": {
        "context": "You are telling a friend about your siblings. Complete:",
        "context_fa": "شما به دوستی درباره خواهر و برادرتان می‌گویید. کامل کنید:",
    },
    # ch02-l02
    "a1-ch02-l02-ex02": {
        "context": "You meet a group of friendly women. Complete:",
        "context_fa": "شما با گروهی از زنان مهربان آشنا می‌شوید. کامل کنید:",
    },
    # ch02-l03
    "a1-ch02-l03-ex02": {
        "context": "You are asking about your friend's sister. Complete:",
        "context_fa": "شما درباره خواهر دوستتان می‌پرسید. کامل کنید:",
    },
    # ch02-l04
    "a1-ch02-l04-ex02": {
        "context": "You come home and your mum is not there. Complete:",
        "context_fa": "به خانه می‌روید و مادرتان آنجا نیست. کامل کنید:",
    },
    # ch03-l01
    "a1-ch03-l01-ex07": {
        "context": "Tomek looks at a window. What gender is 'okno'?",
        "context_fa": "تامک به یک پنجره نگاه می‌کند. جنس دستوری 'okno' چیست؟",
        "sentence": "'Okno' ends in -o, so its gender is ___.",
    },
    # ch03-l02
    "a1-ch03-l02-ex07": {
        "context": "Tomek is male and works as a doctor. Complete:",
        "context_fa": "تامک مرد است و به عنوان دکتر کار می‌کند. کامل کنید:",
    },
    # ch04-l03 — context_fa already has Persian; just clean the Latin "pies" flag
    "a1-ch04-l03-ex07": {
        "context": "Kasia sees a dog (masculine animate: pies). Complete:",
        "context_fa": "کاسیا یک سگ می‌بیند (مذکر جاندار: pies). کامل کنید:",
    },
    # ch05-l03 — fix quoted sentence and add proper context_fa
    "a1-ch05-l03-ex07": {
        "context": "Marek always wakes up late. Complete:",
        "context_fa": "مارک همیشه دیر بیدار می‌شود. کامل کنید:",
        "sentence": "Marek zawsze wstaje ___.",
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
                if field == "sentence":
                    ex["prompt"] = value
                    ex["prompt_fa"] = value
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
