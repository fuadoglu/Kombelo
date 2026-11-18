<p align="center">
  <img src="docs/media/brand.svg" alt="Kombelo oyununun nişanı" width="108" height="108">
</p>

<h1 align="center">Kombelo</h1>

<p align="center"><strong>Blokları yerləşdir. Kombo qur. Rekordunu keç.</strong></p>

Kombelo portret ekranda bir baş barmaqla oynanan blok pazlıdır. Oyunçu üç fiquru 8×8 lövhəyə yerləşdirir, tam dolan sıra və sütunları silir, ardıcıl təmizləmələrlə kombo qurur. **Klassik** rejimdə şəxsi rekordunu artırır. **Liqa** rejimində hər gün eyni lövhəni oynayan dostlarla və digər oyunçularla yarışır.

İlk buraxılış **Android** üçündür. **iOS** ayrıca cihaz və mağaza yoxlamalarından sonra gəlir. **Chrome** inkişaf zamanı lokal oyunu nümayiş etdirmək, toxunma axınını və interfeys dəyişikliklərini yoxlamaq üçündür.

> **Cari vəziyyət:** Flutter-də oynana bilən Klassik lövhə, deterministik Dart oyun nüvəsi və SQLite raund yaddaşı var. Brauzer və Android paketləmə yoxlamaları davam edir. Liqa, hesab, inteqrasiyalar, doqquz dil və buraxılış hələ hazırlanmayıb.

| | Oyunçu təcrübəsi | Məhsul qərarı |
|---|---|---|
| <img src="docs/media/game.svg" width="22" alt=""> | **Bir əllə Klassik** | Hesabsız və internetsiz oyun. Təsdiqlənmiş son gedişdən davam. |
| <img src="docs/media/trophy.svg" width="22" alt=""> | **Gündəlik Liqa** | Ortaq lövhə, iki cəhd, Dostlar, Ölkə və Dünya cədvəlləri. |
| <img src="docs/media/sound.svg" width="22" alt=""> | **Kombo və rekord reaksiyası** | Şirli bloklar, işıq dalğası, yüksələn kombo notları və qısa rekord melodiyası. |
| <img src="docs/media/world.svg" width="22" alt=""> | **Doqquz dil** | Cihazın dil üstünlükləri, ölkə üzrə ehtiyat seçim və əl ilə dəyişmə. |
| <img src="docs/media/bell.svg" width="22" alt=""> | **Qayıdış səbəbləri** | Yeni gündəlik lövhə, real dost dəvəti və dəyişən liqa nəticəsi. |
| <img src="docs/media/shield.svg" width="22" alt=""> | **Profil və monetizasiya** | Avtomatik ID, istifadəçinin seçdiyi nickname və uyğun Klassik sessiyalarında AdMob. |

## 1. Oyun necə işləyir?

1. **Fiquru götür.** Aşağıdakı üç fiqurdan istədiyini seç. Fiqur baş barmağın üstündə görünür və lövhədə yerləşəcəyi xanalar işarələnir.
2. **Göstərilən mövqeyə burax.** Yerləşmə etibarlıdırsa, fiqur həmin xanalara oturur. Etibarsız və ya sistem tərəfindən kəsilən sürükləmə lövhəni, xalı və fiqur dəstini olduğu kimi saxlayır.
3. **Xətləri təmizlə.** Tam dolan sıralar və sütunlar eyni gedişdə silinir. Kəsişən xana bir dəfə silinir, iki tamamlanmış xətt isə ayrıca hesablanır.
4. **Kombonu böyüt.** Ardıcıl xətt silən gedişlər kombo seriyasını artırır. Bir neçə xətti eyni anda silmək ayrıca bonus verir və seriyanı bir pillə qaldırır. Xəttsız yerləşdirmə seriyanı sıfırlayır.
5. **Növbəti dəstə keç.** Üç fiqur istifadə ediləndə yeni dəst gəlir. Qalan fiqurların heç biri yerləşmirsə, Klassik raund bitir. Liqa həm də gediş həddində başa çatır.

### Xal və oyun qaydaları

| Xal komponenti | V1 kontraktı |
|---|---|
| Yerləşdirmə | Hər yerləşdirilən xanaya 1 xal |
| Xətt | Hər tamamlanan sıra və ya sütuna 10 xal |
| Çoxxətli təmizləmə | `5 × n × (n − 1)`, burada `n` həmin gedişdə silinən xəttlərin sayıdır |
| Ardıcıl təmizləmə | Xətt silən gedişdə `3 × min(9, kombo − 1)` |

