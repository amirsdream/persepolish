#!/usr/bin/env python3
"""Add Persian (Farsi) translations to A2 grammar JSON files."""
import json, os
from collections import OrderedDict

BASE = r"D:\code\b2\b2_polish\assets\content\a2\grammar"

TRANSLATIONS = {
    # ── A2 Ch11 — Past Tense ────────────────────────────────────────────────
    "a2-ch11-l01": {
        "title_fa": "زمان گذشته — مفرد مذکر",
        "grammarPoint_fa": "پسوند گذشته مذکر: -ł (مفرد) — pracował، czytał، był",
        "explanation_fa": "در لهستانی فعل گذشته بر اساس جنسیت فاعل تغییر می‌کند. برای مفرد مذکر پسوند -ł افزوده می‌شود: pracować → on pracował (او کار کرد)، czytać → on czytał (او خواند)، być → on był (او بود). این پسوند بر اساس جنسیت دستوری، نه معنایی، تعیین می‌شود."
    },
    "a2-ch11-l02": {
        "title_fa": "زمان گذشته — مفرد مؤنث",
        "grammarPoint_fa": "پسوند گذشته مؤنث: -ła (مفرد) — pracowała، czytała، była",
        "explanation_fa": "برای فاعل مؤنث مفرد پسوند -ła استفاده می‌شود: ona pracowała (او کار کرد)، ona czytała (او خواند)، ona była (او بود). مقایسه: on pracował (مذکر) در برابر ona pracowała (مؤنث). توجه: ona، pani و اسم‌های مؤنث همه پسوند -ła می‌گیرند."
    },
    "a2-ch11-l03": {
        "title_fa": "زمان گذشته — خنثی و جمع",
        "grammarPoint_fa": "پسوندهای گذشته: -ło (خنثی)، -li (جمع مذکر/مختلط)، -ły (جمع مؤنث/خنثی)",
        "explanation_fa": "اشکال جمع زمان گذشته: جمع مذکر/مختلط (oni): -li (pracowali، czytali)؛ جمع مؤنث/خنثی (one): -ły (pracowały، czytały)؛ خنثی مفرد (ono): -ło (pracowało). توجه: اگر در گروه حتی یک مرد باشد، شکل -li استفاده می‌شود."
    },
    "a2-ch11-l04": {
        "title_fa": "زمان گذشته — بن‌های نامنظم",
        "grammarPoint_fa": "افعال نامنظم در گذشته: iść → szedł، wziąć → wziął، móc → mógł",
        "explanation_fa": "برخی افعال پرکاربرد بن‌های نامنظم در گذشته دارند: iść → szedł/szła/szli (رفت)، wziąć → wziął/wzięła (گرفت)، móc → mógł/mogła (توانست)، przyjść → przyszedł/przyszła (آمد)، znaleźć → znalazł/znalazła (پیدا کرد). این افعال را باید حفظ کرد."
    },
    "a2-ch11-revision": {
        "title_fa": "مرور فصل ۱۱: زمان گذشته",
    },
    # ── A2 Ch12 — Aspect ────────────────────────────────────────────────────
    "a2-ch12-l01": {
        "title_fa": "وجه — مفهوم بنیادی",
        "grammarPoint_fa": "وجه فعل: کامل (perfective) در برابر ناکامل (imperfective)",
        "explanation_fa": "وجه فعل (aspekt) یکی از مهم‌ترین مفاهیم دستور زبان لهستانی است. فعل ناکامل (niedokonany) بر فرآیند، تکرار یا عمل ناتمام تأکید دارد: czytać (خواندن — در حال انجام). فعل کامل (dokonany) بر نتیجه یا عمل تمام‌شده تأکید دارد: przeczytać (خواندن — تمام کردن)."
    },
    "a2-ch12-l02": {
        "title_fa": "جفت‌های رایج وجه",
        "grammarPoint_fa": "جفت‌های ناکامل/کامل: robić/zrobić، pisać/napisać، kupować/kupić",
        "explanation_fa": "جفت‌های وجهی پرکاربرد: robić/zrobić (کردن)، pisać/napisać (نوشتن)، czytać/przeczytać (خواندن)، kupować/kupić (خریدن)، mówić/powiedzieć (گفتن)، jeść/zjeść (خوردن)، pić/wypić (نوشیدن). اغلب پیشوند تغییر ناکامل به کامل را نشان می‌دهد."
    },
    "a2-ch12-l03": {
        "title_fa": "وجه — الگوهای پیشوندی",
        "grammarPoint_fa": "پیشوندهای رایج برای ساختن فعل کامل: za-، na-، prze-، wy-، po-",
        "explanation_fa": "بسیاری از افعال کامل با افزودن پیشوند ساخته می‌شوند: za- (zacząć — شروع کردن)، na- (napisać — نوشتن)، prze- (przeczytać — خواندن تا پایان)، wy- (wyjść — بیرون رفتن)، po- (pójść — رفتن). اما گاهی پیشوند معنا را تغییر می‌دهد."
    },
    "a2-ch12-l04": {
        "title_fa": "وجه در بافت",
        "grammarPoint_fa": "انتخاب وجه بر اساس بافت جمله و نشانه‌های زمانی",
        "explanation_fa": "نشانه‌های انتخاب وجه: ناکامل با: często (اغلب)، zawsze (همیشه)، przez godzinę (یک ساعت). کامل با: raz (یک بار)، w końcu (بالاخره)، szybko (سریع). در آینده: ناکامل با będę + مصدر، کامل صرف مستقیم می‌شود."
    },
    "a2-ch12-revision": {
        "title_fa": "مرور فصل ۱۲: اصول وجه",
    },
    # ── A2 Ch13 — Future Tense ──────────────────────────────────────────────
    "a2-ch13-l01": {
        "title_fa": "زمان آینده — ناکامل",
        "grammarPoint_fa": "آینده ناکامل: będę + مصدر ناکامل یا będę + شکل گذشته",
        "explanation_fa": "آینده ناکامل با دو روش ساخته می‌شود: 1) będę + مصدر: Będę czytać (می‌خواهم بخوانم). 2) będę + شکل گذشته (همخوانی جنسیتی): Będę czytał/czytała. هر دو درست هستند اما روش اول محاوره‌ای‌تر است. برای بیان عمل تکراری یا ادامه‌دار در آینده استفاده می‌شود."
    },
    "a2-ch13-l02": {
        "title_fa": "زمان آینده — کامل",
        "grammarPoint_fa": "آینده کامل: صرف مستقیم فعل کامل در زمان حال",
        "explanation_fa": "افعال کامل فقط آینده دارند (نه حال). صرف مستقیم: zrobię (خواهم کرد)، zrobisz (خواهی کرد)، zrobi (خواهد کرد)، zrobimy، zrobicie، zrobią. این ساختار برای بیان عمل کامل‌شده در آینده استفاده می‌شود: Jutro zrobię zadanie (فردا تکلیفم را تمام خواهم کرد)."
    },
    "a2-ch13-l03": {
        "title_fa": "عبارات زمانی آینده",
        "grammarPoint_fa": "ظرف زمان: jutro، pojutrze، za tydzień، w przyszłym roku، wkrótce",
        "explanation_fa": "عبارات زمانی برای آینده: jutro (فردا)، pojutrze (پس‌فردا)، za tydzień (یک هفته دیگر)، za miesiąc (یک ماه دیگر)، za rok (یک سال دیگر)، wkrótce/niedługo (به زودی)، w przyszłym tygodniu/miesiącu/roku (هفته/ماه/سال آینده)."
    },
    "a2-ch13-l04": {
        "title_fa": "عبارات برنامه‌ریزی",
        "grammarPoint_fa": "برنامه‌ریزی با zamierzać، planować، mieć zamiar + مصدر",
        "explanation_fa": "برای بیان برنامه و قصد: zamierzam (قصد دارم)، planuję (برنامه دارم)، mam zamiar (می‌خواهم). مثال: Zamierzam pojechać do Polski (قصد دارم به لهستان بروم). همچنین mam nadzieję (امیدوارم) + że + جمله فرعی برای بیان آرزو."
    },
    "a2-ch13-revision": {
        "title_fa": "مرور فصل ۱۳: زمان آینده",
    },
    # ── A2 Ch14 — Conditional ───────────────────────────────────────────────
    "a2-ch14-l01": {
        "title_fa": "وجه شرطی — اشکال",
        "grammarPoint_fa": "وجه شرطی: فعل گذشته + by — robiłbym، robiłabym",
        "explanation_fa": "وجه شرطی (tryb warunkowy) با افزودن by به شکل گذشته ساخته می‌شود: robiłbym (می‌کردم — مذکر)، robiłabym (می‌کردم — مؤنث)، robiłbyś/robiłabyś (می‌کردی)، robiłby/robiłaby (می‌کرد)، robilibyśmy/robiłybyśmy (می‌کردیم) و ..."
    },
    "a2-ch14-l02": {
        "title_fa": "وجه شرطی — آرزو و ترجیح",
        "grammarPoint_fa": "بیان آرزو: chciałbym/chciałabym + مصدر — wolałbym/wolałabym",
        "explanation_fa": "برای بیان آرزو و ترجیح از وجه شرطی استفاده می‌شود: Chciałbym pojechać do Paryża (دوست دارم به پاریس بروم). Wolałabym herbatę (ترجیح می‌دهم چای). Marzyłbym o... (آرزو دارم...). این ساختارها در لهستانی محاوره‌ای بسیار رایج هستند."
    },
    "a2-ch14-l03": {
        "title_fa": "وجه شرطی — موقعیت‌های فرضی",
        "grammarPoint_fa": "جملات شرطی: Jeśli/Jeżeli + وجه شرطی در هر دو بند",
        "explanation_fa": "جملات شرطی فرضی: Gdybym miał pieniądze, kupiłbym dom (اگر پول داشتم، خانه می‌خریدم). ساختار: gdyby + فعل گذشته در بند شرط + وجه شرطی در بند جواب. این برای موقعیت‌های غیرواقعی یا بعید استفاده می‌شود."
    },
    "a2-ch14-l04": {
        "title_fa": "جملات gdyby در بافت",
        "grammarPoint_fa": "gdyby در جملات پیچیده: Gdyby + گذشته... به‌علاوه by",
        "explanation_fa": "gdyby (اگر — فرضی) با فعل گذشته در بند شرط ترکیب می‌شود: Gdybyś zadzwonił, przyszłabym (اگر زنگ می‌زدی، می‌آمدم). تفاوت با jeśli/jeżeli: jeśli برای شرط واقعی (Jeśli masz czas, przyjdź — اگر وقت داری بیا) و gdyby برای فرضی."
    },
    "a2-ch14-revision": {
        "title_fa": "مرور فصل ۱۴: وجه شرطی",
    },
    # ── A2 Ch15 — Emotions & Relationships ─────────────────────────────────
    "a2-ch15-l01": {
        "title_fa": "دادی علاقه — Podoba mi się",
        "grammarPoint_fa": "ساختار podoba mi się (دوست دارم) و podobają mi się (دوست دارم — جمع)",
        "explanation_fa": "برای بیان «دوست دارم/پسندیدم» از ساختار podoba mi się استفاده می‌شود که به معنای واقعی «به من خوشایند است» می‌باشد. فاعل جمله چیزی/کسی است که پسندیده می‌شود: Podoba mi się ten film (این فیلم را دوست دارم). برای جمع: Podobają mi się kwiaty (گل‌ها را دوست دارم)."
    },
    "a2-ch15-l02": {
        "title_fa": "ساختارهای sobie",
        "grammarPoint_fa": "کاربرد sobie: poradzić sobie، kupić sobie، wyobrazić sobie",
        "explanation_fa": "sobie (دادی ضمیر بازتابی) در ساختارهای مختلف: poradzić sobie (کنار آمدن/از پس برآمدن)، kupić sobie (برای خود خریدن)، wyobrazić sobie (تصور کردن)، życzyć sobie (آرزو کردن). این ساختارها را به عنوان عبارات ثابت یاد بگیرید."
    },
    "a2-ch15-l03": {
        "title_fa": "افعال احساسی",
        "grammarPoint_fa": "افعال احساسی: cieszyć się، martwić się، bać się، denerwować się",
        "explanation_fa": "افعال احساسی پرکاربرد: cieszyć się (خوشحال بودن)، martwić się (نگران بودن)، bać się + مضاف‌الیهی (ترسیدن از)، denerwować się (عصبانی شدن)، wstydzić się (خجالت کشیدن)، nudzić się (حوصله سر رفتن)، tęsknić za + ابزاری (دلتنگ بودن)."
    },
    "a2-ch15-l04": {
        "title_fa": "افعال بازتابی پیشرفته",
        "grammarPoint_fa": "افعال بازتابی پیشرفته با się در ساختارهای مختلف",
        "explanation_fa": "افعال بازتابی پیچیده‌تر: spotkać się z + ابزاری (ملاقات کردن با)، kłócić się z + ابزاری (بحث کردن با)، zgadzać się z + ابزاری (موافقت کردن با)، zakochać się w + مکانی (عاشق شدن در)، interesować się + ابزاری (علاقه داشتن به)."
    },
    "a2-ch15-revision": {
        "title_fa": "مرور فصل ۱۵: احساسات و روابط",
    },
    # ── A2 Ch16 — Imperative ────────────────────────────────────────────────
    "a2-ch16-l01": {
        "title_fa": "وجه امری — مفرد",
        "grammarPoint_fa": "وجه امری مفرد: بن فعل حال + پسوند (-∅، -i/-y) — Idź!، Zrób!",
        "explanation_fa": "وجه امری مفرد معمولاً از بن فعل حال شخص سوم ساخته می‌شود: idzie → idź (برو!)، robi → rób (بکن!)، mówi → mów (بگو!). افعال گروه اول -aj نگه می‌دارند: czytaj (بخوان!). نفی: nie + وجه امری ناکامل: Nie idź! (نرو!)."
    },
    "a2-ch16-l02": {
        "title_fa": "وجه امری — جمع",
        "grammarPoint_fa": "وجه امری جمع: پسوند -cie — Idźcie!، Zróbcie!",
        "explanation_fa": "وجه امری جمع با افزودن -cie به وجه امری مفرد ساخته می‌شود: idź → idźcie (بروید!)، czytaj → czytajcie (بخوانید!)، mów → mówcie (بگویید!). برای «بیایید با هم»: Chodźmy! (بیا بریم — ما)."
    },
    "a2-ch16-l03": {
        "title_fa": "درخواست مؤدبانه",
        "grammarPoint_fa": "درخواست مؤدبانه: Proszę + مصدر و Czy mógłby pan/pani...؟",
        "explanation_fa": "برای درخواست مؤدبانه: Proszę + مصدر: Proszę zadzwonić (لطفاً تلفن بزنید). Czy możesz/możecie...? (می‌توانی/می‌توانید؟). Czy mógłbyś/mogłabyś...? (آیا امکان داری...؟ — بسیار مؤدبانه). Byłby pan tak uprzejmy...? (آیا لطف می‌فرمایید؟)."
    },
    "a2-ch16-l04": {
        "title_fa": "وجه امری نامنظم",
        "grammarPoint_fa": "وجه امری نامنظم: być → bądź، wiedzieć → wiedz، jeść → jedz",
        "explanation_fa": "برخی افعال رایج وجه امری نامنظم دارند: być → bądź/bądźcie (باش/باشید)، wiedzieć → wiedz/wiedzcie (بدان/بدانید)، jeść → jedz/jedzcie (بخور/بخورید)، mieć → miej/miejcie (داشته باش/داشته باشید)، wziąć → weź/weźcie (بگیر/بگیرید)."
    },
    "a2-ch16-revision": {
        "title_fa": "مرور فصل ۱۶: وجه امری و درخواست",
    },
    # ── A2 Ch17 — Travel & Accommodation ───────────────────────────────────
    "a2-ch17-l01": {
        "title_fa": "مضاف‌الیهی جمع — الگوهای پیشرفته",
        "grammarPoint_fa": "مضاف‌الیهی جمع: -ów (مذکر)، -∅/-i/-y (مؤنث)، -∅ (خنثی)",
        "explanation_fa": "الگوهای مضاف‌الیهی جمع: اسم‌های مذکر اغلب -ów: studentów، kotów. استثنا: برادران → braci. مؤنث: -a حذف می‌شود: kobiet، sióstr. خنثی: اغلب بدون پسوند: okien، miast. برخی مؤنث‌ها -i/-y می‌گیرند: nocy، rzeczy."
    },
    "a2-ch17-l02": {
        "title_fa": "مرور حروف اضافه و حالت‌ها",
        "grammarPoint_fa": "مرور جامع: کدام حرف اضافه با کدام حالت دستوری می‌آید",
        "explanation_fa": "خلاصه حروف اضافه: + مضاف‌الیهی: do، od، z، bez، dla، po (بعد از). + دادی: ku، dzięki. + مفعولی: przez، na (حرکت)، w (زمان). + ابزاری: z، między، przed، za، pod، nad (موقعیت). + مکانی: w، na، o، przy (موقعیت)."
    },
    "a2-ch17-l03": {
        "title_fa": "عبارات سفر در بافت دستوری",
        "grammarPoint_fa": "عبارات سفر با ساختارهای دستوری: rezerwować، podróżować، pytać o",
        "explanation_fa": "عبارات سفر با ساختارهای دستوری: rezerwować pokój (اتاق رزرو کردن)، pytać o drogę (راه پرسیدن)، wsiadać do + مضاف‌الیهی (سوار شدن)، wysiadać z + مضاف‌الیهی (پیاده شدن)، przesiadać się na + مفعولی (عوض کردن وسیله)، dojechać do + مضاف‌الیهی (رسیدن به)."
    },
    "a2-ch17-l04": {
        "title_fa": "زبان اقامتگاه",
        "grammarPoint_fa": "عبارات هتل و اقامتگاه: zameldować się، wymeldować się، numer pokoju",
        "explanation_fa": "عبارات هتل: zameldować się (چک‌این کردن)، wymeldować się (چک‌اوت کردن)، Czy jest wolny pokój? (اتاق خالی هست؟)، pokój jednoosobowy/dwuosobowy (اتاق یک/دو نفره)، śniadanie w cenie (صبحانه در قیمت گنجانده شده)، klucz do pokoju (کلید اتاق)."
    },
    "a2-ch17-revision": {
        "title_fa": "مرور فصل ۱۷: سفر و اقامتگاه",
    },
    # ── A2 Ch18 — Work & Study ──────────────────────────────────────────────
    "a2-ch18-l01": {
        "title_fa": "اسم مصدر با -nie",
        "grammarPoint_fa": "ساختن اسم مصدر از افعال ناکامل: czytanie، pisanie، uczenie się",
        "explanation_fa": "اسم مصدر (rzeczownik odsłowny) از مصدر ناکامل با حذف -ć و افزودن -nie ساخته می‌شود: czytać → czytanie (خواندن)، pisać → pisanie (نوشتن)، mówić → mówienie (گفتن). اگر مصدر به -ać ختم شود و صدای آخر تغییر کند: uczyć → uczenie. این اسم‌ها مانند اسم‌های خنثی رفتار می‌کنند."
    },
    "a2-ch18-l02": {
        "title_fa": "اسم مصدر با -cie",
        "grammarPoint_fa": "اسم مصدر با -cie: znalezienie، przyjście، powiedzenie",
        "explanation_fa": "برخی اسم مصدرها به -cie ختم می‌شوند، معمولاً از افعال با بن‌های خاص: znaleźć → znalezienie (پیدا کردن)، przyjść → przyjście (آمدن)، powiedzieć → powiedzenie (گفتن). این ساختار در جملات رسمی بیشتر دیده می‌شود: Po przyjściu do domu... (بعد از رسیدن به خانه...)."
    },
    "a2-ch18-l03": {
        "title_fa": "الگوهای اشتقاق اسم",
        "grammarPoint_fa": "اشتقاق اسم با پسوندها: -ość، -anie/-enie، -nik/-nica، -arz/-arka",
        "explanation_fa": "الگوهای رایج اشتقاق اسم: صفت + -ość = اسم انتزاعی: ważny → ważność (اهمیت). فعل + -nik: uczyć → ucznik (دانش‌آموز — قدیمی). پسوند -arz/-arka برای مشاغل: piekarz/piekarka (نانوا). -nia برای مکان: kawiarnia (کافه)، księgarnia (کتابفروشی)."
    },
    "a2-ch18-l04": {
        "title_fa": "جملات مرکب و پیچیده",
        "grammarPoint_fa": "حروف ربط: że، żeby، kiedy، ponieważ، chociaż، jeśli",
        "explanation_fa": "حروف ربط پرکاربرد در جملات پیچیده: że (که — برای بیان): Wiem, że masz rację. żeby (تا — هدف): Uczę się, żeby zdać egzamin. kiedy (وقتی): Kiedy byłem młody... ponieważ/bo (چون): Nie przyszedłem, bo byłem chory. chociaż (اگرچه): Chociaż jest późno, pracuję."
    },
    "a2-ch18-revision": {
        "title_fa": "مرور فصل ۱۸: کار و تحصیل",
    },
    # ── A2 Ch19 — Formal Register ───────────────────────────────────────────
    "a2-ch19-l01": {
        "title_fa": "ضمایر pan/pani — مخاطب رسمی",
        "grammarPoint_fa": "خطاب رسمی با pan (آقا) و pani (خانم) + فعل سوم شخص مفرد",
        "explanation_fa": "در لهستانی خطاب رسمی با pan (آقا) یا pani (خانم) + فعل سوم شخص مفرد بیان می‌شود: Czy pan rozumie? (آیا متوجه شدید؟)، Czy pani ma...? (آیا شما دارید؟). این ساختار مانند انگلیسی you نیست — فعل سوم شخص است نه دوم. برای جمع: państwo (آقایان و خانم‌ها)."
    },
    "a2-ch19-l02": {
        "title_fa": "نامه‌های رسمی و ایمیل",
        "grammarPoint_fa": "ساختار نامه رسمی: Szanowny Panie/Szanowna Pani، Z poważaniem",
        "explanation_fa": "ساختار نامه رسمی لهستانی: سلام: Szanowny Panie (جناب آقا)، Szanowna Pani (سرکار خانم)، Szanowni Państwo (جناب‌عالی). اختتام: Z poważaniem (با احترام)، Z wyrazami szacunku (با کمال احترام). محتوا با Uprzejmie informuję, że... (محترمانه اطلاع می‌دهم که...) شروع می‌شود."
    },
    "a2-ch19-l03": {
        "title_fa": "واژگان رسمی در برابر غیررسمی",
        "grammarPoint_fa": "معادل‌های رسمی: pragnąć (به جای chcieć)، zamierzać، uprzejmie prosić",
        "explanation_fa": "تفاوت واژگان رسمی و غیررسمی: chcieć (می‌خواهم) → pragnąć (مایلم — رسمی)، mówić (گفتن) → informować (اطلاع دادن — رسمی)، ale (اما) → jednakże/jednak (اما — رسمی)، dlatego (پس) → zatem/wobec tego (بنابراین — رسمی)، więcej → ponadto (علاوه بر این — رسمی)."
    },
    "a2-ch19-l04": {
        "title_fa": "مقایسه سبک رسمی و غیررسمی",
        "grammarPoint_fa": "تبدیل جملات غیررسمی به رسمی و برعکس",
        "explanation_fa": "تمرین تبدیل سبک: جمله غیررسمی «Chcę żebyś mi pomógł» (می‌خواهم کمکم کنی) در سبک رسمی: «Uprzejmie proszę o udzielenie mi pomocy» (مؤدبانه تقاضا می‌کنم به من کمک فرمایید). شناخت سطح رسمیت برای ارتباطات حرفه‌ای و اداری در لهستان ضروری است."
    },
    "a2-ch19-revision": {
        "title_fa": "مرور فصل ۱۹: سبک رسمی",
    },
    # ── A2 Ch20 — Review ────────────────────────────────────────────────────
    "a2-ch20-l01": {
        "title_fa": "مرور وجه — کامل در برابر ناکامل",
        "grammarPoint_fa": "مرور جامع وجه: قواعد انتخاب و کاربرد در بافت‌های مختلف",
        "explanation_fa": "مرور قواعد وجه: ناکامل برای: فرآیند (był gotowany)، تکرار (jadał codziennie)، حال (czytam)، آینده تکراری (będę czytać). کامل برای: نتیجه (ugotował)، یک بار (przeczytał)، آینده کامل (przeczytam). در گفتگوی روزمره وجه اغلب از روی بافت تشخیص داده می‌شود."
    },
    "a2-ch20-l02": {
        "title_fa": "مرور زمان‌ها — گذشته، حال، آینده",
        "grammarPoint_fa": "مرور زمان‌های سه‌گانه با هر دو وجه",
        "explanation_fa": "جدول کامل زمان‌ها: حال (فقط ناکامل): czytam. گذشته کامل: przeczytałem/przeczytałam. گذشته ناکامل: czytałem/czytałam. آینده ناکامل: będę czytać / będę czytał(a). آینده کامل: przeczytam. این جدول را با افعال مختلف تمرین کنید."
    },
    "a2-ch20-l03": {
        "title_fa": "مرور حالت‌ها — هفت حالت",
        "grammarPoint_fa": "مرور جامع هفت حالت دستوری لهستانی و کاربرد هر کدام",
        "explanation_fa": "هفت حالت: فاعلی (mianownik) — فاعل. مضاف‌الیهی (dopełniacz) — مالکیت، نبود، بعد از nie. دادی (celownik) — مفعول غیرمستقیم. مفعولی (biernik) — مفعول مستقیم. ابزاری (narzędnik) — ابزار، همراهی، هویت. مکانی (miejscownik) — مکان با حرف اضافه. ندایی (wołacz) — خطاب مستقیم."
    },
    "a2-ch20-l04": {
        "title_fa": "آمادگی برای آزمون A2",
        "grammarPoint_fa": "مرور مهارت‌های چهارگانه برای آزمون A2: خواندن، نوشتن، گوش دادن، صحبت کردن",
        "explanation_fa": "برای آزمون A2: خواندن — متون کوتاه با واژگان آشنا. گوش دادن — مکالمات روزمره ساده. نوشتن — نامه یا ایمیل کوتاه با دستور درست. صحبت کردن — معرفی خود، توصیف خانواده و محیط. نکات کلیدی: وجه فعل، زمان گذشته و آینده، حالت‌های اصلی."
    },
    "a2-ch20-revision": {
        "title_fa": "مرور فصل ۲۰: مرور کامل A2",
    },
    # ── A2 Extra Grammar Reference Files ────────────────────────────────────
    "a2-grammar-001": {
        "title_fa": "زمان گذشته — مذکر",
        "explanation_fa": "زمان گذشته مذکر مفرد با پسوند -ł ساخته می‌شود: pracował، czytał، mówił. شکل کامل: był (بود). برای اول شخص و دوم شخص پسوندهای شخصی اضافه می‌شوند: pracowałem (کار کردم)، pracowałeś (کار کردی)."
    },
    "a2-grammar-002": {
        "title_fa": "زمان گذشته — مؤنث و خنثی",
        "explanation_fa": "زمان گذشته مؤنث مفرد: -ła (pracowała، czytała). خنثی مفرد: -ło (pracowało). جمع مؤنث/خنثی: -ły (pracowały). جمع مذکر/مختلط: -li (pracowali). پسوندهای شخصی برای اول و دوم شخص جمع: pracowałyśmy/pracowałyście (ما/شما — مؤنث)."
    },
    "a2-grammar-003": {
        "title_fa": "زمان آینده — ساده",
        "explanation_fa": "آینده ناکامل: będę + مصدر یا شکل گذشته: Będę czytać/Będę czytał(a). آینده کامل: صرف مستقیم فعل کامل: przeczytam، przeczytasz، przeczyta، przeczytamy، przeczytacie، przeczytają. کاربرد: ناکامل برای تکرار، کامل برای عمل تمام‌شده."
    },
    "a2-grammar-004": {
        "title_fa": "حالت دادی — مفعول غیرمستقیم",
        "explanation_fa": "حالت دادی (celownik) مفرد: مذکر/خنثی اغلب -owi می‌گیرند (studentowi، psu)؛ مؤنث: -a → -e/-ie (kobiecie، Polsce). جمع: -om برای همه (studentom، kobietom). کاربرد: مفعول غیرمستقیم، podoba mi się، potrzeba mi."
    },
    "a2-grammar-005": {
        "title_fa": "حالت ابزاری — با و به وسیله",
        "explanation_fa": "حالت ابزاری (narzędnik) مفرد: مذکر/خنثی: -em/-iem (studentem)؛ مؤنث: -ą (kobietą). جمع: -ami (studentami، kobietami). کاربرد: همراهی (z + ابزاری)، ابزار (piszę ołówkiem)، هویت (jest studentem)، پس از być در گذشته/آینده."
    },
    "a2-grammar-006": {
        "title_fa": "وجه شرطی — would",
        "explanation_fa": "وجه شرطی: شکل گذشته + by. مذکر: robiłbym، robiłbyś، robiłby؛ مؤنث: robiłabym، robiłabyś، robiłaby؛ جمع: robilibyśmy/robiłybyśmy و ... کاربرد: آرزو (Chciałbym)، فرضیه (Gdybym miał)، ادب (Mógłbyś)."
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
    updated = skipped = 0
    for fname in sorted(os.listdir(BASE)):
        if not fname.endswith(".json"):
            continue
        result = process_file(os.path.join(BASE, fname))
        if result:
            updated += 1
        else:
            skipped += 1
    print(f"\nDone. Updated: {updated}, Skipped: {skipped}")


if __name__ == "__main__":
    main()
