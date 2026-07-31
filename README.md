# FocusOS Lite

Minimal, modern bir odaklanma ve zaman yonetimi Android uygulamasi.
Kotlin + Jetpack Compose + Material 3 + MVVM ile, Android Studio gerekmeden,
tamamen VS Code + terminal uzerinden gelistirilip build alinabilecek sekilde
hazirlanmistir.

## Bu surumde neler var

- Mor AppBar kaldirildi; sol ustte logo + "FocusOS" yazan sade bir ust bar,
  buyuk odak suresi karti ve gunluk hedef ilerleme cubugu ile modern bir
  Ana Sayfa.
- Animasyonlu, capsule gostergeli alt menu: Home / Timer / Alarm / Stats.
- Pomodoro kaldirildi; yerine saat/dakika/saniye olarak sure secilebilen,
  saliseleri gosteren, dairesel animasyonlu, Pause/Resume/Reset destekli,
  arka planda ve kilit ekraninda calismaya devam eden bir odak zamanlayicisi
  geldi (Foreground Service + bildirim).
- Yeniden tasarlanmis tam ekran alarm calma ekrani.
- Gunluk / Haftalik / Aylik grafikli Istatistik ekrani: calisma suresi,
  tamamlanan gorev, streak (art arda gun), en verimli gun. Premium'a
  yonlendirme yok.
- Yeni Ayarlar ekrani: Tema (Light/Dark/AMOLED/System + Dynamic Color), Dil
  (Turkce/English, calisma zamaninda degisir), bildirim/titresim/ses acma-
  kapama, yazi boyutu (Kucuk/Orta/Buyuk).
- Ilk acilista tam ekran Premium tanitimi (sol ustte X ile kapatilir),
  sonra Ana Sayfa'daki Premium butonundan tekrar acilabilir.
- "Gorev" yerine her yerde "To-Do List" ifadesi kullanilir; kartlar modern,
  checkbox animasyonlu, swipe-to-delete destekli ve duzenlenebilir.
- Sayfa gecislerinde fade/scale/slide (Material Motion) animasyonlari.
- Turkce karakterler (g-breve, s-cedilla, c-cedilla, dotless-i, o-umlaut,
  u-umlaut) UTF8 (BOM'suz) olarak yazilir, her yerde dogru gorunur.

## Mimari

```
UI (Compose Screens)  --observes-->  ViewModel (StateFlow)  --calls-->  Repository  -->  Room / DataStore
        ^                                  |
        +---------------- AppViewModelFactory (manuel DI, di/AppContainer) ----------------+
```

- **MVVM**: her ekranin kendi `ViewModel`'i var (`HomeViewModel`, `TimerViewModel`,
  `AlarmViewModel`, `StatsViewModel`, `SettingsViewModel`, `PremiumViewModel`).
  ViewModel'ler yalnizca repository'lerle konusur, UI hicbir zaman dogrudan
  Room/DataStore'a dokunmaz.
- **Manuel DI**: Hilt/Dagger kullanilmadi (VS Code + Gradle CLI build'ini basit
  tutmak icin). `di/AppContainer.kt` tum repository/manager'lari tek yerde kurar,
  `di/AppViewModelFactory.kt` bunlari ViewModel'lere enjekte eder.
- **Room**: `TaskEntity`, `SessionEntity`, `AlarmEntity` ve ilgili DAO'lar
  `data/local/`.
- **DataStore**: Premium durumu, tema/dil/bildirim/titresim/ses/yazi boyutu
  tercihleri, gunluk hedef, son secilen zamanlayici suresi
  `data/preferences/UserPreferencesRepository.kt`.
- **WorkManager**: `worker/DailyResetWorker.kt`, gunde bir kez calisan
  periyodik bakim isi.
- **Foreground Service**: `service/TimerService.kt` - odak zamanlayicisi,
  uygulama arka plana alinsa bile bildirim uzerinden calismaya devam eder ve
  tamamlanan oturumlari Room'a kaydeder.
- **AlarmManager**: `alarm/AlarmScheduler.kt` + `alarm/AlarmReceiver.kt` +
  `alarm/AlarmRingActivity.kt` (kilit ekrani uzerinde tam ekran alarm ekrani)
  + `alarm/BootReceiver.kt` (cihaz yeniden baslayinca alarmlari tekrar kurar).
- **Navigation Compose**: `navigation/NavGraph.kt`, animasyonlu gecisler ve
  `ui/components/BottomNavBar.kt` ile capsule gostergeli alt gezinme cubugu.
- **Dil**: `AppCompatDelegate.setApplicationLocales` ile calisma zamaninda dil
  degisimi (androidx.appcompat), secim DataStore'da da tutulur.
- **Tema**: `ui/theme/Theme.kt` - Light/Dark/AMOLED/System + Android 12+
  Dynamic Color (Material You) destegi, yazi boyutu carpanina gore olceklenen
  Typography.

