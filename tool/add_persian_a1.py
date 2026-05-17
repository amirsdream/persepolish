#!/usr/bin/env python3
"""Add Persian (Farsi) translations to A1 grammar JSON files."""
import json, os, sys
from collections import OrderedDict

BASE = r"D:\code\b2\b2_polish\assets\content\a1\grammar"

# lesson files: title_fa, grammarPoint_fa, explanation_fa
# revision files: title_fa only (no grammarPoint/explanation)
# extra grammar files: title_fa, explanation_fa (no grammarPoint)

TRANSLATIONS = {
    # ── A1 Ch1 ──────────────────────────────────────────────────────────────
    "a1-ch01-l01": {
        "title_fa": "فعل być — مفرد",
        "grammarPoint_fa": "زمان حال فعل być: jestem، jesteś، jest",
        "explanation_fa": "فعل być (بودن) مهم‌ترین فعل لهستانی است. اشکال مفرد: jestem (من هستم)، jesteś (تو هستی)، jest (او هست). در لهستانی معمولاً ضمیر فاعلی حذف می‌شود چون پسوند فعل شخص را نشان می‌دهد. برای بیان شغل از była + حالت ابزاری استفاده کنید: jestem studentem (من دانشجو هستم)."
    },
    "a1-ch01-l02": {
        "title_fa": "فعل być — جمع",
        "grammarPoint_fa": "زمان حال فعل być: jesteśmy، jesteście، są",
        "explanation_fa": "اشکال جمع فعل być: jesteśmy (ما هستیم)، jesteście (شما هستید)، są (آن‌ها هستند). توجه: برای مردان یا گروه مختلط از oni+są و برای گروه زنانه از one+są استفاده می‌شود."
    },
    "a1-ch01-l03": {
        "title_fa": "ضمایر شخصی",
        "grammarPoint_fa": "ضمایر شخصی لهستانی: ja، ty، on/ona/ono، my، wy، oni/one",
        "explanation_fa": "ضمایر شخصی لهستانی: ja (من)، ty (تو)، on (او-مذکر)، ona (او-مؤنث)، ono (آن-خنثی)، my (ما)، wy (شما)، oni (آن‌ها-مذکر/مختلط)، one (آن‌ها-مؤنث/خنثی). در لهستانی ضمایر اغلب حذف می‌شوند، اما برای تأکید استفاده می‌شوند."
    },
    "a1-ch01-l04": {
        "title_fa": "حالت فاعلی — اسم‌ها",
        "grammarPoint_fa": "جنسیت دستوری و پسوندهای فاعلی مفرد",
        "explanation_fa": "هر اسم لهستانی دارای جنسیت دستوری است: مذکر (معمولاً به مصوت ختم نمی‌شود: brat)، مؤنث (معمولاً به -a ختم می‌شود: siostra)، خنثی (معمولاً به -o یا -e ختم می‌شود: okno). حالت فاعلی (mianownik) شکل پایه است که برای فاعل جمله به‌کار می‌رود."
    },
    "a1-ch01-revision": {
        "title_fa": "مرور فصل ۱: احوال‌پرسی و فعل być",
    },
    # ── A1 Ch2 ──────────────────────────────────────────────────────────────
    "a1-ch02-l01": {
        "title_fa": "فعل mieć — داشتن",
        "grammarPoint_fa": "زمان حال فعل mieć: mam، masz، ma، mamy، macie، mają",
        "explanation_fa": "فعل mieć (داشتن) یکی از پرکاربردترین افعال لهستانی است. اشکال: mam (دارم)، masz (داری)، ma (دارد)، mamy (داریم)، macie (دارید)، mają (دارند). برای بیان مالکیت و روابط خانوادگی استفاده می‌شود: Mam brata (برادر دارم)."
    },
    "a1-ch02-l02": {
        "title_fa": "جمع فاعلی — اسم‌ها",
        "grammarPoint_fa": "پسوندهای جمع فاعلی: -i/-y (مذکر)، -y/-i/-e (مؤنث)، -a (خنثی)",
        "explanation_fa": "برای ساختن جمع اسم‌ها: اسم‌های مذکر غیرجاندار + -y/-i (stoły، koty)، اسم‌های مؤنث: -a → -y/-i (kobiety، siostry)، اسم‌های خنثی: -o → -a (okna، słowa). اسم‌های جاندار مذکر قواعد خاص دارند."
    },
    "a1-ch02-l03": {
        "title_fa": "ضمایر ملکی",
        "grammarPoint_fa": "ضمایر ملکی: mój/moja/moje، twój/twoja/twoje و غیره",
        "explanation_fa": "ضمایر ملکی با جنسیت اسم تطبیق می‌یابند: mój (مذکر)، moja (مؤنث)، moje (خنثی/جمع). همینطور: twój/twoja/twoje (مال تو)، jego/jej (مال او)، nasz/nasza/nasze (مال ما)، wasz/wasza/wasze (مال شما)، ich (مال آن‌ها)."
    },
    "a1-ch02-l04": {
        "title_fa": "حالت مضاف‌الیهی مفرد — مالکیت",
        "grammarPoint_fa": "حالت مضاف‌الیهی مفرد: -a/-u (مذکر/خنثی)، -y/-i (مؤنث)",
        "explanation_fa": "حالت مضاف‌الیهی (dopełniacz) برای بیان مالکیت، نبود و منفی کردن استفاده می‌شود. پسوندهای مفرد: مذکر/خنثی اغلب -a می‌گیرند (brat → brata)، مؤنث -y/-i می‌گیرند (siostra → siostry). پس از nie فعل مستقیم به حالت مضاف‌الیهی می‌رود."
    },
    "a1-ch02-revision": {
        "title_fa": "مرور فصل ۲: خانواده و فعل mieć",
    },
    # ── A1 Ch3 ──────────────────────────────────────────────────────────────
    "a1-ch03-l01": {
        "title_fa": "جنسیت اسم — قواعد تشخیص",
        "grammarPoint_fa": "تشخیص جنسیت دستوری اسم‌های لهستانی از روی پسوند",
        "explanation_fa": "قاعده کلی: اسم‌هایی که به مصوت -a ختم می‌شوند مؤنث هستند (kobieta، mama)؛ اسم‌هایی که به -o، -e، -ę، -um ختم می‌شوند خنثی هستند (dziecko، morze)؛ بقیه اغلب مذکر هستند (kot، lekarz). استثناها وجود دارند؛ مثل mężczyzna که مذکر است."
    },
    "a1-ch03-l02": {
        "title_fa": "جفت‌های شغلی — مذکر و مؤنث",
        "grammarPoint_fa": "اشکال مذکر و مؤنث مشاغل: nauczyciel/nauczycielka، lekarz/lekarka",
        "explanation_fa": "در لهستانی اکثر مشاغل اشکال جداگانه مذکر و مؤنث دارند. اغلب با افزودن -ka به شکل مذکر ساخته می‌شوند: student → studentka، nauczyciel → nauczycielka. برخی پسوندهای دیگر: -owa (profesor → profesorowa در سبک قدیمی)."
    },
    "a1-ch03-l03": {
        "title_fa": "نفی با nie",
        "grammarPoint_fa": "قرار دادن nie پیش از فعل برای نفی جمله",
        "explanation_fa": "برای منفی کردن جمله در لهستانی، کلمه nie را مستقیماً پیش از فعل قرار دهید: Jestem studentem (دانشجو هستم) → Nie jestem studentem (دانشجو نیستم). مفعول مستقیم پس از نفی به حالت مضاف‌الیهی تبدیل می‌شود: Mam brata → Nie mam brata."
    },
    "a1-ch03-l04": {
        "title_fa": "سؤال با czy و کلمات پرسشی",
        "grammarPoint_fa": "ساختن سؤال با czy (بله/خیر) و کلمات پرسشی kto، co، gdzie، kiedy",
        "explanation_fa": "برای سؤال بله/خیر از czy در ابتدای جمله استفاده کنید: Czy masz brata? (برادر داری؟). کلمات پرسشی: kto (کی)، co (چی)، gdzie (کجا)، kiedy (کی/چه وقت)، jak (چطور)، dlaczego (چرا)، ile (چقدر/چند)."
    },
    "a1-ch03-revision": {
        "title_fa": "مرور فصل ۳: مشاغل",
    },
    # ── A1 Ch4 ──────────────────────────────────────────────────────────────
    "a1-ch04-l01": {
        "title_fa": "اعداد ۱ تا ۲۰",
        "grammarPoint_fa": "اعداد اصلی لهستانی از ۱ تا ۲۰",
        "explanation_fa": "اعداد ۱ تا ۱۰: jeden/jedna، dwa/dwie، trzy، cztery، pięć، sześć، siedem، osiem، dziewięć، dziesięć. اعداد ۱۱ تا ۲۰: jedenaście، dwanaście، trzynaście، czternaście، piętnaście، szesnaście، siedemnaście، osiemnaście، dziewiętnaście، dwadzieścia."
    },
    "a1-ch04-l02": {
        "title_fa": "اعداد ۲۰ تا ۱۰۰۰",
        "grammarPoint_fa": "اعداد اصلی لهستانی از ۲۰ تا ۱۰۰۰",
        "explanation_fa": "دهگان: dwadzieścia (۲۰)، trzydzieści (۳۰)، czterdzieści (۴۰)، pięćdziesiąt (۵۰)، sześćdziesiąt (۶۰)، siedemdziesiąt (۷۰)، osiemdziesiąt (۸۰)، dziewięćdziesiąt (۹۰)، sto (۱۰۰). صدگان: dwieście، trzysta، czterysta، pięćset ... tysiąc (۱۰۰۰)."
    },
    "a1-ch04-l03": {
        "title_fa": "حالت مفعولی مفرد — مفعول مستقیم",
        "grammarPoint_fa": "حالت مفعولی مفرد: مذکر جاندار -a، مؤنث -ę، خنثی = فاعلی",
        "explanation_fa": "حالت مفعولی (biernik) برای مفعول مستقیم فعل استفاده می‌شود. تغییرات: مذکر جاندار مثل مضاف‌الیهی (brat → brata)، مذکر غیرجاندار = فاعلی (stół → stół)، مؤنث: -a → -ę (kobieta → kobietę)، خنثی = فاعلی (okno → okno)."
    },
    "a1-ch04-l04": {
        "title_fa": "اعداد + اسم‌ها — قواعد حالت‌دهی",
        "grammarPoint_fa": "عدد ۱ + فاعلی؛ ۲-۴ + فاعلی جمع؛ ۵+ + مضاف‌الیهی جمع",
        "explanation_fa": "اعداد لهستانی حالت دستوری اسم را تعیین می‌کنند: 1 + حالت فاعلی مفرد (jeden kot)، 2-4 + حالت فاعلی جمع (dwa koty)، 5+ + حالت مضاف‌الیهی جمع (pięć kotów). این قاعده برای همه اعداد صدک یا بیشتر نیز اعمال می‌شود."
    },
    "a1-ch04-revision": {
        "title_fa": "مرور فصل ۴: اعداد و خرید",
    },
    # ── A1 Ch5 ──────────────────────────────────────────────────────────────
    "a1-ch05-l01": {
        "title_fa": "زمان حال — گروه ۱ (-am/-asz)",
        "grammarPoint_fa": "صرف افعال گروه اول: pracować، mieszkać، słuchać",
        "explanation_fa": "افعال گروه اول (مصدر به -ać/-ować): پسوندها: -am، -asz، -a، -amy، -acie، -ają. مثال: pracować (کار کردن) → pracuję، pracujesz، pracuje، pracujemy، pracujecie، pracują. توجه: افعال -ować در زمان حال به -uj- تبدیل می‌شوند."
    },
    "a1-ch05-l02": {
        "title_fa": "زمان حال — گروه ۲ (-ę/-isz/-ysz)",
        "grammarPoint_fa": "صرف افعال گروه دوم: mówić، robić، pisać، czytać",
        "explanation_fa": "افعال گروه دوم پسوندهای -ę، -isz/-ysz، -i/-y، -imy/-ymy، -icie/-ycie، -ią دارند. مثال: mówić (گفتن) → mówię، mówisz، mówi، mówimy، mówicie، mówią. مصدرهای -ić/-yć اغلب به این گروه تعلق دارند."
    },
    "a1-ch05-l03": {
        "title_fa": "عبارات زمانی — برنامه روزانه",
        "grammarPoint_fa": "ظرف زمان: rano، wieczorem، w południe، potem، zawsze، często",
        "explanation_fa": "عبارات زمانی پرکاربرد: rano (صبح)، po południu (بعد از ظهر)، wieczorem (عصر/شب)، w nocy (شب دیر)، zawsze (همیشه)، często (اغلب)، rzadko (به ندرت)، nigdy (هرگز)، potem (بعد)، najpierw (اول). این کلمات معمولاً بدون تغییر حالت استفاده می‌شوند."
    },
    "a1-ch05-l04": {
        "title_fa": "گفتن ساعت — Która godzina?",
        "grammarPoint_fa": "بیان ساعت با اعداد و عبارت jest godzina",
        "explanation_fa": "برای پرسیدن ساعت: Która godzina? یا Która jest godzina? پاسخ: Jest godzina + عدد (jest godzina trzecia — ساعت سه است). برای دقیقه: piętnaście po trzeciej (ربع بعد از سه)، za piętnaście czwarta (ربع به چهار). ساعت‌ها در حالت مضاف‌الیهی می‌آیند."
    },
    "a1-ch05-revision": {
        "title_fa": "مرور فصل ۵: برنامه روزانه",
    },
    # ── A1 Ch6 ──────────────────────────────────────────────────────────────
    "a1-ch06-l01": {
        "title_fa": "حالت مکانی — بیان مکان",
        "grammarPoint_fa": "حالت مکانی (miejscownik) با حروف اضافه w، na، o، przy",
        "explanation_fa": "حالت مکانی (miejscownik) پس از حروف اضافه w (در)، na (روی/در)، o (درباره)، przy (کنار) استفاده می‌شود. این حالت هرگز به تنهایی نمی‌آید. تغییر اسم‌های مذکر/خنثی: -e/-ie پسوند می‌گیرند (dom → w domu، sklep → w sklepie). اسم‌های مؤنث: -a → -e/-ie (Polska → w Polsce)."
    },
    "a1-ch06-l02": {
        "title_fa": "حالت مکانی — تطبیق صفت",
        "grammarPoint_fa": "پسوندهای صفت در حالت مکانی: -ym/-im (مذکر/خنثی)، -ej (مؤنث)",
        "explanation_fa": "صفات در حالت مکانی با جنسیت اسم تطبیق می‌یابند: مذکر/خنثی: -ym/-im (w dużym domu — در خانه بزرگ)، مؤنث: -ej (w dużej szkole — در مدرسه بزرگ). این قاعده برای همه صفات اعمال می‌شود."
    },
    "a1-ch06-l03": {
        "title_fa": "حروف اضافه مکانی",
        "grammarPoint_fa": "حروف اضافه مکانی: w، na، przed، za، obok، między، pod، nad",
        "explanation_fa": "حروف اضافه مکانی و حالت‌های دستوری متناظر: w/na + مکانی (موقعیت)، przed/za/obok/między/pod/nad + ابزاری (موقعیت). مثال: Książka jest na stole (کتاب روی میز است)، Kot śpi pod stołem (گربه زیر میز می‌خوابد)."
    },
    "a1-ch06-l04": {
        "title_fa": "حالت مکانی جمع",
        "grammarPoint_fa": "پسوندهای جمع مکانی: -ach (اسم‌ها)، -ych/-ich (صفات)",
        "explanation_fa": "جمع مکانی اسم‌ها: پسوند -ach می‌گیرند (dom → w domach، szkoła → w szkołach). صفات جمع: -ych/-ich (w dużych domach — در خانه‌های بزرگ). این قاعده برای همه جنسیت‌ها یکسان است."
    },
    "a1-ch06-revision": {
        "title_fa": "مرور فصل ۶: خانه و شهر",
    },
    # ── A1 Ch7 ──────────────────────────────────────────────────────────────
    "a1-ch07-l01": {
        "title_fa": "حالت ابزاری — اسم‌ها",
        "grammarPoint_fa": "حالت ابزاری مفرد: -em/-iem (مذکر/خنثی)، -ą (مؤنث)",
        "explanation_fa": "حالت ابزاری (narzędnik) برای بیان ابزار، همراهی (z + ابزاری) و هویت (jest + ابزاری) استفاده می‌شود. پسوندهای مفرد: مذکر/خنثی: -em/-iem (chleb → chlebem)، مؤنث: -ą (kawa → kawą). مثال: Jestem studentem (دانشجو هستم)، Piję kawę z mlekiem (قهوه با شیر می‌نوشم)."
    },
    "a1-ch07-l02": {
        "title_fa": "حالت ابزاری — تطبیق صفت",
        "grammarPoint_fa": "پسوندهای صفت در حالت ابزاری: -ym/-im (مذکر/خنثی)، -ą (مؤنث)",
        "explanation_fa": "صفات در حالت ابزاری: مذکر/خنثی: -ym/-im (z dobrym kolegą — با دوست خوب)، مؤنث: -ą (z dobrą koleżanką — با دوست دختر خوب). جمع: -ymi/-imi (z dobrymi kolegami — با دوستان خوب)."
    },
    "a1-ch07-l03": {
        "title_fa": "سفارش غذا — در رستوران",
        "grammarPoint_fa": "عبارات سفارش غذا: Poproszę، Czy mogę prosić o...، Co polecacie؟",
        "explanation_fa": "عبارات پرکاربرد در رستوران: Poproszę... (لطفاً...بدهید)، Co polecacie? (چه پیشنهادی دارید؟)، Czy mogę prosić o rachunek? (می‌توانم صورت‌حساب بخواهم؟)، Smacznego! (نوش جان!). سفارش: Poproszę zupę (لطفاً سوپ بدهید) — مفعول در حالت مفعولی."
    },
    "a1-ch07-l04": {
        "title_fa": "فعل lubić — دوست داشتن + مصدر و اسم",
        "grammarPoint_fa": "lubić + مصدر (دوست دارم ... کنم) و lubić + مفعولی (دوست دارم ...را)",
        "explanation_fa": "فعل lubić (دوست داشتن) با دو ساختار: 1) lubić + مصدر: Lubię czytać (دوست دارم بخوانم). 2) lubić + حالت مفعولی: Lubię kawę (قهوه دوست دارم). شکل منفی: Nie lubię + مضاف‌الیهی: Nie lubię kawy (قهوه دوست ندارم)."
    },
    "a1-ch07-revision": {
        "title_fa": "مرور فصل ۷: غذا و رستوران",
    },
    # ── A1 Ch8 ──────────────────────────────────────────────────────────────
    "a1-ch08-l01": {
        "title_fa": "افعال حرکتی — iść در برابر jechać",
        "grammarPoint_fa": "iść (پیاده رفتن) در برابر jechać (با وسیله نقلیه رفتن)",
        "explanation_fa": "iść برای رفتن پیاده و jechać برای رفتن با وسیله نقلیه (ماشین، اتوبوس و ...) استفاده می‌شود. اشکال iść: idę، idziesz، idzie، idziemy، idziecie، idą. اشکال jechać: jadę، jedziesz، jedzie، jedziemy، jedziecie، jadą."
    },
    "a1-ch08-l02": {
        "title_fa": "جهت با do + مضاف‌الیهی",
        "grammarPoint_fa": "حرف اضافه do (به سمت) + حالت مضاف‌الیهی برای بیان مقصد",
        "explanation_fa": "برای بیان مقصد از do + حالت مضاف‌الیهی استفاده می‌شود: Idę do szkoły (دارم می‌روم مدرسه)، Jadę do Warszawy (دارم می‌روم ورشو). مقایسه: w + مکانی برای موقعیت (Jestem w szkole — در مدرسه هستم) در برابر do + مضاف‌الیهی برای حرکت."
    },
    "a1-ch08-l03": {
        "title_fa": "مضاف‌الیهی مفرد — مالکیت و نبود",
        "grammarPoint_fa": "حالت مضاف‌الیهی: nie ma + مضاف‌الیهی، szukać + مضاف‌الیهی",
        "explanation_fa": "حالت مضاف‌الیهی برای نبود چیزی: Nie ma mleka (شیر نیست). برای جستجو: Szukam klucza (دنبال کلید می‌گردم). برای مالکیت: To jest dom mojego brata (این خانه برادرم است). پسوندها: مذکر/خنثی -a/-u، مؤنث -y/-i."
    },
    "a1-ch08-l04": {
        "title_fa": "مضاف‌الیهی جمع — بیان مقدار",
        "grammarPoint_fa": "مضاف‌الیهی جمع پس از اعداد (5+) و کلمات مقدار",
        "explanation_fa": "مضاف‌الیهی جمع پس از اعداد ۵ به بالا: pięć kotów (پنج گربه)، dużo wody (خیلی آب)، mało czasu (وقت کم). پسوندهای جمع مضاف‌الیهی: اسم‌های مذکر: اغلب -ów (kotów)، مؤنث: اغلب بدون پسوند (kobiet)، خنثی: اغلب بدون پسوند (okien)."
    },
    "a1-ch08-revision": {
        "title_fa": "مرور فصل ۸: حمل‌ونقل و سفر",
    },
    # ── A1 Ch9 ──────────────────────────────────────────────────────────────
    "a1-ch09-l01": {
        "title_fa": "حالت دادی — مفعول غیرمستقیم",
        "grammarPoint_fa": "حالت دادی (celownik): -owi/-u (مذکر)، -e/-ie (مؤنث)، -u (خنثی)",
        "explanation_fa": "حالت دادی (celownik) برای مفعول غیرمستقیم استفاده می‌شود (به چه کسی؟). پسوندهای مفرد: مذکر: -owi (bratu، studentowi)، مؤنث: -e/-ie (siostrze، pani)، خنثی: -u (dziecku). مثال: Daję bratu książkę (کتاب به برادرم می‌دهم)."
    },
    "a1-ch09-l02": {
        "title_fa": "افعال بازتابی با się",
        "grammarPoint_fa": "افعال بازتابی: myć się، ubierać się، nazywać się و دیگران",
        "explanation_fa": "ذره się در لهستانی با افعال بازتابی (برگشتی) استفاده می‌شود. نمونه‌ها: myć się (شستن خود)، ubierać się (لباس پوشیدن)، nazywać się (اسم داشتن)، czuć się (احساس کردن). się همیشه پس از فعل یا در جای طبیعی جمله قرار می‌گیرد، نه الزاماً بلافاصله پس از فعل."
    },
    "a1-ch09-l03": {
        "title_fa": "ساختار boleć — درد بدن",
        "grammarPoint_fa": "Boli mnie + اسم عضو بدن (مفعولی) — درد ... می‌کند",
        "explanation_fa": "برای بیان درد از ساختار خاص boleć استفاده می‌شود: Boli mnie głowa (سرم درد می‌کند). ضمیر به حالت مفعولی می‌آید: mnie (مرا)، cię (ترا)، go/ją (او را). جمع: Bolą mnie nogi (پاهایم درد می‌کنند). این ساختار برعکس فارسی است."
    },
    "a1-ch09-l04": {
        "title_fa": "افعال وجهی — musieć، móc، chcieć، trzeba",
        "grammarPoint_fa": "افعال وجهی: musieć (باید)، móc (توانستن)، chcieć (خواستن) + مصدر",
        "explanation_fa": "افعال وجهی با مصدر همراه می‌شوند: Muszę iść (باید بروم)، Mogę pomóc (می‌توانم کمک کنم)، Chcę jeść (می‌خواهم بخورم). trzeba (باید) ساختار غیرشخصی دارد: Trzeba pracować (باید کار کرد). نفی: Nie musisz (مجبور نیستی)، Nie możesz (نمی‌توانی)."
    },
    "a1-ch09-revision": {
        "title_fa": "مرور فصل ۹: سلامتی و بدن",
    },
    # ── A1 Ch10 ─────────────────────────────────────────────────────────────
    "a1-ch10-l01": {
        "title_fa": "تطبیق صفت در حالت فاعلی",
        "grammarPoint_fa": "پسوندهای صفت در حالت فاعلی: -y/-i (مذکر)، -a (مؤنث)، -e (خنثی)",
        "explanation_fa": "صفات در لهستانی با اسم از نظر جنسیت، حالت و تعداد تطبیق می‌یابند. در حالت فاعلی مفرد: مذکر: -y/-i (duży dom)، مؤنث: -a (duża szkoła)، خنثی: -e (duże okno). جمع مذکر جاندار: -i/-y (duzi chłopcy)، سایر جمع‌ها: -e (duże domy، duże okna)."
    },
    "a1-ch10-l02": {
        "title_fa": "صفات تفضیلی",
        "grammarPoint_fa": "ساختن صفت تفضیلی: -szy/-iejszy + bardziej برای صفات طولانی",
        "explanation_fa": "صفات تفضیلی: اغلب با افزودن -szy/-iejszy: duży → większy (بزرگ‌تر)، mały → mniejszy (کوچک‌تر)، dobry → lepszy (بهتر)، zły → gorszy (بدتر). برای صفات طولانی: bardziej + صفت (bardziej interesujący — جالب‌تر). مقایسه با od + مضاف‌الیهی: Jest wyższy od brata (از برادرش بلندتر است)."
    },
    "a1-ch10-l03": {
        "title_fa": "grać w و grać na — ورزش و ساز",
        "grammarPoint_fa": "grać w + مفعولی (ورزش) و grać na + مکانی (ساز موسیقی)",
        "explanation_fa": "در لهستانی دو ساختار متفاوت برای «بازی/نواختن» وجود دارد: grać w + حالت مفعولی برای ورزش و بازی: grać w piłkę (فوتبال بازی کردن)، grać w szachy (شطرنج بازی کردن). grać na + حالت مکانی برای ساز موسیقی: grać na gitarze (گیتار نواختن)، grać na pianinie (پیانو نواختن)."
    },
    "a1-ch10-l04": {
        "title_fa": "مرور دستور زبان A1 — حالت‌ها و افعال",
        "grammarPoint_fa": "مروری بر هفت حالت دستوری و افعال کلیدی سطح A1",
        "explanation_fa": "در این درس تمام مطالب A1 مرور می‌شود: هفت حالت دستوری (فاعلی، مفعولی، مضاف‌الیهی، دادی، ابزاری، مکانی، ندایی) و کاربرد هر کدام. صرف افعال کلیدی: być، mieć، gropps 1 و 2. افعال حرکتی، وجهی و بازتابی. این مرور پایه محکمی برای سطح A2 فراهم می‌کند."
    },
    "a1-ch10-revision": {
        "title_fa": "مرور فصل ۱۰: سرگرمی‌ها و مرور A1",
    },
    # ── A1 Extra Grammar Reference Files ───────────────────────────────────
    "a1-grammar-001": {
        "title_fa": "حالت فاعلی — اسم‌ها",
        "explanation_fa": "حالت فاعلی (mianownik) شکل پایه اسم و برای فاعل جمله است. جنسیت اسم‌ها: مذکر (به مصوت ختم نمی‌شوند: kot، brat)، مؤنث (به -a ختم می‌شوند: kobieta، mama)، خنثی (به -o/-e ختم می‌شوند: okno، morze). برای بیان «این است...» از To jest + فاعلی استفاده کنید."
    },
    "a1-grammar-002": {
        "title_fa": "فعل być — زمان حال",
        "explanation_fa": "صرف کامل فعل być: jestem (من هستم)، jesteś (تو هستی)، jest (او هست)، jesteśmy (ما هستیم)، jesteście (شما هستید)، są (آن‌ها هستند). برای نفی nie اضافه کنید: nie jestem (نیستم). کاربردها: هویت، ملیت، شغل، توصیف."
    },
    "a1-grammar-003": {
        "title_fa": "ضمایر شخصی",
        "explanation_fa": "ضمایر فاعلی: ja (من)، ty (تو)، on/ona/ono (او)، my (ما)، wy (شما)، oni/one (آن‌ها). در لهستانی ضمایر اغلب حذف می‌شوند چون پسوند فعل شخص را نشان می‌دهد. برای تأکید یا تضاد می‌توان آن‌ها را ذکر کرد."
    },
    "a1-grammar-004": {
        "title_fa": "حالت مفعولی — مفعول مستقیم",
        "explanation_fa": "حالت مفعولی (biernik) برای مفعول مستقیم است. تغییرات: مذکر جاندار مثل مضاف‌الیهی (-a)، مذکر غیرجاندار = فاعلی، مؤنث: -a → -ę، خنثی = فاعلی. مثال: Mam brata (برادر دارم)، Widzę kobietę (زن را می‌بینم)."
    },
    "a1-grammar-005": {
        "title_fa": "حالت مضاف‌الیهی — نفی و مالکیت",
        "explanation_fa": "حالت مضاف‌الیهی (dopełniacz) برای مالکیت، نبود و بعد از nie استفاده می‌شود. پسوندها: مذکر/خنثی: -a/-u، مؤنث: -y/-i. نفی: Nie mam czasu (وقت ندارم). مالکیت: dom mamy (خانه مامان)."
    },
    "a1-grammar-006": {
        "title_fa": "تطبیق صفت — جنسیت و تعداد",
        "explanation_fa": "صفات با اسم از نظر جنسیت تطبیق می‌یابند. فاعلی مفرد: -y/-i (مذکر)، -a (مؤنث)، -e (خنثی). جمع: -i/-y (مذکر جاندار)، -e (بقیه). مثال: duży dom (خانه بزرگ)، duża szkoła (مدرسه بزرگ)، duże okno (پنجره بزرگ)."
    },
    "a1-grammar-007": {
        "title_fa": "اعداد و شمارش — ۱ تا ۱۰۰",
        "explanation_fa": "اعداد ۱-۱۰: jeden، dwa، trzy، cztery، pięć، sześć، siedem، osiem، dziewięć، dziesięć. دهگان: dwadzieścia، trzydzieści، czterdzieści تا dziewięćdziesiąt. قواعد: 1 + فاعلی، 2-4 + فاعلی جمع، 5+ + مضاف‌الیهی جمع."
    },
    "a1-grammar-008": {
        "title_fa": "زمان حال — افعال منظم گروه ۱",
        "explanation_fa": "افعال گروه اول با مصدر -ać/-ować: پسوندها: -am، -asz، -a، -amy، -acie، -ają. افعال -ować در زمان حال: -uj- اضافه می‌شود: pracować → pracuję. مثال‌ها: słuchać (گوش دادن)، czytać (خواندن)، grać (بازی/نواختن)."
    },
}


