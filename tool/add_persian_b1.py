#!/usr/bin/env python3
"""Add Persian (Farsi) translations to B1 grammar JSON files."""
import json, os
from collections import OrderedDict

BASE = r"D:\code\b2\b2_polish\assets\content\b1\grammar"

TRANSLATIONS = {
    # ── B1 Ch1 — Aspect Pairs ────────────────────────────────────────────────
    "b1-ch01-l01": {
        "title_fa": "جفت‌های وجهی — بررسی عمیق",
        "grammarPoint_fa": "تحلیل دقیق تفاوت معنایی فعل کامل و ناکامل در سطح B1",
        "explanation_fa": "در سطح B1 باید تفاوت ظریف وجه را درک کنیم. ناکامل: تأکید بر فرآیند، مدت، تکرار یا عمل ناتمام. کامل: تأکید بر نتیجه، پایان، یک بار یا لحظه خاص. مثال: czytałem gazetę godzinę (یک ساعت روزنامه خواندم — فرآیند) در برابر przeczytałem gazetę (روزنامه را خواندم — تمام کردم)."
    },
    "b1-ch01-l02": {
        "title_fa": "۲۰ جفت وجهی پرکاربرد",
        "grammarPoint_fa": "جفت‌های ضروری: robić/zrobić، pisać/napisać، mówić/powiedzieć و ۱۷ جفت دیگر",
        "explanation_fa": "۲۰ جفت وجهی که باید حفظ کنید: robić/zrobić، pisać/napisać، czytać/przeczytać، mówić/powiedzieć، jeść/zjeść، pić/wypić، kupować/kupić، dawać/dać، brać/wziąć، wychodzić/wyjść، przychodzić/przyjść، wracać/wrócić، otwierać/otworzyć، zamykać/zamknąć، siadać/siąść، kłaść/położyć، wstawać/wstać، uczyć się/nauczyć się، myć/umyć، ubierać/ubrać."
    },
    "b1-ch01-l03": {
        "title_fa": "جفت‌های وجهی بر اساس گروه معنایی",
        "grammarPoint_fa": "دسته‌بندی جفت‌های وجهی: حرکت، ارتباط، تغییر حالت، ادراک",
        "explanation_fa": "دسته‌بندی جفت‌های وجهی: حرکت: iść/pójść، jeździć/pojechać، wchodzić/wejść. ارتباط: mówić/powiedzieć، pisać/napisać، dzwonić/zadzwonić. تغییر حالت: otwierać/otworzyć، zamykać/zamknąć، wstawać/wstać. ادراک: oglądać/obejrzeć، słuchać/posłuchać، czytać/przeczytać. این دسته‌بندی یادگیری را آسان‌تر می‌کند."
    },
    "b1-ch01-l04": {
        "title_fa": "وجه در بافت پاراگراف",
        "grammarPoint_fa": "انتخاب درست وجه در متون طولانی و داستان‌گویی",
        "explanation_fa": "در روایت و داستان‌گویی: از گذشته ناکامل برای پس‌زمینه و حالت استفاده می‌شود: Był wieczór, padał deszcz... (شب بود، باران می‌بارید...). از گذشته کامل برای رویدادهای اصلی: Nagle ktoś zapukał do drzwi (ناگهان کسی در زد). تمرین: داستان‌های کوتاه لهستانی بخوانید و وجه‌ها را علامت‌گذاری کنید."
    },
    "b1-ch01-revision": {
        "title_fa": "مرور فصل ۱ B1: مبانی جفت‌های وجهی",
    },
    # ── B1 Ch2 — Motion Verbs ────────────────────────────────────────────────
    "b1-ch02-l01": {
        "title_fa": "chodzić در برابر pójść — عادت در برابر یک بار",
        "grammarPoint_fa": "chodzić (عادت/تکرار) در برابر pójść (یک بار/آینده) — حرکت پیاده",
        "explanation_fa": "chodzić (ناکامل، چندجهته) برای حرکت تکراری یا عادت: Chodzę do pracy piechotą (پیاده سر کار می‌روم). iść (ناکامل، یک‌جهته) برای حرکت جاری در یک جهت: Idę teraz do sklepu (الان دارم می‌روم مغازه). pójść (کامل) برای رفتن یک‌بار در آینده: Jutro pójdę do lekarza (فردا می‌روم دکتر)."
    },
    "b1-ch02-l02": {
        "title_fa": "jeździć در برابر jechać در برابر pojechać — حرکت با وسیله",
        "grammarPoint_fa": "jeździć (عادت) در برابر jechać (در حال رفتن) در برابر pojechać (رفتن — کامل)",
        "explanation_fa": "jeździć (ناکامل، چندجهته): Jeżdżę do pracy autobusem (با اتوبوس سر کار می‌روم — عادت). jechać (ناکامل، یک‌جهته): Jadę teraz do Krakowa (الان دارم می‌روم کراکوف). pojechać (کامل): W weekend pojechałem do Gdańska (آخر هفته رفتم گدانسک)."
    },
    "b1-ch02-l03": {
        "title_fa": "افعال حرکتی دویدن و پریدن",
        "grammarPoint_fa": "biegać/pobiec (دویدن)، latać/polecieć (پریدن/پرواز کردن)",
        "explanation_fa": "الگوی یکسانی برای همه افعال حرکتی: biegać (دویدن تکراری/چندجهته): Biegam co rano (هر صبح می‌دوم). biec (دویدن یک‌جهته): Biegnę na autobus (دارم برای اتوبوس می‌دوم). pobiec (کامل): Pobiegłem do lekarza (رفتم دکتر — دویدم). latać/lecieć/polecieć برای پرواز."
    },
    "b1-ch02-l04": {
        "title_fa": "افعال حرکتی در بافت",
        "grammarPoint_fa": "ترکیب افعال حرکتی در مکالمه و متن طبیعی",
        "explanation_fa": "در مکالمه طبیعی: Gdzie idziesz? (کجا می‌روی؟) — پاسخ با iść برای جاری. Dokąd chodzisz na spacer? (کجا برای قدم زدن می‌روی؟) — پاسخ با chodzić برای عادت. پیشوندها معنا را تغییر می‌دهند: wchodzić (وارد شدن)، wychodzić (خارج شدن)، przychodzić (آمدن)، odchodzić (دور شدن)."
    },
    "b1-ch02-revision": {
        "title_fa": "مرور فصل ۲ B1: افعال حرکتی",
    },
    # ── B1 Ch3 — Passive with być ────────────────────────────────────────────
    "b1-ch03-l01": {
        "title_fa": "صدای مجهول — być + صفت مفعولی",
        "grammarPoint_fa": "صدای مجهول: być + صفت مفعولی گذشته (imiesłów bierny: -ny/-ty/-ony)",
        "explanation_fa": "صدای مجهول در لهستانی با być + صفت مفعولی گذشته ساخته می‌شود: Dom jest budowany (خانه ساخته می‌شود). صفت مفعولی از بن فعل کامل: napisać → napisany (نوشته‌شده)، zrobić → zrobiony (انجام‌شده)، otworzyć → otwarty (بازشده). صفت با جنسیت اسم تطبیق می‌یابد."
    },
    "b1-ch03-l02": {
        "title_fa": "تطبیق صفت مفعولی — جنسیت و تعداد",
        "grammarPoint_fa": "تطبیق صفت مفعولی: -ny/-na/-ne/-ni/-ne (بسته به جنسیت و تعداد)",
        "explanation_fa": "صفت مفعولی با اسم تطبیق می‌یابد: مذکر: napisany (نوشته‌شده)، مؤنث: napisana، خنثی: napisane، جمع مذکر جاندار: napisani، سایر جمع: napisane. مثال: Książka jest napisana po polsku (کتاب به لهستانی نوشته شده). List był napisany wczoraj (نامه دیروز نوشته شد)."
    },
    "b1-ch03-l03": {
        "title_fa": "صدای مجهول — ۱۵ فعل رایج",
        "grammarPoint_fa": "۱۵ فعل پرکاربرد در صدای مجهول: budować، naprawić، otworzyć و دیگران",
        "explanation_fa": "۱۵ فعل رایج در صدای مجهول: budować → budowany (ساخته می‌شود)، naprawiać → naprawiany (تعمیر می‌شود)، pisać → pisany (نوشته می‌شود)، tłumaczyć → tłumaczony (ترجمه می‌شود)، przygotowywać → przygotowywany (آماده می‌شود)، zamykać → zamykany، organizować → organizowany، robić → robiony، otwierać → otwierany."
    },
    "b1-ch03-l04": {
        "title_fa": "صدای مجهول در بافت",
        "grammarPoint_fa": "کاربرد صدای مجهول در متون رسمی، اخبار و توضیحات",
        "explanation_fa": "صدای مجهول در لهستانی اغلب در متون رسمی، علمی و خبری به‌کار می‌رود: Budynek został wybudowany w 1920 roku (ساختمان در ۱۹۲۰ ساخته شد). در گفتار روزمره معمولاً از صدای معلوم یا się ترجیح داده می‌شود. توجه: زمان با شکل być تعیین می‌شود: jest/był/będzie + صفت مفعولی."
    },
    "b1-ch03-revision": {
        "title_fa": "مرور فصل ۳ B1: صدای مجهول با być",
    },
    # ── B1 Ch4 — Passive with zostać ─────────────────────────────────────────
    "b1-ch04-l01": {
        "title_fa": "صدای مجهول رویدادی — zostać + صفت مفعولی",
        "grammarPoint_fa": "zostać + صفت مفعولی برای بیان رویداد کامل‌شده: został napisany",
        "explanation_fa": "zostać + صفت مفعولی برای رویداد کامل (نتیجه): List został napisany (نامه نوشته شد — کامل شد). تفاوت با być: być + صفت مفعولی بر وضعیت/فرآیند تأکید دارد (Jest napisany — نوشته‌شده است)؛ zostać بر رویداد کامل‌شده تأکید دارد (Został napisany — نوشته شد). زمان‌ها: zostanie (آینده)، został (گذشته)."
    },
    "b1-ch04-l02": {
        "title_fa": "صدای مجهول بدون فاعل و przez + ابزاری",
        "grammarPoint_fa": "بیان فاعل در صدای مجهول: przez + حالت ابزاری (توسط)",
        "explanation_fa": "در صدای مجهول فاعل با przez + حالت ابزاری بیان می‌شود: Książka została napisana przez Mickiewicza (کتاب توسط میتسکیویچ نوشته شد). اما اغلب فاعل ذکر نمی‌شود: Sklep został otwarty o 9. (مغازه ساعت ۹ باز شد). صدای مجهول بدون فاعل در لهستانی بسیار رایج است."
    },
    "b1-ch04-l03": {
        "title_fa": "صدای مجهول در برابر معلوم",
        "grammarPoint_fa": "انتخاب بین صدای معلوم و مجهول بر اساس بافت و سبک",
        "explanation_fa": "کِی از صدای مجهول استفاده کنیم: وقتی فاعل نامعلوم است، بی‌اهمیت است یا می‌خواهیم از ذکر آن خودداری کنیم. در متون علمی، رسمی و اداری. بدیل‌های محاوره‌ای: się constructions: Mówi się że... (گفته می‌شود که...) یا صدای معلوم با فاعل نامشخص: Ktoś otworzył okno."
    },
    "b1-ch04-l04": {
        "title_fa": "صدای مجهول در متون رسمی",
        "grammarPoint_fa": "صدای مجهول پیشرفته: زمان‌های مختلف و ساختارهای پیچیده",
        "explanation_fa": "صدای مجهول در زمان‌های مختلف: حال: jest budowany (ساخته می‌شود). گذشته (فرآیند): był budowany. گذشته (نتیجه): został zbudowany. آینده (فرآیند): będzie budowany. آینده (نتیجه): zostanie zbudowany. این تفاوت‌ها در نوشتار رسمی و حقوقی بسیار اهمیت دارند."
    },
    "b1-ch04-revision": {
        "title_fa": "مرور فصل ۴ B1: صدای مجهول پیشرفته",
    },
    # ── B1 Ch5 — Conditional ─────────────────────────────────────────────────
    "b1-ch05-l01": {
        "title_fa": "وجه شرطی — صرف کامل",
        "grammarPoint_fa": "صرف کامل وجه شرطی: -łbym/-łabym، -łbyś/-łabyś، -łby/-łaby و ...",
        "explanation_fa": "صرف کامل وجه شرطی برای مذکر: robiłbym، robiłbyś، robiłby، robilibyśmy، robilibyście، robiliby. برای مؤنث: robiłabym، robiłabyś، robiłaby، robiłybyśmy، robiłybyście، robiłyby. اتصال by به فعل یا ضمیر بستگی به سبک دارد."
    },
    "b1-ch05-l02": {
        "title_fa": "درخواست مؤدبانه — chciałbym/chciałabym",
        "grammarPoint_fa": "chciałbym/chciałabym + مصدر — مؤدبانه‌ترین شکل درخواست",
        "explanation_fa": "chciałbym (می‌خواستم — مذکر) و chciałabym (می‌خواستم — مؤنث) برای درخواست بسیار مؤدبانه: Chciałbym zamówić stolik (می‌خواستم یک میز رزرو کنم). مقایسه سطح ادب: chcę (می‌خواهم — مستقیم) < chciałbym/chciałabym (می‌خواستم — مؤدب) < czy mógłbym/mogłabym (آیا می‌توانم — بسیار مؤدب)."
    },
    "b1-ch05-l03": {
        "title_fa": "عبارات مؤدبانه رسمی با وجه شرطی",
        "grammarPoint_fa": "عبارات رسمی: Czy mógłby pan/pani...؟ Byłoby możliwe...؟",
        "explanation_fa": "عبارات مؤدبانه رسمی: Czy mógłby pan zadzwonić? (آیا می‌توانید زنگ بزنید؟). Byłbym wdzięczny (ممنون می‌شدم). Czy byłoby możliwe...? (آیا ممکن خواهد بود...؟). Chciałbym prosić o... (می‌خواستم درخواست کنم...). این عبارات در محیط‌های رسمی و تجاری ضروری هستند."
    },
    "b1-ch05-l04": {
        "title_fa": "وجه شرطی در موقعیت‌های فرضی",
        "grammarPoint_fa": "جملات فرضی پیچیده با gdyby در هر دو بند",
        "explanation_fa": "ساختارهای فرضی پیچیده: Gdybym wiedział, powiedziałbym ci (اگر می‌دانستم، بهت می‌گفتم). Gdybyś przyszedł wcześniej, zdążyłbyś (اگر زودتر می‌آمدی، به‌موقع می‌رسیدی). توجه: در هر دو بند وجه شرطی استفاده می‌شود. این برای موقعیت‌های کاملاً فرضی یا غیرواقعی است."
    },
    "b1-ch05-revision": {
        "title_fa": "مرور فصل ۵ B1: وجه شرطی",
    },
    # ── B1 Ch6 — Reported Speech ─────────────────────────────────────────────
    "b1-ch06-l01": {
        "title_fa": "نقل قول غیرمستقیم — mówić że",
        "grammarPoint_fa": "نقل قول با mówić/powiedzieć że + جمله فرعی",
        "explanation_fa": "برای نقل قول غیرمستقیم از że (که) استفاده می‌شود: مستقیم: «Jestem zmęczony» (خسته‌ام). غیرمستقیم: Powiedział, że jest zmęczony (گفت که خسته است). توجه: ضمایر و زمان تغییر می‌کنند. «Idę do domu» → Powiedział, że idzie do domu (گفت که دارد می‌رود خانه)."
    },
    "b1-ch06-l02": {
        "title_fa": "سؤال‌های غیرمستقیم",
        "grammarPoint_fa": "سؤال غیرمستقیم: zapytał, czy/kiedy/gdzie/jak + جمله فرعی",
        "explanation_fa": "سؤال‌های غیرمستقیم: بله/خیر: zapytał, czy... — «Czy masz czas?» → Zapytał, czy mam czas (پرسید آیا وقت دارم). با کلمات پرسشی: zapytał, gdzie/kiedy/jak/kto/co + جمله فرعی: Zapytała, gdzie mieszkam (پرسید کجا زندگی می‌کنم). ترتیب کلمات در جمله فرعی مانند جمله معمولی است، نه سؤالی."
    },
    "b1-ch06-l03": {
        "title_fa": "دستورات نقل‌قول‌شده — żeby و kazać",
        "grammarPoint_fa": "نقل قول دستور: powiedział, żeby + گذشته — kazał mi + مصدر",
        "explanation_fa": "برای نقل قول دستور: powiedział/poprosiła, żeby + گذشته شرطی: «Zamknij okno!» → Powiedział, żebym zamknął okno (گفت درپنجره را ببندم). kazać + دادی + مصدر: Kazał mi czekać (دستور داد منتظر بمانم). prosić, żeby: Poprosił, żebym przyszedł wcześniej (خواهش کرد زودتر بیایم)."
    },
    "b1-ch06-l04": {
        "title_fa": "نقل قول غیرمستقیم در بافت",
        "grammarPoint_fa": "ترکیب انواع نقل قول در مکالمه و روایت",
        "explanation_fa": "در روایت طولانی ترکیب انواع نقل قول: Marek powiedział, że jest chory i że nie przyjdzie (مارک گفت مریض است و نمی‌آید). Zapytałem go, czy ma lekarstwo. Powiedział, żebym zadzwonił do doktora (پرسیدم دارو دارد. گفت با دکتر تلفن بزنم). این مهارت برای درک متون روایی ضروری است."
    },
    "b1-ch06-revision": {
        "title_fa": "مرور فصل ۶ B1: نقل قول غیرمستقیم",
    },
    # ── B1 Ch7 — Żeby ────────────────────────────────────────────────────────
    "b1-ch07-l01": {
        "title_fa": "żeby + مصدر — جملات هدف",
        "grammarPoint_fa": "żeby + مصدر وقتی فاعل هر دو بند یکی است",
        "explanation_fa": "żeby + مصدر وقتی فاعل هر دو بند یکسان است: Uczę się, żeby zdać egzamin (درس می‌خوانم تا امتحان قبول شوم). Idę do sklepu, żeby kupić chleb (می‌روم مغازه تا نان بخرم). این ساختار معادل «تا» در فارسی است و بسیار رایج‌تر از ساختار بعدی است."
    },
    "b1-ch07-l02": {
        "title_fa": "żeby + گذشته شرطی — فاعل‌های مختلف",
        "grammarPoint_fa": "żeby + گذشته (شرطی) وقتی فاعل‌های دو بند متفاوتند",
        "explanation_fa": "وقتی فاعل‌های دو بند متفاوتند از żeby + گذشته استفاده می‌شود: Chcę, żebyś przyszedł (می‌خواهم که بیایی). Proszę, żeby pan to zrobił (خواهش می‌کنم این کار را بکنید). توجه: گذشته در این ساختار معنای گذشته ندارد بلکه نشانه وجه التزامی است."
    },
    "b1-ch07-l03": {
        "title_fa": "żeby پس از chcieć، prosić، powiedzieć",
        "grammarPoint_fa": "افعالی که żeby می‌طلبند: chcieć، prosić، woleć، bać się، cieszyć się",
        "explanation_fa": "افعال رایج که żeby می‌طلبند: chcieć żeby (خواستن که)، prosić żeby (خواهش کردن که)، woleć żeby (ترجیح دادن که)، bać się żeby (ترسیدن که)، cieszyć się żeby (شادمان بودن که). پس از این افعال: żeby + گذشته اگر فاعل‌ها متفاوتند، żeby + مصدر اگر یکسانند."
    },
    "b1-ch07-l04": {
        "title_fa": "żeby — هدف، آرزو، دستور در بافت کامل",
        "grammarPoint_fa": "مرور کامل żeby در همه کاربردهایش",
        "explanation_fa": "żeby در چهار کاربرد: ۱) هدف (فاعل یکسان): Wychodzę, żeby pobiec (می‌روم تا بدوم). ۲) خواسته (فاعل‌های مختلف): Chcę, żebyś zrozumiał (می‌خواهم بفهمی). ۳) پس از دستور: Kazał mi, żebym przyszedł (دستور داد بیایم). ۴) آرزو: Oby żeby wszystko było dobrze (کاش همه چیز خوب باشد)."
    },
    "b1-ch07-revision": {
        "title_fa": "مرور فصل ۷ B1: جملات żeby",
    },
    # ── B1 Ch8 — Który ───────────────────────────────────────────────────────
    "b1-ch08-l01": {
        "title_fa": "جملات موصولی — który در حالت فاعلی",
        "grammarPoint_fa": "który (که) در حالت فاعلی برای توصیف اسم‌ها",
        "explanation_fa": "który (که) در جملات موصولی با جنسیت اسم مرجع تطبیق می‌یابد. در حالت فاعلی: مذکر: który (chłopiec, który...) — پسری که... مؤنث: która (kobieta, która...) — زنی که... خنثی: które (dziecko, które...) — بچه‌ای که... جمع مذکر جاندار: którzy، بقیه جمع: które."
    },
    "b1-ch08-l02": {
        "title_fa": "جملات موصولی — który در حالت مفعولی",
        "grammarPoint_fa": "który در حالت مفعولی (که ... را) — który/którą/które/których",
        "explanation_fa": "وقتی który نقش مفعول مستقیم دارد به حالت مفعولی می‌رود: Książka, którą czytam... (کتابی که می‌خوانم...). Chłopiec, którego widzę... (پسری که می‌بینم...). Dzieci, które lubię... (بچه‌هایی که دوست دارم...). توجه: حالت مفعولی مذکر جاندار = مضاف‌الیهی: którego."
    },
    "b1-ch08-l03": {
        "title_fa": "جملات موصولی — który در حالت مضاف‌الیهی و سایر حالت‌ها",
        "grammarPoint_fa": "który در حالت‌های مضاف‌الیهی، دادی، ابزاری، مکانی",
        "explanation_fa": "który در حالت‌های مختلف: مضاف‌الیهی: którego/której/których — dom, którego szukam (خانه‌ای که دنبالش می‌گردم). دادی: któremu/której/którym — człowiek, któremu pomogłem. ابزاری: którym/którą/którymi — długopis, którym piszę. مکانی: którym/której/których — miasto, w którym mieszkam."
    },
    "b1-ch08-l04": {
        "title_fa": "جملات موصولی در جملات پیچیده",
        "grammarPoint_fa": "ترکیب جملات موصولی در متون طولانی و پیچیده",
        "explanation_fa": "جملات موصولی پیچیده: Mężczyzna, który mieszka w tym domu, który stoi przy parku, jest moim przyjacielem (مردی که در آن خانه‌ای که کنار پارک است زندگی می‌کند، دوست من است). برای وضوح: جمله موصولی باید بلافاصله پس از اسم مرجع بیاید. در نوشتار رسمی از ساختارهای موصولی کوتاه‌تر استفاده کنید."
    },
    "b1-ch08-revision": {
        "title_fa": "مرور فصل ۸ B1: جملات موصولی با który",
    },
    # ── B1 Ch9 — Verbal Nouns ─────────────────────────────────────────────────
    "b1-ch09-l01": {
        "title_fa": "اسم مصدر با -nie",
        "grammarPoint_fa": "اسم مصدر ناکامل با -nie: czytanie، pisanie، uczenie się",
        "explanation_fa": "اسم مصدر با -nie از افعال ناکامل: mصدر: czytać → czytanie (خواندن به عنوان فعالیت). این اسم‌ها مانند اسم‌های خنثی رفتار می‌کنند و در همه حالت‌ها قابل استفاده‌اند: Czytanie książek jest przyjemne (کتاب خواندن لذتبخش است). Lubię czytanie (کتاب خواندن را دوست دارم). Po czytaniu (بعد از خواندن)."
    },
    "b1-ch09-l02": {
        "title_fa": "اسم مصدر با -cie",
        "grammarPoint_fa": "اسم مصدر با -cie: przyjście، wyjście، powiedzenie، zrobienie",
        "explanation_fa": "اسم مصدر با -cie معمولاً از افعال کامل: przyjść → przyjście (آمدن)، wyjść → wyjście (رفتن/خروج)، powiedzieć → powiedzenie (گفتن — نتیجه)، zrobić → zrobienie (انجام دادن). مقایسه: mówienie (فرآیند گفتن) در برابر powiedzenie (یک گفته خاص). zrobienie (انجام دادن) در برابر robienie (در حال انجام دادن)."
    },
    "b1-ch09-l03": {
        "title_fa": "اسم مصدر و وجه فعل",
        "grammarPoint_fa": "اسم مصدر کامل در برابر ناکامل: różnica między robieniem a zrobieniem",
        "explanation_fa": "اسم مصدر وجه را حفظ می‌کند: robienie (ناکامل — فرآیند): Lubię robienie pizzy (دوست دارم پیتزا درست کنم). zrobienie (کامل — نتیجه): Zrobienie tego zajęło godzinę (انجام این یک ساعت طول کشید). این تمایز در جملات رسمی و نوشتار علمی اهمیت دارد."
    },
    "b1-ch09-l04": {
        "title_fa": "اسم مصدر در بافت",
        "grammarPoint_fa": "کاربرد اسم مصدر در جملات پیچیده و متون رسمی",
        "explanation_fa": "کاربردهای اسم مصدر: فاعل: Uczenie się języków jest ważne (یادگیری زبان‌ها مهم است). مفعول: Lubię chodzenie na spacery (قدم زدن را دوست دارم). پس از حروف اضافه: Przed wyjściem z domu... (قبل از خروج از خانه...). Po zjedzeniu obiadu... (بعد از خوردن ناهار...). این ساختارها سبک نوشتار را رسمی‌تر می‌کنند."
    },
    "b1-ch09-revision": {
        "title_fa": "مرور فصل ۹ B1: اسم مصدرها",
    },
    # ── B1 Ch10 — Gerunds (full filename IDs) ────────────────────────────────
    "b1-ch10-l01-gerunds-imperfective": {
        "title_fa": "قیدهای فعلی ناکامل — فعالیت‌های عادت و کلی",
        "grammarPoint_fa": "قید فعلی ناکامل (imiesłów przysłówkowy współczesny): -ąc — czytając، mówiąc",
        "explanation_fa": "قید فعلی ناکامل (imiesłów przysłówkowy współczesny) با پسوند -ąc ساخته می‌شود: czytać → czytając (در حال خواندن)، mówić → mówiąc (در حال گفتن)، słuchać → słuchając. کاربرد: برای دو عمل همزمان: Słuchając muzyki, gotowałam obiad (در حالی که موسیقی گوش می‌دادم، ناهار درست می‌کردم). فاعل هر دو فعل باید یکسان باشد."
    },
    "b1-ch10-l02-gerunds-perfective": {
        "title_fa": "قیدهای فعلی کامل — اعمال متوالی و تمام‌شده",
        "grammarPoint_fa": "قید فعلی کامل (imiesłów przysłówkowy uprzedni): -wszy/-łszy — przeczytawszy، zrobiwszy",
        "explanation_fa": "قید فعلی کامل (imiesłów przysłówkowy uprzedni) با پسوند -wszy/-łszy ساخته می‌شود: przeczytać → przeczytawszy (پس از خواندن)، zrobić → zrobiwszy (پس از انجام دادن). کاربرد: برای عملی که قبل از فعل اصلی تمام شده: Przeczytawszy list, odłożył go (پس از خواندن نامه، آن را گذاشت). این ساختار در نوشتار ادبی و رسمی استفاده می‌شود."
    },
    "b1-ch10-l03-gerunds-aspect-distinction": {
        "title_fa": "قیدهای فعلی — انتخاب درست وجه",
        "grammarPoint_fa": "انتخاب بین قید فعلی ناکامل (-ąc) و کامل (-wszy/-łszy)",
        "explanation_fa": "قاعده انتخاب: ناکامل (-ąc): هر دو عمل همزمان هستند: Siedząc przy oknie, czytał (در حالی که کنار پنجره نشسته بود، می‌خواند). کامل (-wszy): اول یک عمل تمام می‌شود، سپس عمل دیگر: Zjadłszy obiad, wyszedł (بعد از خوردن ناهار، بیرون رفت). در گفتار روزمره اغلب از این ساختارها پرهیز می‌شود."
    },
    "b1-ch10-l04-gerunds-context": {
        "title_fa": "قیدهای فعلی در متون رسمی و ادبی",
        "grammarPoint_fa": "کاربرد قیدهای فعلی در سبک‌های مختلف نوشتاری",
        "explanation_fa": "قیدهای فعلی در سبک‌های مختلف: ادبی: Patrząc na gwiazdy, myślał o niej (در حالی که به ستاره‌ها نگاه می‌کرد، به او فکر می‌کرد). روزنامه‌ای: Opisując sytuację... (هنگام توصیف وضعیت...). علمی: Analizując dane... (در تحلیل داده‌ها...). در گفتار روزمره به جای این ساختارها از kiedy/po + اسم مصدر استفاده می‌شود."
    },
    # Note: b1-ch10 has no revision file in the list
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