Məsələn, birxanalı fiqur iki xətti tamamlayır və kombonu üçüncü pilləyə qaldırırsa, **37 xal** verir. Bu vektor sənəd yoxlayıcısında da yoxlanır. Ekrandakı kombo rəqəmi seriyanın uzunluğunu göstərir. Rənglər vizualdır. Eyni gedişlər eyni qayda versiyası altında mobil tətbiqdə və serverdə eyni nəticəni verməlidir.

- [Oyun protokolu](docs/GAME_PROTOCOL.md)
- [Fiqur kataloqu, çəkilər və xal sabitləri](contracts/game-v1.json)
- [Girişlər və gözlənilən nəticələr](contracts/game-v1-vectors.json)

## 2. Klassik, Liqa və oyunçu profili

| | Klassik | Liqa |
|---|---|---|
| **Məqsəd** | Şəxsi rekordu artırmaq | Eyni gündəlik lövhədə digər oyunçularla yarışmaq |
| **Başlanğıc** | Yerli raund və qayda versiyasına bağlı fiqur generatoru | Hamı üçün eyni başlanğıc lövhəsi və fiqur ardıcıllığı |
| **Gedişlər** | Qanuni yerləşmə qaldıqca davam edir | Qanuni yerləşmə və elan olunmuş gediş həddi daxilində |
| **İnternet** | Oyun, rekord və davam yerli işləyir | Cəhd serverdə açılır. Bağlantı kəsilsə, başlamış cəhd yerli davam edir və vaxtında göndərilir. |
| **Nəticə** | Şəxsi rekord cihazda saxlanır | Server gedişləri yenidən hesablayır və ən yaxşı təsdiqlənmiş gündəlik nəticəni qəbul edir. |
| **Reklam** | Uyğun hallarda raundlararası reklam və könüllü ikinci şans | Reytinqli cəhd reklamsızdır və gedişi geri alma imkanı vermir. |

**Bir nəticə, üç cədvəl.** Dostlar şəxsi rəqabəti, Ölkə seçilən təmsilçiliyi, Dünya isə ümumi sıralamanı göstərir. Hər lövhədə iki reytinqli cəhddən yüksək nəticə götürülür. Həftəlik xal ən yaxşı dörd gündəlik nəticənin cəmidir. Bərabər xallar eyni yeri tutur və oyun sürəti sıralamaya təsir etmir. Bağlanış UTC ilə idarə olunur və oyunçuya öz yerli vaxtında göstərilir.

**Profil avtomatik yaranır.** Klassik üçün yerli ID ilk açılışda yaranır. İlk liqa girişində profil server hesabına bağlanır və unikal ictimai oyunçu kodu alır. Oyunçu sərbəst nickname seçə və dəyişə bilər. Eyni nickname bir neçə oyunçuda ola bilər, dost axtarışında ictimai kod dəqiq şəxsi ayırır. E-poçtla hesab bərpası seçimlidir. Profil şikayəti, bloklama və hesab silmə uyğun ekranlardan idarə olunur.

Server təsdiqi gedişin qanuniliyini və xalı yoxlayır. Ortaq lövhənin həllinin oyunçular arasında paylaşılması liqa dizaynında qalan ədalət riskidir. [Server davranışı və qəbul ssenariləri](docs/SERVICE_BEHAVIOR.md)

## 3. İnterfeys, onboarding və səs

