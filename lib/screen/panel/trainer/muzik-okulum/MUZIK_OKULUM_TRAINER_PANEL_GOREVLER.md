# Müzik Okulu — Eğitmen Panel Görev Listesi

## Mimari Özet

- **Dizin:** `lib/screen/panel/trainer/muzik-okulum/`
- **ApplicationType:** `muzik_okulum` → `appType.isMusicSchool`
- **Referans (web):** `system.fitiz.net` — öğretmen listesi/kartı (`Employee`); **bu mobil kapsamda finans yok** (Fitiz’deki *Hakediş* / `earning-report` mobilde yer almayacak).
- **Referans (mobil):** `lib/screen/panel/trainer/swimming-course/` — ana sayfa, `today-summary`, ders programı, yoklama, `TrainerHomeScreen` / `TrainerProfileScreen` dallanması.
- **Pagination:** `.cursor/rules/pagination-convention.mdc` (liste ekranlarında infinite scroll).
- **Kurallar:** `AppLabels`, `BlocTheme`, API modelleri (`lib/data/model/`), magic string yok.

---

## A — Ürün İlkesi: Öğretmen kartı ≠ finans

- [ ] Öğretmen kartı ve tüm alt ekranlarda **hakediş, kazanç, cari, ücret** vb. **gösterilmez** ve ilgili API çağrıları **yapılmaz**.
- [ ] Fitiz web `employee/card` içindeki **Yoklama / Dersler / İstatistik** ile hizalı kalınır; **Hakediş** sekmesi mobilde **yok**.

---

## B — Kabuk ve Sekmeler

- [ ] `TrainerHomeScreen` — `appType.isMusicSchool` ise `MuzikOkulumTrainerHomeScreen` (yüzme ile aynı kalıp).
- [ ] `TrainerProfileScreen` — `appType.isMusicSchool` ise `MuzikOkulumTrainerProfileScreen` (veya ortak profil + muzik menü filtresi; yüzme `SwimmingCourseTrainerProfileScreen` ile paralel karar).
- [ ] `tabs_screen.dart` — eğitmen için sekme yapısı değişmiyorsa dokunma; değişecekse dokümante et.

---

## C — Öğretmen kartı içeriği → Hızlı erişim (ana sayfa)

Fitiz `employee/card` sol/sağ panel mantığı mobilde **tek kart sayfasına tıklanmadan**: ana sayfada **`QuickAccessSectionWidget`** ile her blok ayrı giriş.

| Hızlı erişim başlığı (ör.) | Açılacak hedef | Fitiz karşılığı (referans) | Not |
|----------------------------|----------------|----------------------------|-----|
| **Bu haftanın ders özeti** | `MuzikOkulumTrainerWeeklyStatsScreen` veya diyalog | Üst widget’lar: normal / telafi / toplam | Randevu `employees/{id}/stats` veya `lessons` türevi — **finans içermez** |
| **Verdiğim dersler** | `MuzikOkulumTrainerLessonsListScreen` | `EmployeeLessonsCard` | Tarih aralığı + liste; müzikte sütun: **Sınıf** (`tableClassroom` anlamı) |
| **Yoklama raporum** | `MuzikOkulumTrainerAttendanceReportScreen` | `EmployeeAttendanceTab` | `start` / `end` filtreli rapor — sadece yoklama metrikleri |
| **Ders programı** | Mevcut haftalık takvim rotası | Schedule + `employee_id` benzeri filtre | Ortak `TrainerLessonScheduleScreen` ile aynı API ailesi (`service-plans/calendar`) |
| *(Opsiyonel)* **Yardım / kullanım kodu** | Policy uygunsa tek ekran | Fitiz `use-code` | JWT/employee **use-code** mobilde var mı — backend onayı |

- [ ] Ana sayfa üst üçlü (Bugünkü derslerim / Yoklamalar / Özet) — yüzme eğitmen ile aynı veri kaynağı: `GET v2/me/today-summary` (`RandevuAlTrainerUrlConstants.getTodaySummaryUrl`).
- [ ] Slider + duyuru — yüzme/member muzik ile DRY mümkünse ortak davranış.