def process_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f, object_pairs_hook=OrderedDict)

    file_id = data.get("id", "")
    if not file_id:
        print(f"  SKIP (no id): {filepath}")
        return False

    if "title_fa" in data:
        print(f"  SKIP (already has title_fa): {file_id}")
        return False

    trans = TRANSLATIONS.get(file_id)
    if not trans:
        print(f"  WARN (no translation): {file_id}")
        return False

    # Build new ordered dict inserting fa fields after their English counterparts
    new_data = OrderedDict()
    for key, val in data.items():
        new_data[key] = val
        if key == "title":
            new_data["title_fa"] = trans["title_fa"]
        elif key == "grammarPoint" and "grammarPoint_fa" in trans:
            new_data["grammarPoint_fa"] = trans["grammarPoint_fa"]
        elif key == "explanation" and "explanation_fa" in trans:
            new_data["explanation_fa"] = trans["explanation_fa"]
        elif key == "description" and "description_fa" in trans:
            new_data["description_fa"] = trans["description_fa"]

    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(new_data, f, ensure_ascii=False, indent=2)

    print(f"  OK: {file_id}")
    return True


def main():
    updated = 0
    skipped = 0
    warned = 0

    for fname in sorted(os.listdir(BASE)):
        if not fname.endswith(".json"):
            continue
        fp = os.path.join(BASE, fname)
        result = process_file(fp)
        if result is True:
            updated += 1
        elif result is False:
            skipped += 1

    print(f"\nDone. Updated: {updated}, Skipped: {skipped}")


if __name__ == "__main__":
    main()