| Mövzu | İcra qərarı |
|---|---|
| **İlk açılış** | Sistem splash ekranı yüklənməni örtür. Kombelo nişanı yumşaq, qısa keçidlə göstərilir. Oynana bilən lövhədə ilk fiqur və yerləşmə nümunəsi işarələnir. |
| **Geri qayıdış** | Açıq Klassik raund varsa, oyunçu saxlanmış vəziyyətdən davam edir. Təlimat yalnız lazım olan anda görünür. |
| **Görünüş** | Tünd indiqo lövhə. Firuzəyi, sarı, moruq, mərcan və yasəmən rəngli şirli bloklar. Boş xanalar və etibarlı önizləmə parlaqlıq altında seçilir. |
| **Birbarmaqla idarəetmə** | Geniş toxunma sahələri, bütün jest boyunca sabit fiqur qaldırması, sərhəddə kiçik titrəyişə dözümlülük. Dörd künc və aşağı sıra sağ və sol əllə yoxlanır. |
| **Animasiya** | Fiqur yüngül sıxılma ilə oturur. Xətt boyunca işıq yayılır və bloklar xanalara doğru sönür. Görüntü effekti davam edərkən növbəti fiquru götürmək mümkündür. |
| **Səs** | Yumşaq keramika toxunuşu, yüksələn kombo notları və rekord üçün qısa melodiya. Bir gedişə bir əsas səs siqnalı seçilir. |
| **Əlçatanlıq** | Sürükləməyə alternativ toxunaraq yerləşdirmə, semantik etiketlər, böyük mətn, azaldılmış hərəkət və ayrı səs, musiqi, vibrasiya ayarları. |

**Dil seçimi** cihazın sıralanmış dil seçimlərini izləyir. Uyğun dil tapılmasa, yalnız aydın uyğunluğu olan cihaz regionu nəzərə alınır, sonra ingilis dilinə keçilir. Oyundakı əl ilə seçim üstün tutulur. Ölkə liqası ayrıca seçimdir və cihaz regionu ilkin təklif kimi istifadə olunur. GPS tələb edilmir.

Dillər **AZ, EN, TR, RU, ES, pt-BR, DE, FR və AR**. Ərəb dilində menyu sağdan sola işləyir, fiqur və lövhə koordinatları bütün dillərdə eynidir. Funksional ikonlar üçün lisenziyası yoxlanılmış Lucide seçimi, səslər üçün təsdiqlənmiş açıq lisenziyalı mənbələr və orijinal Kombelo melodiyası nəzərdə tutulur. [UI sistemi](docs/UI_SYSTEM.md) · [Aktivlərin mənbə və lisenziya reyestri](docs/ASSET_MANIFEST.md)

### Təsdiqlənmiş interaktiv UI atlası

[Kombelo UI atlasını](docs/Kombelo_UI_Atlasi.html) yükləyib brauzerdə aç. Atlas 28 ekran və vəziyyəti rəngli UI və Wireframe rejimlərində göstərir. Klassik lövhədə firuzəyi təkxanalı fiquru işarələnmiş xanaya qoyaraq iki xəttin silinməsini və `3 kombo · +37 xal` reaksiyasını görmək olur. Pauza menyusundan Liqa, Profil və Ayarlar açılır.

Atlas brauzerdə yerli işləyən dizayn referansıdır. Liqa, reklam və hesab axınları nümunə məlumatlarla göstərilir. Flutter tətbiqində oyun hesablaması üçün [oyun protokolu](docs/GAME_PROTOCOL.md), vizual icra üçün [UI sistemi](docs/UI_SYSTEM.md) və [qəbul ssenariləri](docs/ACCEPTANCE.md) əsas götürülür.

## 4. AdMob, Firebase və oyunçu seçimləri

**AdMob yeganə gəlir mənbəyidir.** Uyğun Klassik sessiyalarında raundlar arasında seyrək tam ekran reklam göstərilir. Raund bitəndə həqiqətən davam etməyə imkan verən alternativ gediş varsa, oyunçu bir dəfə **«Reklama bax və son gedişi geri al»** seçə bilər. Mükafat yalnız SDK təsdiqi ilə tətbiq edilir. Oyun əvvəlki xal, kombo, fiqur dəsti və generator vəziyyətini birlikdə bərpa edir. Reklam hazır olmayanda yeni raunda keçid davam edir.

