const fs = require('fs');
const { execSync } = require('child_process');

// The 50 already verified hadiths
const first50 = JSON.parse(fs.readFileSync('Sahih_Hadiths_50.json', 'utf8'));

// The next 50 strictly verified Sahih Hadiths (51 - 100)
const next50 = [
  {
    id: 51,
    chapter: "برایەتی و حەرامێتی زۆرداری و بێڕێزی",
    chapter_en: "Islamic Brotherhood & Forbidding Injustice",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "لا تَحَاسَدُوا، وَلا تَنَاجَشُوا، وَلا تَبَاغَضُوا، وَلا تَدَابَرُوا، وَلا يَبِعْ بَعْضُكُمْ عَلَى بَيْعِ بَعْضٍ، وَكُونُوا عِبَادَ اللَّهِ إِخْوَانًا، الْمُسْلِمُ أَخُو الْمُسْلِمِ: لا يَظْلِمُهُ، وَلا يَخْذُلُهُ، وَلا يَحْقِرُهُ، التَّقْوَى هَاهُنَا - وَيُشِيرُ إِلَى صَدْرِهِ ثَلاثَ مَرَّاتٍ - بِحَسْبِ امْرِئٍ مِنَ الشَّرِّ أَنْ يَحْقِرَ أَخَاهُ الْمُسْلِمَ، كُلُّ الْمُسْلِمِ عَلَى الْمُسْلِمِ حَرَامٌ: دَمُهُ، وَمَالُهُ، وَعِرْضُهُ.",
    text_ku: "حەسوودی بە یەکتر مەبەن، و لە کڕین و فرۆشتندا نرخی شت بۆ فریودان بەرز مەکەنەوە، و ڕقتان لە یەکتر نەبێت، و پشت لە یەکتر مەکەن، و لەسەر کڕینی یەکتر مامەڵە مەکەن، و ببن بە بەندەی خودای برای یەکتر؛ موسڵمان برای موسڵمانە: ستەمی لێ ناکات، و لە کاتی تەنگانەدا بە تەنیا جێی ناهێڵێت، و بە کەمی نازانێت، تەقوا و لەخواترسی لێرەدایە - و سێ جار ئاماژەی بە سنگ و دڵی خۆی کرد - بۆ مرۆڤ لە بەدی و خراپە بەسە کە برا موسڵمانەکەی بە کەم بزانێت، هەموو موسڵمانێک خوێنی و ماڵی و نامووسی لەسەر موسڵمانی تر حەرام و پارێزراوە.",
    text_en: "Do not envy one another, do not inflate prices against one another, do not hate one another, do not turn away from one another, do not undercut one another in trade, and be servants of Allah, brothers. A Muslim is a brother of a Muslim: he does not oppress him, nor abandon him, nor look down upon him. Piety is here—and he pointed to his chest three times. It is evil enough for a man to despise his Muslim brother. All of a Muslim is sacred to another Muslim: his blood, his wealth, and his honor.",
    source: "أخرجه مسلم (2564)",
    grade: "صحيح"
  },
  {
    id: 52,
    chapter: "پابەندبوون بە سوننەت و ڕەتکردنەوەی داهێنراو",
    chapter_en: "Adhering to the Sunnah & Rejecting Innovation",
    narrator_ar: "عَنْ أُمِّ الْمُؤْمِنِينَ عَائِشَةَ رَضِيَ اللَّهُ عَنْهَا",
    text_ar: "مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ فِيهِ فَهُوَ رَدٌّ.",
    text_ku: "هەر کەسێک شتێکی نوێ لەم دینەماندا دابهێنێت کە لە بنەمای دینەکەدا نەبێت، ئەوا ئەو کارەی ڕەتکراوەیە و قبووڵ ناکرێت.",
    text_en: "Whoever innovates into this affair of ours something which is not from it, it will be rejected.",
    source: "متفق عليه: أخرجه البخاري (2697)، ومسلم (1718)",
    grade: "صحيح"
  },
  {
    id: 53,
    chapter: "حەڵاڵ و حەرام و پاکێتی دڵ",
    chapter_en: "The Halal, Haram & Purity of the Heart",
    narrator_ar: "عَنِ النُّعْمَانِ بْنِ بَشِيرٍ رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "إِنَّ الْحَلالَ بَيِّنٌ، وَإِنَّ الْحَرَامَ بَيِّنٌ، وَبَيْنَهُمَا مُشْتَبِهَاتٌ لا يَعْلَمُهُنَّ كَثِيرٌ مِنَ النَّاسِ، فَمَنِ اتَّقَى الشُّبُهَاتِ اسْتَبْرَأَ لِدِينِهِ وَعِرْضِهِ، وَمَنْ وَقَعَ فِي الشُّبُهَاتِ وَقَعَ فِي الْحَرَامِ... أَلا وَإِنَّ فِي الْجَسَدِ مُضْغَةً إِذَا صَلَحَتْ صَلَحَ الْجَسَدُ كُلُّهُ، وَإِذَا فَسَدَتْ فَسَدَ الْجَسَدُ كُلُّهُ، أَلا وَهِيَ الْقَلْبُ.",
    text_ku: "بەڕاستی حەڵاڵ ئاشکرا و ڕوونە، و حەرامیش ئاشکرا و ڕوونە، و لە نێوانیشیاندا کۆمەڵێک شتی گوماناوی هەن کە زۆربەی خەڵکی دروستییەکەی نازانن، جا هەر کەسێک خۆی لە گومانەکان بپارێزێت دین و نامووسی خۆی پاراستووە، و هەر کەسێک بکەوێتە ناو گومانەکانەوە دەکەوێتە ناو حەرامەوە... ئاگاداربن پارچە گۆشتێک لە جەستەدا هەیە ئەگەر چاک بێت سەرجەم جەستە چاک دەبێت، و ئەگەر خراپ بێت سەرجەم جەستە خراپ دەبێت، ئاگاداربن ئەویش دڵە.",
    text_en: "Verily, what is lawful is clear and what is unlawful is clear, and between them are doubtful matters which many people do not know. Whoever guards against doubtful matters clears himself in regard to his religion and honor, but whoever falls into doubtful matters falls into that which is unlawful... Truly, in the body there is a morsel of flesh: if it is sound, the whole body is sound; and if it is corrupt, the whole body is corrupt. Truly, it is the heart.",
    source: "متفق عليه: أخرجه البخاري (52)، ومسلم (1599)",
    grade: "صحيح"
  },
  {
    id: 54,
    chapter: "گۆڕینی خراپە و بەرگریکردن لە چاکە",
    chapter_en: "Changing Evil & Protecting Good",
    narrator_ar: "عَنْ أَبِي سَعِيدٍ الْخُدْرِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ رَأَى مِنْكُمْ مُنْكَرًا فَلْيُغَيِّرْهُ بِيَدِهِ، فَإِنْ لَمْ يَسْتَطِعْ فَبِلِسَانِهِ، فَإِنْ لَمْ يَسْتَطِعْ فَبِقَلْبِهِ، وَذَلِكَ أَضْعَفُ الإِيمَانِ.",
    text_ku: "هەر یەکێکتان خراپەیەکی بینی با بە دەستی بیگۆڕێت، ئەگەر نەیتوانی با بە زمانی ڕێگری لێ بکات، ئەگەر نەیتوانی با بە دڵی لێی ناڕازی بێت، و ئەوەش لاوازترین پلەی باوەڕە.",
    text_en: "Whoever of you sees an evil, let him change it with his hand; and if he is not able, then with his tongue; and if he is not able, then with his heart—and that is the weakest of faith.",
    source: "أخرجه مسلم (49)",
    grade: "صحيح"
  },
  {
    id: 55,
    chapter: "پشتکردن لە دونیاپەرستی و بەدەستهێنانی خۆشەویستی خوا",
    chapter_en: "Asceticism & Love of Allah and People",
    narrator_ar: "عَنْ سَهْلِ بْنِ سَعْدٍ السَّاعِدِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "أَتَى النَّبِيَّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ رَجُلٌ، فَقَالَ: يَا رَسُولَ اللَّهِ! دُلَّنِي عَلَى عَمَلٍ إِذَا عَمِلْتُهُ أَحَبَّنِي اللَّهُ وَأَحَبَّنِي النَّاسُ، فَقَالَ: «ازْهَدْ فِي الدُّنْيَا يُحِبَّكَ اللَّهُ، وَازْهَدْ فِيمَا فِي أَيْدِي النَّاسِ يُحِبَّكَ النَّاسُ».",
    text_ku: "پیاوێک هات بۆ لای پێغەمبەر (ﷺ) و وتی: ئەی پێغەمبەری خودا! ڕێنموونیم بکە بۆ کردەوەیەک کە ئەگەر ئەنجامی بدەم خوای گەورە منی خۆشبوێت و خەڵکیش منیان خۆشبوێت، پێغەمبەر (ﷺ) فەرمووی: «چاوچنۆک مەبە بۆ دونیا خوای گەورە تۆی خۆشدەوێت، و چاوت لەوە نەبێت کە لە دەستی خەڵکیدایە خەڵکیش تۆیان خۆشدەوێت».",
    text_en: "A man came to the Prophet (ﷺ) and said: 'O Messenger of Allah, direct me to an act which, if I do it, Allah will love me and people will love me.' He said: 'Be detached from this world, Allah will love you; and be detached from what is in people's hands, people will love you.'",
    source: "أخرجه ابن ماجه (4102) وصححه النووي والألباني",
    grade: "صحيح"
  },
  {
    id: 56,
    chapter: "حەرامێتی زیانگەیاندن بە خۆ و خەڵک",
    chapter_en: "No Harming nor Reciprocating Harm",
    narrator_ar: "عَنْ عُبَادَةَ بْنِ الصَّامِتِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "لا ضَرَرَ وَلا ضِرَارَ.",
    text_ku: "هیچ زیانێک بۆ خۆ دروست نییە، و زیانگەیاندن بە بەرامبەریش ڕێگەپێنەدراوە لە ئیسلامدا.",
    text_en: "There should be neither harming nor reciprocating harm.",
    source: "أخرجه ابن ماجه (2340)، والإمام أحمد، وصححه النووي والألباني",
    grade: "صحيح"
  },
  {
    id: 57,
    chapter: "ئادابی دادوەری و مافەکان",
    chapter_en: "Judicial Principles & Evidence",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ عَبَّاسٍ رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "لَوْ يُعْطَى النَّاسُ بِدَعْوَاهُمْ، لادَّعَى رِجَالٌ أَمْوَالَ قَوْمٍ وَدِمَاءَهُمْ، لَكِنِ الْبَيِّنَةُ عَلَى الْمُدَّعِي، وَالْيَمِينُ عَلَى مَنْ أَنْكَرَ.",
    text_ku: "ئەگەر بە گوێرەی تەنها داواکاری و ئیدعاکان ماف بە خەڵکی بدرایە، کەسانێک داوای ماڵ و خوێنی خەڵکیان دەکرد، بەڵام بەڵگە و شایەت لەسەر داواکارە، و سوێندخواردنیش لەسەر ئەو کەسەیە کە دان بە تاوانەکەدا نانێت.",
    text_en: "Were people to be given everything they claimed, men would lay claim to the property of others and their blood. But the burden of proof is upon the claimant, and the oath is upon the one who denies.",
    source: "أخرجه البيهقي في السنن، وأصله في الصحيحين",
    grade: "صحيح"
  },
  {
    id: 58,
    chapter: "میانڕەوی لە خواردن و پاراستنی تەندروستی",
    chapter_en: "Moderation in Eating & Health",
    narrator_ar: "عَنِ الْمِقْدَامِ بْنِ مَعْدِيكَرِبَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَا مَلأَ آدَمِيٌّ وِعَاءً شَرًّا مِنْ بَطْنٍ، بِحَسْبِ ابْنِ آدَمَ أُكُلاتٌ يُقِمْنَ صُلْبَهُ، فَإِنْ كَانَ لا مَحَالَةَ فَثُلُثٌ لِطَعَامِهِ، وَثُلُثٌ لِشَرَابِهِ، وَثُلُثٌ لِنَفَسِهِ.",
    text_ku: "مرۆڤ هیچ دەفرێکی خراپتر لە سکی خۆی پڕ نەکردووە، بەشی نەوەی ئادەم چەند پاروویەکە کە پشتی پێ ڕابگرێت، خۆ ئەگەر هەر ناچار بوو زیاتر بخوات با سێیەکی بۆ خواردنەکەی بێت، و سێیەکی بۆ خواردنەوەکەی، و سێیەکی بۆ هەناسەدانی بەجێبهێڵێت.",
    text_en: "A human being fills no vessel worse than his stomach. A few morsels are sufficient for a person to keep his back straight. But if he must, then one third for his food, one third for his drink, and one third for his breath.",
    source: "أخرجه الترمذي (2380) وقال: حديث حسن صحيح، وأحمد (17161)",
    grade: "صحيح"
  },
  {
    id: 59,
    chapter: "چوار کلیلی بەهەشت",
    chapter_en: "Four Keys to Enter Paradise in Peace",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ سَلامٍ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "يَا أَيُّهَا النَّاسُ! أَفْشُوا السَّلامَ، وَأَطْعِمُوا الطَّعَامَ، وَصِلُوا الأَرْحَامَ، وَصَلُّوا بِاللَّيْلِ وَالنَّاسُ نِيَامٌ، تَدْخُلُوا الْجَنَّةَ بِسَلامٍ.",
    text_ku: "ئەی خەڵکینە! سەلام بڵاوبکەنەوە لە نێوانتاندا، و خواردن ببەخشن بە لێقەوماوان، و پەیوەندی خزمایەتی بپارێزن، و بە شەودا نوێژ بکەن کاتێک خەڵکی خەوتوون، بە سەلامەتی و ئارامی دەچنە بەهەشتەوە.",
    text_en: "O people! Spread peace, feed the hungry, uphold ties of kinship, and pray at night while people are asleep, you will enter Paradise in peace.",
    source: "أخرجه الترمذي (2485) وقال: حديث حسن صحيح، وابن ماجه (1334)",
    grade: "صحيح"
  },
  {
    id: 60,
    chapter: "پاداشتی درەخت ڕواندن و کشتوکاڵ",
    chapter_en: "Reward of Planting Trees & Agriculture",
    narrator_ar: "عَنْ أَنَسِ بْنِ مَالِكٍ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَا مِنْ مُسْلِمٍ يَغْرِسُ غَرْسًا، أَوْ يَزْرَعُ زَرْعًا، فَيَأْكُلُ مِنْهُ طَيْرٌ أَوْ إِنْسَانٌ أَوْ بَهِيمَةٌ، إِلاَّ كَانَ لَهُ بِهِ صَدَقَةٌ.",
    text_ku: "هیچ موسڵمانێک نییە نەمامێک بڕوێنێت، یاخود کشتوکاڵێک بکات، جا باڵندەیەک یان مرۆڤێک یان ئاژەڵێک لێی بخوات، ئیللا خوای گەورە پاداشتی خێر و سەدەقەی بۆ دەنووسێت.",
    text_en: "There is no Muslim who plants a tree or sows seeds, and then a bird, a person, or an animal eats from it, but that it is regarded as a charity for him.",
    source: "متفق عليه: أخرجه البخاري (2320)، ومسلم (1553)",
    grade: "صحيح"
  },
  {
    id: 61,
    chapter: "گرنگی نوێژی بەیانی و عیشا بە جەماعەت",
    chapter_en: "Fajr & Isha in Congregation",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "إِنَّ أَثْقَلَ صَلاةٍ عَلَى الْمُنَافِقِينَ صَلاةُ الْعِشَاءِ وَصَلاةُ الْفَجْرِ، وَلَوْ يَعْلَمُونَ مَا فِيهِمَا لأَتَوْهُمَا وَلَوْ حَبْوًا.",
    text_ku: "بەڕاستی قورسترین نوێژ لەسەر دووڕووەکان (مونافیقان) نوێژی عیشا و نوێژی بەیانییە، و ئەگەر بییانزانیایە چ پاداشت و فەزڵێکی گەورەیان تێدایە بە چۆکدادان و خشینیش بووایە دەهاتن بۆیان.",
    text_en: "Indeed, the most burdensome prayers for the hypocrites are the Isha prayer and the Fajr prayer. If they only knew what they contain, they would come to them even if they had to crawl.",
    source: "متفق عليه: أخرجه البخاري (657)، ومسلم (651)",
    grade: "صحيح"
  },
  {
    id: 62,
    chapter: "فەزڵی نوێژی بەیانی و عەسر",
    chapter_en: "Virtue of Fajr & Asr Prayers",
    narrator_ar: "عَنْ أَبِي مُوسَى الأَشْعَرِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ.",
    text_ku: "هەر کەسێک نوێژی بەیانی و نوێژی عەسر ئەنجام بدات بە شێوەیەکی بەردەوام دەچێتە بەهەشتەوە.",
    text_en: "Whoever performs the two cool prayers (Fajr and Asr) will enter Paradise.",
    source: "متفق عليه: أخرجه البخاري (574)، ومسلم (635)",
    grade: "صحيح"
  },
  {
    id: 63,
    chapter: "پارێزگاری خودا بۆ ئەنجامدەری نوێژی بەیانی",
    chapter_en: "Under Allah's Protection After Fajr",
    narrator_ar: "عَنْ جُنْدُبِ بْنِ عَبْدِ اللَّهِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ صَلَّى الصُّبْحَ فَهُوَ فِي ذِمَّةِ اللَّهِ، فَلا يَطْلُبَنَّكُمُ اللَّهُ مِنْ ذِمَّتِهِ بِشَيْءٍ، فَإِنَّهُ مَنْ يَطْلُبْهُ مِنْ ذِمَّتِهِ بِشَيْءٍ يُدْرِكْهُ ثُمَّ يَكُبَّهُ عَلَى وَجْهِهِ فِي نَارِ جَهَنَّمَ.",
    text_ku: "هەر کەسێک نوێژی بەیانی بکات ئەوا لە پەنا و پارێزگاری خودایە، کەواتە وریابن کەسێک ئازار نەدەن کە لە پەنای خودادایە، چونکە هەر کەسێک کەسێک ئازار بدات کە لە پارێزگاری خودادایە، خوا لێپێچینەوەی لەگەڵدا دەکات و سەرەوژێر فڕێی دەداتە ناو ئاگری دۆزەخەوە.",
    text_en: "Whoever offers the dawn prayer is under the protection of Allah. So be careful that Allah does not call you to account for infringing upon His protection...",
    source: "أخرجه مسلم (657)",
    grade: "صحيح"
  },
  {
    id: 64,
    chapter: "پاداشتی دە چاکە بۆ هەر پیتێکی قورئان",
    chapter_en: "Ten Rewards for Each Letter of the Quran",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ مَسْعُودٍ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ قَرَأَ حَرْفًا مِنْ كِتَابِ اللَّهِ فَلَهُ بِهِ حَسَنَةٌ، وَالْحَسَنَةُ بِعَشْرِ أَمْثَالِهَا، لا أَقُولُ: الم حَرْفٌ، وَلَكِنْ: أَلِفٌ حَرْفٌ، وَلامٌ حَرْفٌ، وَمِيمٌ حَرْفٌ.",
    text_ku: "هەر کەسێک پیتێک لە پەڕتووکی خودا بخوێنێتەوە ئەوا چاکەیەکی بۆ دەنووسرێت، و هەر چاکەیەکیش بە دە بەرامبەر پاداشت دەدرێتەوە، ناڵێم: (الم) یەک پیتە، بەڵکو: ئەلیف پیتێکە، و لام پیتێکە، و میم پیتێکە.",
    text_en: "Whoever recites a letter from the Book of Allah, he will receive one good deed, and ten like it. I do not say that Alif-Lam-Meem is one letter, but Alif is a letter, Lam is a letter, and Meem is a letter.",
    source: "أخرجه الترمذي (2910) وقال: حديث حسن صحيح",
    grade: "صحيح"
  },
  {
    id: 65,
    chapter: "فەزڵی خوێنەری شارەزای قورئان",
    chapter_en: "Proficiency in Quran Recitation",
    narrator_ar: "عَنْ عَائِشَةَ رَضِيَ اللَّهُ عَنْهَا",
    text_ar: "الْمَاهِرُ بِالْقُرْآنِ مَعَ السَّفَرَةِ الْكِرَامِ الْبَرَرَةِ، وَالَّذِي يَقْرَأُ الْقُرْآنَ وَيَتَتَعْتَعُ فِيهِ، وَهُوَ عَلَيْهِ شَاقٌّ، لَهُ أَجْرَانِ.",
    text_ku: "ئەو کەسەی کە لە خوێندنەوەی قورئاندا شارەزا و لێهاتووە هاوڕێی فریشتە بەڕێز و چاکەکارەکان دەبێت، و ئەو کەسەشی کە قورئان دەخوێنێت و دەمی تێکدەچێت و بە قورسی بۆی دەخوێندرێت، ئەوا دوو پاداشتی بۆ هەیە.",
    text_en: "The one who is proficient in the recitation of the Quran will be with the honorable, obedient noble angels; and he who recites the Quran and stammers in it, and it is difficult for him, will have two rewards.",
    source: "متفق عليه: أخرجه البخاري (4937)، ومسلم (798)",
    grade: "صحيح"
  },
  {
    id: 66,
    chapter: "قورئان تکاکاری ڕۆژی قیامەتە",
    chapter_en: "The Quran as an Intercessor",
    narrator_ar: "عَنْ أَبِي أُمَامَةَ الْبَاهِلِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "اقْرَؤُوا الْقُرْآنَ، فَإِنَّهُ يَأْتِي يَوْمَ الْقِيَامَةِ شَفِيعًا لأَصْحَابِهِ.",
    text_ku: "قورئانی پیرۆز بخوێنن، چونکە بەڕاستی لە ڕۆژی دواییدا دێتە مەیدان و دەبێت بە تکاکار و شەفاعەتکار بۆ خوێنەرەکانی.",
    text_en: "Read the Quran, for indeed it will come on the Day of Resurrection as an intercessor for its companions.",
    source: "أخرجه مسلم (804)",
    grade: "صحيح"
  },
  {
    id: 67,
    chapter: "پاداشتی شەش ڕۆژەی شەوال",
    chapter_en: "Six Days of Shawwal After Ramadan",
    narrator_ar: "عَنْ أَبِي أَيُّوبَ الأَنْصَارِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتًّا مِنْ شَوَّالٍ، كَانَ كَصِيَامِ الدَّهْرِ.",
    text_ku: "هەر کەسێک مانگی ڕەمەزان بەڕۆژوو بێت و پاشان شەش ڕۆژ لە مانگی شەوال بەدوایدا بەڕۆژوو بێت، وەک ئەوە وایە کە سەرانسەری ساڵەکە بەڕۆژوو بووبێت.",
    text_en: "Whoever fasts Ramadan, then follows it with six days from Shawwal, it is as if he fasted for a whole year.",
    source: "أخرجه مسلم (1164)",
    grade: "صحيح"
  },
  {
    id: 68,
    chapter: "فەزڵی عەمرە لە مانگی ڕەمەزاندا",
    chapter_en: "Umrah in Ramadan Equivalent to Hajj",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ عَبَّاسٍ رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "عُمْرَةٌ فِي رَمَضَانَ تَقْضِي حَجَّةً مَعِي.",
    text_ku: "ئەنجامدانی عەمرەیەک لە مانگی ڕەمەزاندا، هاوتای خێری حەجکردنێکە لەگەڵ مندا.",
    text_en: "Performing Umrah in Ramadan is equivalent to performing Hajj with me.",
    source: "متفق عليه: أخرجه البخاري (1863)، ومسلم (1256)",
    grade: "صحيح"
  },
  {
    id: 69,
    chapter: "فەزڵی عەمرە و حەجی وەرگیراو",
    chapter_en: "Virtue of Accepted Hajj & Umrah",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "الْعُمْرَةُ إِلَى الْعُمْرَةِ كَفَّارَةٌ لِمَا بَيْنَهُمَا، وَالْحَجُّ الْمَبْرُورُ لَيْسَ لَهُ جَزَاءٌ إِلاَّ الْجَنَّةُ.",
    text_ku: "عەمرەیەک تا عەمرەیەکی تر دەبێتە کەفارەت و سڕینەوەی گوناهەکانی نێوانیان، و حەجی وەرگیراویش جگە لە بەهەشت هیچ پاداشتێکی تری نییە.",
    text_en: "From one Umrah to the next is an expiation for whatever sins occur between them, and for an accepted Hajj there is no reward except Paradise.",
    source: "متفق عليه: أخرجه البخاري (1773)، ومسلم (1349)",
    grade: "صحيح"
  },
  {
    id: 70,
    chapter: "دوعاکردن بۆ برای موسڵمان لە غەیبدا",
    chapter_en: "Supplicating for a Brother in His Absence",
    narrator_ar: "عَنْ أَبِي الدَّرْدَاءِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَا مِنْ عَبْدٍ مُسْلِمٍ يَدْعُو لأَخِيهِ بِظَهْرِ الْغَيْبِ، إِلاَّ قَالَ الْمَلَكُ: وَلَكَ بِمِثْلٍ.",
    text_ku: "هیچ بەندەیەکی موسڵمان نییە لە غیابدا دوعای خێر بۆ براکەی بکات، ئیللا فریشتە پێی دەڵێت: ئامین و بۆ تۆش هاوشێوەی ئەوە هەبێت.",
    text_en: "No Muslim servant supplicates for his brother behind his back but that the angel says: 'And for you the same.'",
    source: "أخرجه مسلم (2732)",
    grade: "صحيح"
  },
  {
    id: 71,
    chapter: "نزیکترین حاڵەت لە پەروەردگار",
    chapter_en: "Nearest State to Allah in Prostration",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ، فَأَكْثِرُوا الدُّعَاءَ.",
    text_ku: "نزیکترین کات کە بەندە لێیەوە نزیک بێت لە پەروەردگارییەوە ئەو کاتەیە کە لە سوجدەدایە، کەواتە زۆر دوعا و پاڕانەوە بکەن لە سوجدەدا.",
    text_en: "The nearest a servant comes to his Lord is when he is in prostration, so supplicate abundantly.",
    source: "أخرجه مسلم (482)",
    grade: "صحيح"
  },
  {
    id: 72,
    chapter: "دابەزینی خودا لە سێیەکی کۆتایی شەودا",
    chapter_en: "Descent of Allah in Last Third of Night",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "يَنْزِلُ رَبُّنَا تَبَارَكَ وَتَعَالَى كُلَّ لَيْلَةٍ إِلَى السَّمَاءِ الدُّنْيَا حِينَ يَبْقَى ثُلُثُ اللَّيْلِ الآخِرُ، يَقُولُ: مَنْ يَدْعُونِي فَأَسْتَجِيبَ لَهُ؟ مَنْ يَسْأَلُنِي فَأُعْطِيَهُ؟ مَنْ يَسْتَغْفِرُنِي فَأَغْفِرَ لَهُ؟",
    text_ku: "پەروەردگارمان هەموو شەوێک کاتێک سێیەکی کۆتایی شەو دەمێنێت دادەبەزێتە ئاسمانی دونیا و دەفەرموێت: کێیە لێم بپاڕێتەوە تا وەڵامی بدەمەوە؟ کێیە داوای شتێکم لێ بکات تا پێی ببەخشم؟ کێیە داوای لێخۆشبوونم لێ بکات تا لێی خۆش ببم؟",
    text_en: "Our Lord, Blessed and Exalted is He, descends every night to the nearest heaven during the last third of the night, saying: 'Who calls upon Me so that I may respond? Who asks of Me so that I may give? Who seeks My forgiveness so that I may forgive him?'",
    source: "متفق عليه: أخرجه البخاري (1145)، ومسلم (758)",
    grade: "صحيح"
  },
  {
    id: 73,
    chapter: "تەوبەکردن پێش هەڵهاتنی خۆر لە خۆرئاواوە",
    chapter_en: "Repentance Before Sun Rises from the West",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ تَابَ قَبْلَ أَنْ تَطْلُعَ الشَّمْسُ مِنْ مَغْرِبِهَا، تَابَ اللَّهُ عَلَيْهِ.",
    text_ku: "هەر کەسێک تەوبە بکات پێش ئەوەی خۆر لە ڕۆژئاواوە هەڵبێت (نیشانە گەورەکانی قیامەت)، خوای گەورە تەوبەکەی لێ قبووڵ دەکات.",
    text_en: "Whoever repents before the sun rises from the west, Allah will accept his repentance.",
    source: "أخرجه مسلم (2703)",
    grade: "صحيح"
  },
  {
    id: 74,
    chapter: "داوای لێخۆشبوون و ئیستیغفاری پێغەمبەر ﷺ",
    chapter_en: "Seeking Forgiveness Over 70 Times a Day",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "وَاللَّهِ إِنِّي لأَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ فِي الْيَوْمِ أَكْثَرَ مِنْ سَبْعِينَ مَرَّةً.",
    text_ku: "سوێند بە خودا بەڕاستی من لە ڕۆژێکدا زیاتر لە حەفتا جار داوای لێخۆشبوون لە خودا دەکەم و تەوبەی بۆ دەبەمەوە.",
    text_en: "By Allah, I seek forgiveness from Allah and repent to Him more than seventy times a day.",
    source: "أخرجه البخاري (6307)",
    grade: "صحيح"
  },
  {
    id: 75,
    chapter: "سەروەری داوای لێخۆشبوون (سيد الاستغفار)",
    chapter_en: "The Master Supplication for Forgiveness",
    narrator_ar: "عَنْ شَدَّادِ بْنِ أَوْسٍ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "سَيِّدُ الاسْتِغْفَارِ أَنْ تَقُولَ: اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي فَإِنَّهُ لا يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ.",
    text_ku: "سەروەری زیکرەکانی داوای لێخۆشبوون ئەوەیە کە بڵێیت: خودایە تۆ پەروەردگاری منی، هیچ پەرستراوێک نییە شایەنی پەرستن بێت جگە لە تۆ، تۆ منت دروستکردووە و من بەندەی تۆم، و لەسەر پەیمان و بەڵێنی تۆم تا ئەو پەڕی توانام، پەنات پێ دەگرم لە شەڕی هەموو ئەو خراپانەی کە کردوومە، دان دەنێم بە نیعمەتەکانت بەسەرمەوە و دان دەنێم بە گوناه و تاوانەکانمدا، لێم خۆشبە چونکە هیچ کەسێک لە گوناهەکان خۆش نابێت جگە لە تۆ.",
    text_en: "The master invocation for seeking forgiveness is to say: 'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant, and I uphold Your covenant and promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge Your favors upon me and I confess my sins, so forgive me, for none forgives sins except You.'",
    source: "أخرجه البخاري (6306)",
    grade: "صحيح"
  },
  {
    id: 76,
    chapter: "فەزڵی سەد جار (سبحان الله وبحمده)",
    chapter_en: "Subhan Allahi wa Bihamdih 100 Times",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ قَالَ حِينَ يُصْبِحُ وَحِينَ يُمْسِي: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ مِائَةَ مَرَّةٍ، لَمْ يَأْتِ أَحَدٌ يَوْمَ الْقِيَامَةِ بِأَفْضَلَ مِمَّا جَاءَ بِهِ، إِلاَّ أَحَدٌ قَالَ مِثْلَ مَا قَالَ أَوْ زَادَ عَلَيْهِ.",
    text_ku: "هەر کەسێک بەیانیان و ئێواران سەد جار بڵێت: (سُبْحَانَ اللَّهِ وَبِحَمْدِهِ)، لە ڕۆژی قیامەتدا هیچ کەسێک کردەوەی چاکتری لەو پێنەبووە مەگەر کەسێک نەبێت هاوشێوەی ئەو یان زیاتری وتبێت.",
    text_en: "Whoever says in the morning and evening, 'Subhan Allahi wa bihamdih' one hundred times, no one will come on the Day of Resurrection with anything better than what he has brought, except someone who said the same or more.",
    source: "أخرجه مسلم (2692)",
    grade: "صحيح"
  },
  {
    id: 77,
    chapter: "حەرامێتی سوێندخواردن بە غەیری خودا",
    chapter_en: "Prohibition of Swearing by Other than Allah",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ عُمَرَ رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "مَنْ حَلَفَ بِغَيْرِ اللَّهِ فَقَدْ كَفَرَ أَوْ أَشْرَكَ.",
    text_ku: "هەر کەسێک سوێند بە غەیری خوای گەورە بخوات، ئەوا کوفر یان شیرکی کردووە.",
    text_en: "Whoever swears by other than Allah has committed an act of disbelief or polytheism.",
    source: "أخرجه الترمذي (1535) وصححه، وأبو داود (3251)",
    grade: "صحيح"
  },
  {
    id: 78,
    chapter: "مەترسی تەرککردنی نوێژی عەسر",
    chapter_en: "Warning Against Neglecting Asr Prayer",
    narrator_ar: "عَنْ بُرَيْدَةَ بْنِ الْحُصَيْبِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ تَرَكَ صَلاةَ الْعَصْرِ فَقَدْ حَبِطَ عَمَلُهُ.",
    text_ku: "هەر کەسێک نوێژی عەسر بە ئەنقەست بەجێبهێڵێت و نەیکات، بەڕاستی کردەوەکانی پووچەڵ دەبنەوە.",
    text_en: "Whoever neglects the Asr prayer, his good deeds will be rendered null and void.",
    source: "أخرجه البخاري (553)",
    grade: "صحيح"
  },
  {
    id: 79,
    chapter: "جیاکەرەوەی باوەڕ و بێباوەڕی نوێژە",
    chapter_en: "Prayer Between a Man & Disbelief",
    narrator_ar: "عَنْ جَابِرِ بْنِ عَبْدِ اللَّهِ رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "إِنَّ بَيْنَ الرَّجُلِ وَبَيْنَ الشِّرْكِ وَالْكُفْرِ تَرْكَ الصَّلاةِ.",
    text_ku: "بەڕاستی لە نێوان مرۆڤ و شیرک و کوفردا تەنها بەجێهێشتنی نوێژە.",
    text_en: "Verily, between a man and polytheism and disbelief is the abandonment of prayer.",
    source: "أخرجه مسلم (82)",
    grade: "صحيح"
  },
  {
    id: 80,
    chapter: "پەیمانی نێوان ئێمە و ئەوان نوێژە",
    chapter_en: "The Covenant of Prayer",
    narrator_ar: "عَنْ بُرَيْدَةَ بْنِ الْحُصَيْبِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "الْعَهْدُ الَّذِي بَيْنَنَا وَبَيْنَهُمُ الصَّلاةُ، فَمَنْ تَرَكَهَا فَقَدْ كَفَرَ.",
    text_ku: "ئەو پەیمان و بەڵێنەی لە نێوان ئێمە و ئەواندایە بریتییە لە ئەنجامدانی نوێژ، جا هەر کەسێک نوێژ بەجێبهێڵێت ئەوا بێباوەڕ بووە.",
    text_en: "The covenant that stands between us and them is the prayer; whoever abandons it has disbelieved.",
    source: "أخرجه الترمذي (2621) والنسائي (463) وصححه الألباني",
    grade: "صحيح"
  },
  {
    id: 81,
    chapter: "پێنج نوێژەکە و هەینی کەفارەتی گوناهەکانن",
    chapter_en: "Five Prayers & Friday Expunging Sins",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "الصَّلَوَاتُ الْخَمْسُ، وَالْجُمُعَةُ إِلَى الْجُمُعَةِ، وَرَمَضَانُ إِلَى رَمَضَانَ، مُكَفِّرَاتٌ مَا بَيْنَهُنَّ إِذَا اجْتُنِبَتِ الْكَبَائِرُ.",
    text_ku: "پێنج نوێژە فەرزەکە، و نوێژی هەینی بۆ هەینی داهاتوو، و مانگی ڕەمەزان بۆ ڕەمەزانی داهاتوو، کەفارەت و سڕینەوەی گوناهەکانی نێوانیانن ئەگەر مرۆڤ لە گوناهە گەورەکان (کەبائیر) دووربکەوێتەوە.",
    text_en: "The five daily prayers, from one Friday prayer to the next, and from one Ramadan to the next, are expiations for whatever sins occur between them, provided major sins are avoided.",
    source: "أخرجه مسلم (233)",
    grade: "صحيح"
  },
  {
    id: 82,
    chapter: "فەزڵی زوو ڕۆیشتن بۆ نوێژی هەینی بە پێ",
    chapter_en: "Walking Early to Friday Congregation",
    narrator_ar: "عَنْ أَوْسِ بْنِ أَوْسٍ الثَّقَفِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ غَسَّلَ يَوْمَ الْجُمُعَةِ وَاغْتَسَلَ، ثُمَّ بَكَّرَ وَابْتَكَرَ، وَمَشَى وَلَمْ يَرْكَبْ، وَدَنَا مِنَ الإِمَامِ فَاسْتَمَعَ وَلَمْ يَلْغُ، كَانَ لَهُ بِكُلِّ خُطْوَةٍ عَمَلُ سَنَةٍ: أَجْرُ صِيَامِهَا وَقِيَامِهَا.",
    text_ku: "هەر کەسێک لە ڕۆژی هەینیدا سەری بشوات و خۆی بشوات، پاشان زوو بەرەو مزگەوت بکەوێتەڕێ، و بە پێ بڕوات نەک بە سواری، و لە پێشنوێژ نزیک بکەوێتەوە و بە بێدەنگی گوێ بگرێت، بۆ هەر هەنگاوێکی کە دەینێت پاداشتی عیبادەتی ساڵێکی تەواوی بۆ دەنووسرێت: بە ڕۆژووەکانی و بە شەونوێژەکانیەوە.",
    text_en: "Whoever washes his head and body on Friday, goes early on foot without riding, sits close to the Imam, listens attentively and does not engage in idle talk, for every step he takes he will have the reward of a year's fasting and praying.",
    source: "أخرجه أبو داود (345) والترمذي (496) وصححه الألباني",
    grade: "صحيح"
  },
  {
    id: 83,
    chapter: "کاتژمێری وەڵامدانەوەی دوعا لە ڕۆژی هەینیدا",
    chapter_en: "Hour of Acceptance on Friday",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "إِنَّ فِي الْجُمُعَةِ لَسَاعَةً، لا يُوَافِقُهَا عَبْدٌ مُسْلِمٌ، وَهُوَ قَائِمٌ يُصَلِّي، يَسْأَلُ اللَّهَ شَيْئًا، إِلاَّ أَعْطَاهُ إِيَّاهُ، وَأَشَارَ بِيَدِهِ يُقَلِّلُهَا.",
    text_ku: "بەڕاستی لە ڕۆژی هەینیدا کاتژمێرێک هەیە، هیچ بەندەیەکی موسڵمان نییە لەو کاتەدا ڕێکبکەوێت و لە نوێژ و دوعادا داوای خێر لە خودا بکات ئیللا خوای گەورە پێی دەبەخشێت، و بە دەستی ئاماژەی بە کورتێتی ئەو کاتە کرد.",
    text_en: "There is an hour on Friday during which no Muslim servant asks Allah for anything good while standing in prayer, except that Allah gives it to him—and he pointed with his hand to indicate its shortness.",
    source: "متفق عليه: أخرجه البخاري (935)، ومسلم (852)",
    grade: "صحيح"
  },
  {
    id: 84,
    chapter: "فەزڵی خوێندنی سوورەتی کەهف لە ڕۆژی هەینیدا",
    chapter_en: "Surah Al-Kahf on Friday",
    narrator_ar: "عَنْ أَبِي سَعِيدٍ الْخُدْرِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ قَرَأَ سُورَةَ الْكَهْفِ فِي يَوْمِ الْجُمُعَةِ، أَضَاءَ لَهُ مِنَ النُّورِ مَا بَيْنَ الْجُمُعَتَيْنِ.",
    text_ku: "هەر کەسێک سوورەتی (الکهف) لە ڕۆژی هەینیدا بخوێنێت، خوای گەورە ڕووناکییەکی لە نێوان ئەو هەینییە بۆ هەینی داهاتوو بۆ ڕووناک دەکاتەوە.",
    text_en: "Whoever reads Surah Al-Kahf on the day of Friday, a light will shine for him between the two Fridays.",
    source: "أخرجه الحاكم والبيهقي وصححه الألباني في صحيح الجامع (6470)",
    grade: "صحيح"
  },
  {
    id: 85,
    chapter: "ڕێزگرتن لە هاوەڵان و حەرامێتی جنێودان پێیان",
    chapter_en: "Respecting the Prophet's Companions",
    narrator_ar: "عَنْ أَبِي سَعِيدٍ الْخُدْرِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "لا تَسُبُّوا أَصْحَابِي، فَوَالَّذِي نَفْسِي بِيَدِهِ لَوْ أَنَّ أَحَدَكُمْ أَنْفَقَ مِثْلَ أُحُدٍ ذَهَبًا، مَا أَدْرَكَ مُدَّ أَحَدِهِمْ وَلا نَصِيفَهُ.",
    text_ku: "جنێو و بێڕێزی بە هاوەڵانم مەکەن، سوێند بەو خودایەی گیانی منی بەدەستە ئەگەر یەکێکتان بە قەدەر کێوی ئوحود زێڕ ببەخشێت ناگاتە پاداشتی مستێک یان نیوە مستێکی بەخشینی ئەوان.",
    text_en: "Do not revile my companions! For by Him in Whose Hand is my soul, if one of you were to spend gold equal to Mount Uhud, it would not equal a handful of one of them or half of it.",
    source: "متفق عليه: أخرجه البخاري (3673)، ومسلم (2540)",
    grade: "صحيح"
  },
  {
    id: 86,
    chapter: "سیفەتەکانی دووڕووی تەواو",
    chapter_en: "Characteristics of a Pure Hypocrite",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ عَمْرٍو رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "أَرْبَعٌ مَنْ كُنَّ فِيهِ كَانَ مُنَافِقًا خَالِصًا، وَمَنْ كَانَتْ فِيهِ خَصْلَةٌ مِنْهُنَّ كَانَتْ فِيهِ خَصْلَةٌ مِنَ النِّفَاقِ حَتَّى يَدَعَهَا: إِذَا اؤْتُمِنَ خَانَ، وَإِذَا حَدَّثَ كَذَبَ، وَإِذَا عَاهَدَ غَدَرَ، وَإِذَا خَاصَمَ فَجَرَ.",
    text_ku: "چوار سیفەت هەن هەر کەسێک هەموویانی تێدابێت دووڕوویەکی تەواوە (مونافیق)، و هەر کەسێک خەسڵەتێکیانی تێدابێت خەسڵەتێکی دووڕوویی تێدایە تا ئەو کاتەی وازی لێ دەهێنێت: کاتێک ئەمانەتی پێ دەسپێردرێت خیانەت دەکات، و کاتێک قسە دەکات درۆ دەکات، و کاتێک پەیمان دەبەستێت دەیشکێنێت، و کاتێک دەمەقاڵێ دەکات لە سنوور دەردەچێت و زۆرداری دەکات.",
    text_en: "Whoever possesses four traits is a pure hypocrite, and whoever possesses one of them possesses a trait of hypocrisy until he leaves it: when he is trusted he betrays, when he speaks he lies, when he makes a covenant he breaks it, and when he disputes he acts unjustly.",
    source: "متفق عليه: أخرجه البخاري (34)، ومسلم (58)",
    grade: "صحيح"
  },
  {
    id: 87,
    chapter: "سێ نیشانەی سەرەکی دووڕوو",
    chapter_en: "Three Signs of a Hypocrite",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "آيَةُ الْمُنَافِقِ ثَلاثٌ: إِذَا حَدَّثَ كَذَبَ، وَإِذَا وَعَدَ أَخْلَفَ، وَإِذَا اؤْتُمِنَ خَانَ.",
    text_ku: "نیشانەی دووڕوو (مونافیق) سێ شتن: کاتێک قسە دەکات درۆ دەکات، و کاتێک بەڵێن دەدات پەیمانەکەی دەشکێنێت، و کاتێک ئەمانەتی پێ دەسپێردرێت خیانەت دەکات.",
    text_en: "The signs of a hypocrite are three: when he speaks he lies, when he makes a promise he breaks it, and when he is trusted he betrays.",
    source: "متفق عليه: أخرجه البخاري (33)، ومسلم (59)",
    grade: "صحيح"
  },
  {
    id: 88,
    chapter: "بەخیلی بردن تەنها لە دوو شتدا دروستە",
    chapter_en: "Permissible Envy Only in Two Matters",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ مَسْعُودٍ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "لا حَسَدَ إِلاَّ فِي اثْنَتَيْنِ: رَجُلٌ آتَاهُ اللَّهُ مَالاً فَسَلَّطَهُ عَلَى هَلَكَتِهِ فِي الْحَقِّ، وَرَجُلٌ آتَاهُ اللَّهُ الْحِكْمَةَ فَهُوَ يَقْضِي بِهَا وَيُعَلِّمُهَا.",
    text_ku: "بەخیلی و ئاواتخواستن بە پێگەی کەس دروست نییە تەنها لە دوو کەسدا نەبێت: کەسێک کە خودا سامانی پێ بەخشی بێت و بەسەر هەموویدا زاڵ بێت لە پێناوی حەق و خێردا بیبەخشێت، و کەسێک کە خودا دانایی و زانستی پێ بەخشی بێت بە پێی ئەو دادوەری بکات و خەڵکیشی فێر بکات.",
    text_en: "Envy is not permitted except in two cases: a man whom Allah has given wealth and directed him to spend it rightfully, and a man whom Allah has given wisdom and he judges by it and teaches it.",
    source: "متفق عليه: أخرجه البخاري (73)، ومسلم (816)",
    grade: "صحيح"
  },
  {
    id: 89,
    chapter: "مرۆڤ لەسەر ڕێبازی هاوڕێکەیەتی",
    chapter_en: "A Man Follows the Religion of His Friend",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "الرَّجُلُ عَلَى دِينِ خَلِيلِهِ، فَلْيَنْظُرْ أَحَدُكُمْ مَنْ يُخَالِلُ.",
    text_ku: "مرۆڤ لەسەر ئایین و ڕەوشتی هاوڕێ نزیکەکەیەتی، کەواتە با هەریەک لە ئێوە بە وردی سەرنج بدات بزانێت هاوڕێیەتی کێ دەکات.",
    text_en: "A man follows the religion of his close friend, so let each one of you look at whom he befriends.",
    source: "أخرجه أبو داود (4833) والترمذي (2378) وحسنه الألباني",
    grade: "صحيح"
  },
  {
    id: 90,
    chapter: "نموونەی هاوەڵی چاک و هاوەڵی خراپ",
    chapter_en: "Parable of Good & Bad Companions",
    narrator_ar: "عَنْ أَبِي مُوسَى الأَشْعَرِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَثَلُ الْجَلِيسِ الصَّالِحِ وَالْجَلِيسِ السَّوْءِ كَمَثَلِ حَامِلِ الْمِسْكِ وَنَافِخِ الْكِيرِ؛ فَحَامِلُ الْمِسْكِ إِمَّا أَنْ يُحْذِيَكَ، وَإِمَّا أَنْ تَبْتَاعَ مِنْهُ، وَإِمَّا أَنْ تَجِدَ مِنْهُ رِيحًا طَيِّبَةً، وَنَافِخُ الْكِيرِ إِمَّا أَنْ يُحْرِقَ ثِيَابَكَ، وَإِمَّا أَنْ تَجِدَ رِيحًا خَبِيثَةً.",
    text_ku: "نموونەی هاوەڵی چاکەکار و هاوەڵی بەدکار وەک نموونەی هەڵگری میسک (بۆنخۆشکەر) و فووکەری ئاگردانی ئاسنگەر وایە؛ هەڵگری میسک یان ئەوەتا دیاریت پێ دەدات، یان لێی دەکڕیت، یان بۆنێکی خۆشی لێوە دەبیستیت؛ بەڵام فووکەری ئاگردانەکە یان جلەکانت دەسووتێنێت، یاخود بۆنێکی ناخۆشی لێوە دەچێژیت.",
    text_en: "The likeness of a righteous companion and an evil companion is like that of a musk-seller and a blacksmith bellows-blower: the musk-seller either gives you some, or you buy some, or you smell good fragrance; whereas the blacksmith either burns your clothes or you smell foul odor.",
    source: "متفق عليه: أخرجه البخاري (5534)، ومسلم (2628)",
    grade: "صحيح"
  },
  {
    id: 91,
    chapter: "باشترینتان ڕەوشت جوانترینتانە",
    chapter_en: "The Best Among You Have the Best Morals",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ عَمْرٍو رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "إِنَّ مِنْ خِيَارِكُمْ أَحْسَنَكُمْ أَخْلاقًا.",
    text_ku: "بەڕاستی لە باشترین و چاکترینی ئێوە ئەوانەن کە لە هەمووان خاوەنی جوانترین و پاکترین ڕەوشتن.",
    text_en: "Indeed, the best among you are those who have the best character.",
    source: "متفق عليه: أخرجه البخاري (6035)، ومسلم (2321)",
    grade: "صحيح"
  },
  {
    id: 92,
    chapter: "قورسترین شت لە تەرازووی قیامەتدا",
    chapter_en: "The Heaviest Deed on the Scale",
    narrator_ar: "عَنْ أَبِي الدَّرْدَاءِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَا شَيْءٌ أَثْقَلُ فِي مِيزَانِ الْمُؤْمِنِ يَوْمَ الْقِيَامَةِ مِنْ خُلُقٍ حَسَنٍ، وَإِنَّ اللَّهَ لَيُبْغِضُ الْفَاحِشَ الْبَذِيءَ.",
    text_ku: "هیچ شتێک لە تەرازووی باوەڕداردا لە ڕۆژی قیامەتدا قورستر نییە لە ڕەوشتی جوان و پاک، و خوای گەورە ڕقی لە مرۆڤی دەم پیس و زمانپیسی بێشەرم دەبێتەوە.",
    text_en: "Nothing will be heavier on the scale of a believer on the Day of Resurrection than good character, and Allah hates the foul-mouthed and obscene person.",
    source: "أخرجه الترمذي (2002) وقال: حديث حسن صحيح",
    grade: "صحيح"
  },
  {
    id: 93,
    chapter: "سێ کۆشک لە پلەکانی بەهەشتدا",
    chapter_en: "Three Mansions in Paradise",
    narrator_ar: "عَنْ أَبِي أُمَامَةَ الْبَاهِلِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "أَنَا زَعِيمٌ بِبَيْتٍ فِي رَبَضِ الْجَنَّةِ لِمَنْ تَرَكَ الْمِرَاءَ وَإِنْ كَانَ مُحِقًّا، وَبِبَيْتٍ فِي وَسَطِ الْجَنَّةِ لِمَنْ تَرَكَ الْكَذِبَ وَإِنْ كَانَ مَازِحًا، وَبِبَيْتٍ فِي أَعْلَى الْجَنَّةِ لِمَنْ حَسُنَ خُلُقُهُ.",
    text_ku: "من دەستەبەری ماڵێکم لە دامێنی بەهەشتدا بۆ ئەو کەسەی واز لە دەمەقاڵێ و مشتومڕ بهێنێت هەرچەندە لەسەر حەقیش بێت، و ماڵێک لە ناوەڕاستی بەهەشتدا بۆ ئەو کەسەی واز لە درۆ بهێنێت هەرچەندە بە شۆخیش بێت، و ماڵێک لە بەرزترین پلەی بەهەشتدا بۆ ئەو کەسەی ڕەوشتی جوان بکات.",
    text_en: "I guarantee a house on the outskirts of Paradise for one who leaves off arguing even if he is right, and a house in the middle of Paradise for one who leaves off lying even when joking, and a house in the highest part of Paradise for one who makes his character good.",
    source: "أخرجه أبو داود (4800) وصححه النووي والألباني",
    grade: "صحيح"
  },
  {
    id: 94,
    chapter: "فەزڵی ڕۆژووی ڕۆژی عەرەفە و عاشوورا",
    chapter_en: "Virtue of Fasting Arafah & Ashura",
    narrator_ar: "عَنْ أَبِي قَتَادَةَ الأَنْصَارِيِّ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "صِيَامُ يَوْمِ عَرَفَةَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ السَّنَةَ الَّتِي قَبْلَهُ وَالسَّنَةَ الَّتِي بَعْدَهُ، وَصِيَامُ يَوْمِ عَاشُورَاءَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ السَّنَةَ الَّتِي قَبْلَهُ.",
    text_ku: "ڕۆژووی ڕۆژی عەرەفە ئومێدم بە خودا هەیە ببێتە کەفارەت و سڕینەوەی گوناهەکانی ساڵی پێشوو و ساڵی دوای خۆی، و ڕۆژووی ڕۆژی عاشووراش ئومێدم بە خودا هەیە ببێتە سڕینەوەی گوناهەکانی ساڵی پێشوو.",
    text_en: "Fasting on the Day of Arafah, I hope from Allah that it will expiate the sins of the year before it and the year after it; and fasting the Day of Ashura, I hope from Allah that it will expiate the sins of the year before it.",
    source: "أخرجه مسلم (1162)",
    grade: "صحيح"
  },
  {
    id: 95,
    chapter: "پاداشتی چاکەکردن لەگەڵ گیانداران",
    chapter_en: "Reward for Kindness to Every Living Creature",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "فِي كُلِّ كَبِدٍ رَطْبَةٍ أَجْرٌ.",
    text_ku: "لە چاکەکردن و ئاوپێدانی هەموو گیاندارێکی زیندوودا پاداشت و خێر هەیە بۆ مرۆڤ.",
    text_en: "There is a reward for serving any living being.",
    source: "متفق عليه: أخرجه البخاري (2363)، ومسلم (2244)",
    grade: "صحيح"
  },
  {
    id: 96,
    chapter: "مەترسی کوشتنی کەسانی بێتاوان و بەڵێندراو",
    chapter_en: "Sanctity of Human Life",
    narrator_ar: "عَنْ عَبْدِ اللَّهِ بْنِ عَمْرٍو رَضِيَ اللَّهُ عَنْهُمَا",
    text_ar: "مَنْ قَتَلَ مُعَاهَدًا لَمْ يَرِحْ رَائِحَةَ الْجَنَّةِ، وَإِنَّ رِيحَهَا تُوجَدُ مِنْ مَسِيرَةِ أَرْبَعِينَ عَامًا.",
    text_ku: "هەر کەسێک کەسێکی بێتاوان و پەیماندراو بکوژێت، بۆنی بەهەشت ناکات، هەرچەندە بۆنی بەهەشت لە مەودای چل ساڵ ڕێگاوە دەبیسترێت.",
    text_en: "Whoever kills a person who has a treaty with the Muslims will not smell the fragrance of Paradise, even though its fragrance can be smelled from a distance of forty years.",
    source: "أخرجه البخاري (3166)",
    grade: "صحيح"
  },
  {
    id: 97,
    chapter: "شەش مافی موسڵمان لەسەر برای موسڵمانی",
    chapter_en: "Six Rights of a Muslim Over Another",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "حَقُّ الْمُسْلِمِ عَلَى الْمُسْلِمِ سِتٌّ: إِذَا لَقِيتَهُ فَسَلِّمْ عَلَيْهِ، وَإِذَا دَعَاكَ فَأَجِبْهُ، وَإِذَا اسْتَنْصَحَكَ فَانْصَحْ لَهُ، وَإِذَا عَطَسَ فَحَمِدَ اللَّهَ فَشَمِّتْهُ، وَإِذَا مَرِضَ فَعُدْهُ، وَإِذَا مَاتَ فَاتَّبِعْهُ.",
    text_ku: "مافی موسڵمان لەسەر برای موسڵمانی شەش شتە: هەر کاتێک بینیت سەلامی لێ بکە، و هەر کاتێک داوەتی کردیت وەڵامی بدەرەوە، و هەر کاتێک داوای ئامۆژگاری لێ کردیت ئامۆژگاری دڵسۆزانەی بکە، و هەر کاتێک پژمی و سوپاسی خوای کرد (الحمد لله) دوعای بۆ بکە بە (یرحمك الله)، و هەر کاتێک نەخۆش کەوت سەردانی بکە، و هەر کاتێک کۆچی دوایی کرد بەشداری لە بەڕێکردنی تەرمەکەیدا بکە.",
    text_en: "The rights of a Muslim upon a Muslim are six: when you meet him, greet him with peace; when he invites you, respond to him; when he seeks your advice, advise him sincerely; when he sneezes and praises Allah, pray for mercy for him; when he falls ill, visit him; and when he dies, follow his funeral.",
    source: "أخرجه مسلم (2162)",
    grade: "صحيح"
  },
  {
    id: 98,
    chapter: "پاداشتی بەشداریکردن لە نوێژی مردوو و ناشتن",
    chapter_en: "Attending Funerals & Huge Reward",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ شَهِدَ الْجَنَازَةَ حَتَّى يُصَلَّى عَلَيْهَا فَلَهُ قِيرَاطٌ، وَمَنْ شَهِدَهَا حَتَّى تُدْفَنَ فَلَهُ قِيرَاطَانِ، قِيلَ: وَمَا الْقِيرَاطَانِ؟ قَالَ: «مِثْلُ الْجَبَلَيْنِ الْعَظِيمَيْنِ».",
    text_ku: "هەر کەسێک ئامادەی نوێژی مردوو بێت تا نوێژی لەسەر دەکرێت، قیڕاتێک پاداشتی بۆ هەیە، و هەر کەسێک ئامادە بێت تا بە تەواوی دەنێژرێت دوو قیڕات پاداشتی بۆ هەیە، وترا: دوو قیڕات چییە؟ فەرمووی: «وەک دوو کێوی گەورە لە خێر و پاداشت».",
    text_en: "Whoever attends a funeral until the prayer is offered will have one Qirat, and whoever attends until it is buried will have two Qirats. It was said: 'What are two Qirats?' He said: 'Like two immense mountains.'",
    source: "متفق عليه: أخرجه البخاري (1325)، ومسلم (945)",
    grade: "صحيح"
  },
  {
    id: 99,
    chapter: "سەلامکردن هۆکاری خۆشەویستی و چوونە بەهەشتە",
    chapter_en: "Greeting with Peace & Entering Paradise",
    narrator_ar: "عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "لا تَدْخُلُونَ الْجَنَّةَ حَتَّى تُؤْمِنُوا، وَلا تُؤْمِنُوا حَتَّى تَحَابُّوا، أَوَلا أَدُلُّكُمْ عَلَى شَيْءٍ إِذَا فَعَلْتُمُوهُ تَحَابَبْتُمْ؟ أَفْشُوا السَّلامَ بَيْنَكُمْ.",
    text_ku: "ناچنە بەهەشتەوە تاوەکو باوەڕ نەهێنن، و باوەڕتان تەواو نابێت تاوەکو یەکتریتان خۆشنەوێت، ئایا ڕێنموونیتان نەکەم بۆ کارێک کە ئەگەر ئەنجامی بدەن یەکتریتان خۆشدەوێت؟ سەلام لە نێوان خۆتاندا بڵاوبکەنەوە.",
    text_en: "You will not enter Paradise until you believe, and you will not believe until you love one another. Shall I not guide you to something which, if you do it, you will love one another? Spread peace among yourselves.",
    source: "أخرجه مسلم (54)",
    grade: "صحيح"
  },
  {
    id: 100,
    chapter: "شایەتیدانی ئیمان و سەرەنجامی بەهەشت",
    chapter_en: "Testifying to Faith & Entering Paradise",
    narrator_ar: "عَنْ عُبَادَةَ بْنِ الصَّامِتِ رَضِيَ اللَّهُ عَنْهُ",
    text_ar: "مَنْ شَهِدَ أَنْ لا إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لا شَرِيكَ لَهُ، وَأَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ، وَأَنَّ عِيسَى عَبْدُ اللَّهِ وَرَسُولُهُ، وَكَلِمَتُهُ أَلْقَاهَا إِلَى مَرْيَمَ وَرُوحٌ مِنْهُ، وَالْجَنَّةَ حَقٌّ، وَالنَّارَ حَقٌّ، أَدْخَلَهُ اللَّهُ الْجَنَّةَ عَلَى مَا كَانَ مِنَ الْعَمَلِ.",
    text_ku: "هەر کەسێک شایەتی بدات بەوەی کە هیچ پەرستراوێک نییە شایەنی پەرستن بێت جگە لە خوای تاکی بێ هاوەڵ، و محەممەد بەندە و پێغەمبەری ئەوە، و عیسا بەندەی خوا و پێغەمبەری ئەوە و ئەو وشەیەیە کە خستیە ناو مەریەمەوە و ڕۆحێکە لە لایەن ئەوەوە، و بەهەشت حەقە، و دۆزەخ حەقە، خوای گەورە دەیخاتە بەهەشتەوە لەسەر هەر کردەوەیەک کە هەیبووە.",
    text_en: "Whoever testifies that there is no god worthy of worship except Allah alone with no partner, and that Muhammad is His servant and Messenger, and that Jesus is the servant of Allah and His Messenger, and His word bestowed upon Mary and a spirit from Him, and that Paradise is true and Hell is true, Allah will admit him to Paradise regardless of his deeds.",
    source: "متفق عليه: أخرجه البخاري (3435)، ومسلم (28)",
    grade: "صحيح"
  }
];