## Reklam ve Premium kurallari (uygulanmis haliyle)

- `ui/components/AdBanner.kt` icindeki `BottomAdBanner()` yalnizca
  `TimerScreen` ve `AlarmScreen` icinde, `bottomBar` slotunda ve sadece
  `isPremium == false` iken gosterilir.
- Ana ekranda (`HomeScreen`) ve gorevlerde reklam yoktur.
- Tam ekran reklam (interstitial) kullanilmamistir, yalnizca banner.
- Premium satin alindiginda (`BillingManager` -> `UserPreferencesRepository.setPremium(true)`)
  tum reklamlar aninda kaybolur, cunku `isPremium` bir `Flow` olarak UI'a
  baglidir.
- Uygulama ilk acildiginda tam ekran Premium tanitimi acilir (sol ustte X ile
  kapatilabilir); bir kez kapatildiktan sonra bir daha otomatik acilmaz, Ana
  Sayfa'daki Premium butonundan istendiginde tekrar acilabilir.

## Gercek AdMob / Play Billing kimlikleri

Proje su an Google'in resmi test kimlikleriyle gelir (yayina almadan once
degistirin):

| Ne | Dosya | Test degeri | Yapilacak |
|---|---|---|---|
| AdMob App ID | `AndroidManifest.xml` | `ca-app-pub-3940256099942544~3347511713` | AdMob konsolundan gercek App ID |
| Banner Ad Unit ID | `ads/AdManager.kt` | `ca-app-pub-3940256099942544/6300978111` | AdMob konsolundan gercek Banner Unit ID |
| Premium urun ID | `billing/BillingManager.kt` -> `PREMIUM_LIFETIME_SKU` | `focusos_premium_lifetime` | Play Console -> Monetize -> In-app products'ta bu ID ile bir "tek seferlik" urun olusturun |

## Gereksinimler (Windows / VS Code)

- JDK 17 (`java -version` ile kontrol edin)
- Android SDK command-line tools (Android Studio kurmadan da SDK'yi tek basina
  kurabilirsiniz: https://developer.android.com/studio#command-tools).
  `ANDROID_HOME` / `ANDROID_SDK_ROOT` ortam degiskeninin ayarli olmasi yeterli.
- Internet baglantisi (Gradle wrapper'i ve bagimliliklari indirmek icin).
- VS Code + "Kotlin" ve "Gradle for Java" uzantilari (opsiyonel ama onerilir).

## Kurulum (tek komut)

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

Bu script:
1. `FocusOSLite/` klasorunu ve tum alt klasorleri olusturur.
2. Gradle (Kotlin DSL), AndroidManifest, tum kaynak (res) ve Kotlin dosyalarini
   yazar.
3. Sistemde `gradle` yoksa Gradle 8.7'yi gecici olarak indirip `gradle wrapper`
   komutunu calistirarak `gradlew.bat`, `gradlew`, `gradle-wrapper.jar`
   dosyalarini dogru ve resmi kaynaktan uretir.
4. `local.properties` dosyasini `ANDROID_HOME`/`ANDROID_SDK_ROOT`'tan otomatik
   olusturur.
5. `gradlew.bat :app:assembleDebug` ile bir build kontrolu calistirir ve
   sonucu ekrana yazar.

Script tekrar calistirilabilir (idempotent); mevcut dosyalarin uzerine
guvenle yazar.

## Build / calistirma komutlari

```powershell
cd FocusOSLite

# Debug APK
.\gradlew.bat :app:assembleDebug

# Release APK (imzalama bilgisi olmadan da derlenir, imzasiz cikar)
.\gradlew.bat :app:assembleRelease

# Bagli cihaza/emulatore kurup calistirmak icin
.\gradlew.bat :app:installDebug

# Lint kontrolu
.\gradlew.bat :app:lintDebug
```

## Play Store'a hazirlik icin son adimlar

1. `app/build.gradle.kts` icindeki `signingConfigs.release` blogunu kendi
   keystore bilgilerinizle `-PRELEASE_STORE_FILE=... -PRELEASE_STORE_PASSWORD=...
   -PRELEASE_KEY_ALIAS=... -PRELEASE_KEY_PASSWORD=...` parametreleriyle (veya
   `gradle.properties` icine ekleyerek) doldurun, ardindan:
   ```powershell
   .\gradlew.bat :app:bundleRelease
   ```
   ile `app/build/outputs/bundle/release/app-release.aab` dosyasini uretip
   Play Console'a yukleyin.
2. Yukaridaki tabloda belirtilen gercek AdMob ve Play Billing kimliklerini
   girin.
3. Play Console'da `focusos_premium_lifetime` urununu (veya sectiginiz ID'yi)
   "tek seferlik urun" olarak olusturun ve fiyatlandirin.