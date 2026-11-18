# Codex qəbul kontraktı

Bu sənəd [icra planındakı](EXECUTION.md) mərhələlər üçün yoxlanıla bilən nəticələri bağlayır. GitHub Actions-da sənəd yoxlaması məhsul testindən ayrıdır. Məhsul testi üçün nəticə yalnız işlək giriş nöqtəsi ilə sübut olunmalıdır.

## A · Oyun və Chrome

| ID | Ssenari | Qəbul meyarı |
|---|---|---|
| A01 | 360×800, sonra 430×932. Hər tray mövqeyindən sürüklə. | Barmağın üstündə fiqur görünür. Dörd künc və aşağı orta xana əlçatandır. Təsdiqlənən xana son görünən etibarlı hədəflə eynidir. |
| A02 | Lövhə kənarı, dolu xana, ikinci toxunuş, sistem ləğvi. | Heç bir qanunsuz gediş yazılmır. İkinci pointer sürükləməni mənimsəmir. Xal, tray, RNG və gediş sayı sabit qalır. |
| A03 | Kəsişən sıra və sütun. 3-cü kombo. Silinmə zamanı yeni fiquru götür. | +37 xal, 15 unikal xana, 2 xətt, kombo 3. Yeni gedişdə hədəf effektin üstündə görünür və bütün təmizlənən xanalar artıq boşdur. |
| A04 | Son slotu oyna, tətbiqi öldür, yenidən aç. | Cihazda yalnız tam köhnə və ya tam yeni tranzaksiya görünə bilər. Yarım tray, yarım xal və fərqli generator vəziyyəti qəbuledilməzdir. |
| A05 | [Son fiqur və geri alma vektoru](../contracts/classic-lifecycle-v1.json). | Son slotdan sonra tray yenilənir, terminal yaranır. Alternativ mövqe raundu davam etdirir. Mükafatla əvvəlki tray, lövhə, 99 xal, 3 kombo və RNG 21 birlikdə bərpa edilir. |
| A06 | Birinci gediş, təkrar açılış, RTL və azaldılmış hərəkət. | Intro təkrarlanmır. Ərəb dilində tray həndəsəsi sabit qalır. Hərəkətsiz rejim eyni oyun nəticəsini verir. |

Chrome nümunəsi təkrar oynadıla bilən development fixture ilə A03 və A05 başlanğıc vəziyyətlərini açmalıdır. Normal sürükləmə və normal nəticə ekranı istifadə olunur. Test nəticəsi kimi birbaşa state dəyişmək olmaz. Hər görünən slice üçün commit, əmr, hər viewport üzrə faktiki hərəkət, müşahidə, preview URL və ya görüntü yazılır. Android jestləri və həyat dövrü ayrıca real cihaz nəticəsidir.

## B–D · Yarış və inteqrasiya

| ID | Ssenari | Gözlənilən nəticə |
|---|---|---|
| S01 | Eyni hesab/lövhə üçün eyni açarla iki paralel start | Hər iki cavab eyni attempt ID-ni qaytarır. Yalnız bir slot istifadə olunur. |
| S02 | Eyni hesab/lövhə üçün üç müxtəlif açarla paralel start | İki fərqli ID yaradılır. Üçüncü sorğu 409 attempt_cap qaytarır. |
| S03 | Bağlanışdan əvvəl tam replay alınıb, emal gecikib | UTC server receipt vaxtı cutoff-dan əvvəldirsə qəbul. Tam sərhəddə yeni replay 410 board_expired. |
| S04 | Təsdiqlənmiş replay-i cutoff-dan sonra yenidən göndər | Eyni replay eyni nəticəni qaytarır. Başqa replay 409 conflicting_replay. Hər iki halda ikinci xal yazılmır. |
| S05 | Eyni xal iki səhifəyə bölünüb, sonra lövhə ləğv edilib | İlk snapshot-da eyni rank. Ləğvdən sonra köhnə cursor etibarsızdır, yeni sıralama həmin lövhənin töhfəsini çıxarır. |
| S06 | Reklam bağlanır, earned sonra gəlir, sonra iki dəfə təkrarlanır | Bir dəfə bərpa, bir dəfə reward marker. Təsdiqlənməmiş reklam xalı və rekordu dəyişmir. |
| S07 | Mükafatlı reklam göstərilmir və ya istifadəçi razılığı ləğv edir | Yeni reklam sorğusu dayanır, Klassik əlçatan qalır. Earned olmadan geri alma yoxdur. |
| S08 | Hesab bərpası, nickname dəyişməsi və hesab silmə | Profil ID-si bərpada və nickname dəyişəndə sabitdir. Silinmə tokenləri və ictimai nəticələri çıxarır. |

## Reklam hadisələrinin dəqiq ardıcıllığı

Show başlamazdan əvvəl request ID və terminal raundun dəyişməz snapshot-u saxlanır. Reklam overlay açıq olduqda Eyni reklam/Yenidən oyna hərəkətləri deaktivdir. Dismiss gəlibsə və earned hələ yoxdursa, nəticə ekranı ən çox 2 saniyə settlement göstərə bilər. Bu müddət UI qərarıdır. Mükafat SDK callback-inin etibarlılıq həddi kimi istifadə edilmir.

Earned həmin raundun nəticəsi açıqkən gəlirsə, bərpa bir tranzaksiyada tətbiq olunur. Oyunçu artıq yeni raunda keçibsə, callback cari lövhəni dəyişmir. Köhnə raund üçün bərpa edilə bilən entitlement ayrıca saxlanır və növbəti Klassik menyuda “İkinci şans hazırdır” kimi göstərilir. Seçim cari raundu əvəz edəcəksə, oyunçu əvvəlcədən bunu görüb təsdiqləyir. Eyni run üçün ikinci entitlement yazılmır. No-fill və show error nəticə ekranını dərhal açır. Tətbiq dayandıqdan sonra saxlanmış earned grant bərpa edilir. SDK təsdiqi heç alınmayıbsa, grant təxmin olunmur.

Reklamla geri alınan nəticə terminal şəxsi rekord kimi qalmamalıdır. Rekord əvvəlki təsdiqlənmiş raundların maksimumudur. Terminal nəticə yeni raunda keçəndə saxlanır. Gecikmiş earned həmin terminalı geri alanda xidmət etdiyi run ID üzrə nəticə yenidən hesablanır. Cari raundun xalı və generatoru toxunulmaz qalır. Rekord şənliyi həmin run üçün təkrarlanmır.

## Buraxılış sübutu

Hər mərhələdə uyğun ID-ləri yoxla və konkret nəticəni göstər. Əgər emulator, Chrome və ya fiziki Android mövcud deyilsə, dəqiq maneəni və sınağın statusunu yaz. Açıq qəbul maddəsini keçilmiş kimi göstərmək olmaz. İstehsal reklamı, hadisə telemetriyası və hüquqi səhifələrin yayımı üçün [buraxılış şərtləri](RELEASE.md) tətbiq olunur.