- **Firebase Analytics** ilk raund, təkrar oyun, kombo, rekord, liqa göndərişi və reklam nəticəsi kimi məhdud hadisələri ölçür. Nickname, e-poçt, dost kodu və gediş tarixçəsi analitika hadisələrinə daxil edilmir.
- **Crashlytics** uyğun sessiyalarda texniki nasazlıq diaqnostikası üçün nəzərdə tutulur. Oyunçu məlumatları nasazlıq qeydlərindən çıxarılır.
- **Firebase Cloud Messaging** oyunçunun seçimi əsasında gündəlik lövhə və real dost hadisələrini göndərir. İlkin limit yerli gün ərzində bir təşviq bildirişidir. Sakit saatlar, bildirişin vaxtı keçdikdə davranış və birbaşa açılan ekran müəyyən edilib.
- **Yaş və razılıq** reklam, analitika və ictimai funksiyaları idarə edir. Yaşı məlum olmayan və məhdud sessiyalarda Klassik əlçatandır. İstehsal SDK-ları auditoriya, razılıq və mağaza tələbləri yoxlandıqdan sonra aktivləşdirilir.
- **Hüquqi səhifələr** məxfilik, istifadə şərtləri, hesab və məlumatların silinməsi, dəstək, icma qaydaları və üçüncü tərəf bildirişlərini əhatə edir. Sənəddəki layihələr yayımdan əvvəl real naşir, əlaqə məlumatları, vendorlar və məlumat saxlama müddətləri ilə tamamlanır.

[Monetizasiya və məxfilik](docs/TRUST_AND_GROWTH.md) · [İnteqrasiya matrisi və analitika hadisələri](docs/INTEGRATION_MATRIX.md) · [Hüquqi mətn layihələri](docs/LEGAL_DRAFTS.md)

## 5. Texniki arxitektura

| Qat | Seçim | Məsuliyyət |
|---|---|---|
| **Mobil tətbiq** | Flutter | İlk mərhələdə Android, daha sonra iOS. Ekranlar, ayarlar, lokalizasiya və platforma inteqrasiyaları. |
| **Lövhə və effektlər** | `CustomPainter` | Lövhə, sürüklənən fiqur, önizləmə və effektlərin ayrı çəkilməsi. |
| **Ortaq qaydalar** | Saf Dart | Yerləşdirmə, generator, xətt təmizləmə, xal və gediş təkrarının deterministik hesablanması. |
| **Cihaz yaddaşı** | SQLite | Aktiv raund, son gedişdən əvvəlki vəziyyət, fiqur dəsti, xal və kombo. |
| **Onlayn xidmət** | Dart API və PostgreSQL | Profil, dostlar, cəhdlər, serverdə xal yoxlaması, sıralama və bildiriş növbəsi. |
| **Əməliyyatlar** | Versiyalı konfiqurasiya, planlaşdırılmış işlər və auditli əmrlər | Gündəlik lövhələrin açılması, həftəlik nəticələrin hesablanması, qüsurlu lövhənin ləğvi və reklamın dayandırılması. Admin paneli nəzərdə tutulmur. |

`apps/mobile` və `packages/game_rules` hazırkı ilkin mərhələnin tətbiq/nüvə sərhədləridir. `services/api` sonrakı mərhələdə OpenAPI və SQL sxeminə əsasən əlavə olunacaq. [Texniki spesifikasiya](docs/ENGINEERING.md) · [OpenAPI](contracts/openapi.json) · [PostgreSQL sxemi](contracts/schema.sql)

## 6. Lokal yoxlama və Chrome nümayişi

İş mühitini hazırlamaq və mövcud yoxlamaları işə salmaq üçün repo kökündən:

```sh
./scripts/bootstrap.sh
./scripts/verify.sh
```

Flutter 3.50.0 / Dart 3.14.0 dəqiq SDK hədəfidir. Bootstrap versiyalı game rules faylını Flutter asset-ə sinxronlaşdırır, Dart workspace-i bərpa edir və Chrome üçün SQLite WASM/worker fayllarını yaradır. Verify statik analizi, oyun qaydası vektorlarını, UI və SQLite testlərini, sənəd checker-lərini işlədir.

Chrome preview:

```sh
cd apps/mobile
flutter run -d chrome --web-hostname=127.0.0.1 --web-port=8080
```

`?fixture=intersection` development URL-si acceptance A03 üçün iki xəttin kəsişmə vəziyyətini açır. Android APK build-ni cihaz yoxlamasından əvvəl hazırlamaq olar; Chrome testi native həyat dövrü və jest yoxlamasını əvəz etmir.

Yalnız mövcud sənədləri yoxlamaq üçün:

```sh
python3 scripts/check_contracts.py
python3 scripts/check_lifecycle.py
```

**Hər görünən mərhələ üçün Codex** dəyişən axını Chrome-da işlədir, **360×800** və **430×932** ölçülərində yoxlayır və canlı önizləmə linki və ya ekran görüntüsü təqdim edir. RTL və azaldılmış hərəkət dəyişikliklə əlaqəlidirsə yoxlamaya daxil edilir. Yoxlama qeydi əmri, ekran ölçüsünü, ssenarini, müşahidə edilən nəticəni və qalan məhdudiyyəti göstərir.