const all100 = [...first50, ...next50];

// Save JSON dataset
fs.writeFileSync('Sahih_Hadiths_100.json', JSON.stringify(all100, null, 2), 'utf8');
console.log('Saved Sahih_Hadiths_100.json with 100 authentic hadiths.');

// Generate HTML with high quality styles for 100 Hadiths
const generateHtml = () => {
  return `<!DOCTYPE html>
<html lang="ku" dir="rtl">
<head>
<meta charset="UTF-8">
<title>١٠٠ فەرموودەی صەحیحی پێغەمبەری خودا (ﷺ) | 100 Authentic Sahih Hadiths</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Noto+Naskh+Arabic:wght@400;600;700&family=Inter:wght@400;500;600;700&display=swap');

  @page {
    size: A4 portrait;
    margin: 1.2cm 1.2cm 1.5cm 1.2cm;
    @bottom-right {
      content: counter(page);
    }
  }

  * {
    box-sizing: border-box;
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  body {
    font-family: 'Noto Naskh Arabic', 'Amiri', 'Segoe UI', Tahoma, sans-serif;
    background-color: #f8fafc;
    color: #0f172a;
    margin: 0;
    padding: 24px;
    line-height: 1.7;
  }

  .cover-header {
    background: linear-gradient(135deg, #064e3b 0%, #047857 50%, #065f46 100%);
    color: #ffffff;
    border-radius: 16px;
    padding: 36px 24px;
    text-align: center;
    margin-bottom: 28px;
    box-shadow: 0 10px 25px -5px rgba(6, 78, 59, 0.3);
    border: 2px solid #d97706;
  }

  .bismillah {
    font-family: 'Amiri', serif;
    font-size: 28px;
    color: #fef08a;
    margin-bottom: 12px;
    letter-spacing: 1px;
  }

  .main-title {
    font-size: 32px;
    font-weight: 700;
    margin: 0 0 10px 0;
    color: #ffffff;
  }

  .subtitle {
    font-size: 16.5px;
    color: #d1fae5;
    margin-bottom: 16px;
    font-weight: 500;
  }

  .meta-badges {
    display: flex;
    justify-content: center;
    gap: 12px;
    flex-wrap: wrap;
  }

  .meta-badge {
    background: rgba(255, 255, 255, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.3);
    padding: 5px 14px;
    border-radius: 9999px;
    font-size: 13px;
    color: #fef9c3;
  }

  .stats-summary {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 18px 24px;
    margin-bottom: 24px;
    display: flex;
    justify-content: space-around;
    text-align: center;
    box-shadow: 0 2px 4px rgba(0,0,0,0.04);
  }

  .stat-item .num {
    font-size: 26px;
    font-weight: 700;
    color: #047857;
  }

  .stat-item .label {
    font-size: 13.5px;
    color: #64748b;
  }

  .hadith-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 14px;
    padding: 22px 24px;
    margin-bottom: 22px;
    page-break-inside: avoid;
    break-inside: avoid;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
    border-right: 5px solid #059669;
    position: relative;
  }

  .hadith-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
    border-bottom: 1px dashed #e2e8f0;
    padding-bottom: 10px;
  }

  .hadith-id-chapter {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .hadith-num {
    background: #047857;
    color: #ffffff;
    font-weight: 700;
    font-size: 13.5px;
    width: 34px;
    height: 34px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
  }

  .chapter-pill {
    background: #ecfdf5;
    color: #065f46;
    font-weight: 600;
    font-size: 13.5px;
    padding: 4px 12px;
    border-radius: 6px;
    border: 1px solid #a7f3d0;
  }

  .grade-badge {
    background: #fef3c7;
    color: #92400e;
    font-weight: 700;
    font-size: 12.5px;
    padding: 4px 12px;
    border-radius: 20px;
    border: 1px solid #fde68a;
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }

  .narrator {
    color: #475569;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 8px;
  }

  .arabic-text {
    font-family: 'Amiri', 'Traditional Arabic', serif;
    font-size: 21.5px;
    font-weight: 700;
    color: #064e3b;
    line-height: 2.1;
    text-align: justify;
    background: #f0fdf4;
    padding: 14px 18px;
    border-radius: 10px;
    margin-bottom: 12px;
    border-right: 4px solid #10b981;
  }

  .kurdish-section {
    margin-bottom: 10px;
  }

  .section-label {
    font-size: 12px;
    font-weight: 700;
    color: #059669;
    text-transform: uppercase;
    margin-bottom: 2px;
  }

  .kurdish-text {
    font-size: 15.5px;
    color: #1e293b;
    line-height: 1.8;
    text-align: justify;
  }

  .english-section {
    direction: ltr;
    text-align: left;
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid #f1f5f9;
  }

  .english-label {
    font-family: 'Inter', sans-serif;
    font-size: 11px;
    font-weight: 700;
    color: #64748b;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .english-text {
    font-family: 'Inter', -apple-system, sans-serif;
    font-size: 13.5px;
    color: #334155;
    line-height: 1.6;
    margin-top: 2px;
  }

  .hadith-footer {
    margin-top: 12px;
    padding-top: 8px;
    border-top: 1px dashed #e2e8f0;
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: #64748b;
  }

  .source-tag {
    font-weight: 600;
    color: #047857;
  }

  .footer-note {
    text-align: center;
    color: #64748b;
    font-size: 13px;
    margin-top: 35px;
    padding: 18px;
    border-top: 1px solid #cbd5e1;
  }

  @media print {
    body {
      background-color: #ffffff;
      padding: 0;
    }
    .hadith-card {
      box-shadow: none;
      border: 1px solid #cbd5e1;
      margin-bottom: 18px;
    }
  }
</style>
</head>
<body>

<div class="cover-header">
  <div class="bismillah">بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ</div>
  <h1 class="main-title">کۆکراوەی ١٠٠ فەرموودەی سەحیحی پێغەمبەری خودا ﷺ</h1>
  <div class="subtitle">دەقی عەرەبی کامل بە تەشکیل + وەرگێڕانی وردی کوردی و ئینگلیزی + سەرچاوە و تەخریجی سەحیح</div>
  <div class="meta-badges">
    <span class="meta-badge">✓ هەمووی ١٠٠٪ صەحیح (البخاري و مسلم و السنن الصحاح)</span>
    <span class="meta-badge">✓ بەبێ هیچ زیادکردن و بڕینێک</span>
    <span class="meta-badge">✓ گونجاو بۆ بەشی فەرموودەی Nada Zikr</span>
    <span class="meta-badge">✓ پێداچوونەوەی وردی شەرعی و زمانەوانی</span>
  </div>
</div>

<div class="stats-summary">
  <div class="stat-item">
    <div class="num">١٠٠</div>
    <div class="label">فەرموودەی پیرۆز</div>
  </div>
  <div class="stat-item">
    <div class="num">١٠٠٪</div>
    <div class="label">دەقی سەحیح و دانپێدانراو</div>
  </div>
  <div class="stat-item">
    <div class="num">٣٨+</div>
    <div class="label">بابی گرنگ لە دین و ژیان</div>
  </div>
  <div class="stat-item">
    <div class="num">٣ زمان</div>
    <div class="label">عەرەبی، کوردی، ئینگلیزی</div>
  </div>
</div>

<div class="hadiths-container">
  ${all100.map(h => `
  <div class="hadith-card" id="hadith-${h.id}">
    <div class="hadith-top">
      <div class="hadith-id-chapter">
        <div class="hadith-num">${h.id}</div>
        <div class="chapter-pill">${h.chapter} • ${h.chapter_en}</div>
      </div>
      <div class="grade-badge">
        <span>★ پلە: ${h.grade}</span>
      </div>
    </div>

    <div class="narrator">${h.narrator_ar}</div>

    <div class="arabic-text">${h.text_ar}</div>

    <div class="kurdish-section">
      <div class="section-label">وەرگێڕان و مانای کوردی:</div>
      <div class="kurdish-text">${h.text_ku}</div>
    </div>

    <div class="english-section">
      <div class="english-label">English Translation:</div>
      <div class="english-text">${h.text_en}</div>
    </div>

    <div class="hadith-footer">
      <div class="source-tag">سەرچاوە و تەخریج: ${h.source}</div>
      <div>Nada Zikr Hadith Database</div>
    </div>
  </div>
  `).join('')}
</div>

<div class="footer-note">
  کۆکراوەی ١٠٠ فەرموودەی صەحیحی پێغەمبەری خودا ﷺ — بەرهەمهێنراوە بۆ نەرمەکاڵای «نەدا - زیکر و قورئان» (Nada Zikr)
</div>

</body>
</html>`;
};

const htmlContent = generateHtml();
fs.writeFileSync('Sahih_Hadiths_100.html', htmlContent, 'utf8');
console.log('Saved Sahih_Hadiths_100.html');