---

## D — Dosya / Ekran İskeleti (öneri)

```
lib/screen/panel/trainer/muzik-okulum/
  muzik_okulum_trainer_home_screen.dart
  muzik_okulum_trainer_profile_screen.dart          // veya profile alt menü sadece muzik
  lessons/
    muzik_okulum_trainer_lessons_list_screen.dart
  attendance/
    muzik_okulum_trainer_attendance_report_screen.dart
  stats/
    muzik_okulum_trainer_weekly_stats_screen.dart
  MUZIK_OKULUM_TRAINER_PANEL_GOREVLER.md             // bu dosya
```

- [ ] Her ekran: `BlocTheme`, `AppLabels`; liste modelleri `fromJson`.
- [ ] **Finans** ekranı / servisi **eklenmeyecek**.

---

## E — API ve Modeller

- [ ] Eğitmen `employee_id`: JWT profilinden (`getTrainerProfileUrl`) veya mevcut `UserConfig` — tek kaynak netleştirilir.
- [ ] Haftalık özet / ders listesi: Randevu `mobile/employees/{id}/lessons` (`RandevuAlTrainerUrlConstants.getMobileEmployeeLessonsUrl`) — yanıt şekli için mevcut `trainer_schedule` / yüzme servisleri ile hizala.
- [ ] Yoklama raporu: web `GET /apps/employees/{id}/attendance-report` ile eşdeğer **mobil/trainer** uç var mı doğrulanır; yoksa backend görevi açılır (`v2/me/...` veya `mobile/employees/.../attendance-report`).
- [ ] `today-summary`: mevcut `TrainerTodayDashboardModel` yeniden kullanım.

---

## F — Localization (`AppLabels`)

- [ ] Müzik okulu eğitmenine özel başlıklar: profil özeti, bu haftanın özeti, verdiğim dersler, yoklama raporu (TR/EN, `MusicSchoolLabels` / `MusicSchoolLabelsEn` veya mevcut hiyerarşi).
- [ ] Sınıf vs lokasyon: üye panelindeki “derslik” terminolojisi ile tutarlılık.

---

## G — Test / Kabul

- [ ] `muzik_okulum` + trainer hesabı: ana sayfa hızlı erişim → her rota açılıyor, **finans alanı yok**.
- [ ] Web Fitiz ile karşılaştırmalı: ders listesi ve yoklama akışı alan adları uyumlu (mümkün olduğunca).

---

## H — Bilinçli olarak yapılmayacaklar

- Fitiz `EmployeeEarningsTab`, `earning-report`, maaş / hakediş içeriği.
- Üye panelindeki cari, planlı ödeme, paket ücretleri eğitmen hızlı erişiminde **yok**.

---

## I — İleride (bu dosyada sadece hatırlatma)

- Diğer öğretmenleri listeleme (admin benzeri) — ayrı ürün; bu görev **oturum açan eğitmenin kendi kartı** odaklıdır.
- Öğretmen kadrosu **üye** tarafında zaten var; eğitmen tarafında sadece **kendi** kartı önceliklidir.

### Yoklama satırı — paket seçimi (planlanan)

İlerleyen zamanda **kalan adet sıfır** veya paket **pasif** olduğunda, üye/paket bağlamına göre **aktif paketler** API üzerinden getirilecek ve kullanıcıya **selectbox** ile seçtirilecek. Şu anki davranışta bu durumlarda resepsiyona aktif paket atanması için metin gösteriliyor; çoklu seçenek endpoint’i (`package-options` veya paket bazlı aktif liste) hazır olduğunda UI tarafında mevcut `PATCH member_register_id` / Kaydet akışı ile tamamlanacak.

**İlgili kod:** `lib/screen/panel/trainer/muzik-okulum/muzik_okulum_trainer_lesson_roster_attendance_screen.dart`, `TrainerEnrollmentPackageService`.