**Android cihazı ayrıca sübut tələb edir.** Sistem jestləri, kəsilən toxunuş, tətbiqin bağlanıb açılması, səs və vibrasiya, reklam mükafatı və bildirişlər cihazda yoxlanır. Chrome-da imitasiya edilən inteqrasiyalar açıq işarələnir.

## 7. Codex üçün icra ardıcıllığı

| Mərhələ | Görünən nəticə | Əsas qəbul ssenarisi |
|---|---|---|
| **A · Oyun nüvəsi** | Chrome-da oynana bilən Klassik lövhə | Fiquru dəqiq yerləşdir, eyni gedişdə sıra və sütun sil, effekt gedərkən növbəti fiquru götür. |
| **B · UI və lokalizasiya** | Brend, intro, onboarding, səs və doqquz dil | İlk və təkrar açılışı, ərəb dilini, böyük mətni, səssiz rejimi və azaldılmış hərəkəti göstər. |
| **C · Onlayn oyun** | Profil, nickname, dostlar və üç liqa cədvəli | İki cəhdi yoxla, eyni nəticəni təkrar göndər, gecikmiş cəhdi göstər və hesabı sil. |
| **D · İnteqrasiyalar** | AdMob, Firebase, bildirişlər və hüquqi səhifələr | Test reklamı ilə bir mükafat ver, təkrar callback-i yoxla, razılığı geri götür və vaxtı keçmiş keçidi aç. |
| **E · Android buraxılışı** | İmzalanmış daxili sınaq versiyası | Fiziki cihaz matrisi, mağaza bəyanları, lisenziya inventarı və geri qaytarma sınağı. |
| **F · iOS buraxılışı** | iOS sınaq və mağaza namizədi | Platforma imzası, məxfilik bəyanları, SDK-lar və real iOS cihazı üzrə ayrıca yoxlama. |

[AGENTS.md](AGENTS.md) Codex-in məcburi iş qaydalarını müəyyən edir. Agent cari mərhələyə aid sənədləri oxuyur, əlaqəsiz dəyişikliklərdən qaçır və qısa, sübutlu iş qeydi təqdim edir. Sənədlər arasında ziddiyyət çıxarsa, normativ kontrakt və onun test vektoru eyni dəyişiklikdə dəqiqləşdirilir. [Qəbul ssenariləri](docs/ACCEPTANCE.md) · [İcra və sübut formatı](docs/EXECUTION.md) · [Buraxılış və istismar meyarları](docs/RELEASE.md)

## Sənədlərin xəritəsi

| | Sənəd | Əhatə dairəsi |
|---|---|---|
| <img src="docs/media/game.svg" width="20" alt=""> | [Məhsul spesifikasiyası](docs/PRODUCT.md) | Qaydalar, ekran axınları, onboarding və idarəetmə |
| <img src="docs/media/code.svg" width="20" alt=""> | [Oyun protokolu](docs/GAME_PROTOCOL.md) | Deterministik generator, xal, gediş sırası və geri alma |
| <img src="docs/media/sound.svg" width="20" alt=""> | [UI və səs sistemi](docs/UI_SYSTEM.md) | Ekran ölçüləri, palitra, animasiya, səs və əlçatanlıq |
| <img src="docs/media/world.svg" width="20" alt=""> | [Server davranışı](docs/SERVICE_BEHAVIOR.md) | Cəhdlər, bağlanış, sıralama, profil və moderasiya |
| <img src="docs/media/shield.svg" width="20" alt=""> | [Məxfilik və gəlir](docs/TRUST_AND_GROWTH.md) | AdMob, Firebase, uşaqlar üçün qaydalar və lisenziyalar |
| <img src="docs/media/docs.svg" width="20" alt=""> | [Buraxılış planı](docs/RELEASE.md) | QA, Android cihaz sınağı, əməliyyatlar və iOS keçidi |

Kombelo-nun əsas keyfiyyət meyarı budur: oyunçu fiquru bir əllə istədiyi xanaya yerləşdirir, kombonun nə üçün yarandığını anlayır və növbəti gedişi gözləmədən oynayır.
