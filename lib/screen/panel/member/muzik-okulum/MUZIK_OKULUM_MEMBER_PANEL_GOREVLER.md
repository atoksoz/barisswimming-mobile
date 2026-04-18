# Müzik Okulu — Member Panel Görev Listesi

## Mimari Özet

- **Dizin:** `lib/screen/panel/member/muzik-okulum/`
- **ApplicationType:** `muzik_okulum` → `appType.isMusicSchool`
- **Sekmeler:** Anasayfa | QR Kod | Profil (3 tab)
- **Pagination Kuralı:** `.cursor/rules/pagination-convention.mdc` (infinite scroll)
- **Dashboard API birleştirme (yapılacak):** aşağıdaki **A.7** maddeleri

---

## A — Anasayfa

- [x] `muzik_okulum_home_screen.dart` oluştur
- [x] Header: Hoş Geldiniz + kullanıcı adı (Unicode decode `jsonDecode`)
- [x] Header stil: `textSubtitle` + `textTitle` (trainer paneldeki gibi)
- [x] Profil avatarı: Fotoğraf varsa `ClipOval` + popup, yoksa SVG user icon
- [x] Duyuru ikonu: `AnnouncementIconWidget` (ortak widget)
- [x] Slider: `CarouselSlider` — mevcut yapı korundu
- [x] Üst 3 buton:
  - [x] Bugünkü Derslerim → `Icons.calendar_month_outlined` — rozet: bugünkü ders sayısı (haftalık şablon + telafi, `MemberTodaySummaryService` ile popup ile aynı kaynak)
  - [x] Bugünkü Ödemelerim → `Icons.payments` — rozet: ödenen/toplam veya tek sayı (`MemberTodayPaymentPlanStatsService` / özet listesi ile uyumlu)
  - [x] Bugünün Özeti → `Icons.dashboard_customize_outlined` — rozet: özet popup satır adedi; `MemberTodaySummaryPopup` + `SummaryPopupWidget`
- [x] Hızlı Erişim (8 buton) — `QuickAccessSectionWidget` (ortak widget):
  - [x] Paket Bilgileri → `Icons.shopping_basket_rounded`
  - [x] Yoklamalar → `Icons.fact_check_outlined`
  - [x] Cari Ekstre → `Icons.receipt_long_outlined`
  - [x] Ders Programı → `Icons.event_note_outlined`
  - [x] Öneri Şikayet → `theme.suggestionSvgPath` (iconColor: `default900Color`)
  - [x] Veli Bilgisi → `Icons.family_restroom_outlined`
  - [x] Planlı Ödeme → `Icons.payments_outlined`
  - [x] Eğitmen Kadrosu → `Icons.school_outlined`

## A.1 — Tabs Entegrasyonu

- [x] `tabs_screen.dart` — `_buildMusicSchoolMember*` metodları
- [x] `appType.isMusicSchool` kontrolü ile dinamik yükleme

## A.2 — Ortak Widget'lar (DRY)

- [x] `AnnouncementIconWidget` (`lib/core/widgets/announcement_icon_widget.dart`)
  - Trainer, Explore ve MuzikOkulum'da kullanılıyor
- [x] `QuickAccessSectionWidget` (`lib/core/widgets/quick_access_section_widget.dart`)
  - Trainer, Explore ve MuzikOkulum'da kullanılıyor

## A.3 — Profil Menüsü

- [x] `muzik_okulum_profile_menu_screen.dart` — ayrı dosya
- [x] Kaldırılan menü öğeleri: Ödeme geçmişi, Geçiş bilgileri, Ders kuralları, Hızlı randevu kuralları, Tesis kuralları
- [x] Kalan: Profilim, Tesis detayları, Öğretmen kadrosu, Öneri şikayet, Üyelik kuralları, KVKK, Hakkımızda

## A.4 — Localization

- [x] `AppLabels` abstract getters eklendi (TR + EN)
  - `todayMyLessons`, `todayMyPayments`, `myActivePackages`
  - `packageInfo`, `myAttendance`, `financialStatement`, `lessonSchedule`
  - `guardianInfo`, `scheduledPayments`

## A.5 — Pagination Kuralı

- [x] `.cursor/rules/pagination-convention.mdc` — Cursor rule oluşturuldu

## A.6 — Bugünün özeti, cari satır rozetleri, telafi (tamamlandı)

- [x] `lib/core/services/member_today_summary_service.dart` — bugünkü işlemler: `my-schedule` (bugünün günü) + yoklama `is_makeup` birleşimi, planlı ödeme, cari satış/tahsilat, yoklama satırları; güvenli sıralama + try/catch
- [x] `lib/screen/panel/member/muzik-okulum/member_today_summary_popup.dart` — popup satırları: **Planlı Ödeme**, **Satış** / **Tahsilat** (ayrı rozet), **Derslerim**, yoklama; telafi vurgusu; alt açıklama metni kaldırıldı
- [x] `lib/core/widgets/summary_popup_widget.dart` — opsiyonel `subtitle`; cari satış+tahsilat ardışık satırlarda ayırıcı gizleme (`omitDividerBetween`)
- [x] `AppLabels` — `summaryRowBadgeStatementSale`, `summaryRowBadgeStatementCollection`, `summaryRowBadgeMyLessons` (TR/EN)
- [x] Anasayfa `_loadPanelSummary` — tek `loadTodayOperationItems` ile üç rozet; `addPostFrameCallback` + `UserConfigCubit` ile yenileme; hata durumunda rozet sıfırlama
- [x] `lesson_schedule_screen.dart` — paralel `attendance-report` ile bugünkü **telafi** kartlara eklenir; kart üstü **Derslerim** etiketi (`summaryRowBadgeMyLessons`)

## A.7 — Member dashboard API birleştirme + istemci cache (yapılacak)

**Amaç:** Member anasayfa yüklendiğinde ve tab geçişlerinde oluşan **tekrarlayan çoklu API çağrılarını** azaltmak:
1. Her backend tabanında **tek toplu endpoint** (`home-dashboard`)
2. İstemcide **60 saniyelik local cache** (tab geçişlerinde aynı isteklerin tekrarlanmasını engelle)

---

### A.7.0 — Mevcut Durum Analizi

#### Anasayfa yüklendiğinde atılan istekler (toplam ~12+ HTTP request)

| # | Endpoint | Backend | Tetikleyen Servis | Sorun |
|---|----------|---------|-------------------|-------|
| 1 | `GET v2/me/announcements/latest` | api-system | `AnnouncementCubit` | — |
| 2 | `GET v2/me/mobile-application-settings` | api-system | `MobileAppSettingsService` | — |
| 3 | `GET v2/me/panel-summary` | api-system | `MemberHomeDashboardService` | **Birleştirme adayı** |
| 4 | `GET v2/me/packages?page=1,2,…` | api-system | `MemberHomeDashboardService._aggregateActivePackageRights` | **N sayfa taranıyor**, birleştirme adayı |
| 5a | `GET v2/me/payment-plans?page=…` | api-system | `MemberTodayPaymentPlanStatsService.fetchTodayPlanItems` (today summary) | **Aynı endpoint 3 kez** |
| 5b | `GET v2/me/payment-plans?page=…` | api-system | `MemberHomeDashboardService._countOverduePayments` (insights) | ↑ tekrar |
| 5c | `GET v2/me/payment-plans?page=…` | api-system | `MemberHomeRemindersService.fetchPaymentReminders` | ↑ tekrar |
| 6a | `GET v2/me/statements` | api-system | `MemberTodaySummaryService.loadTodayOperationItems` | **Aynı endpoint 2 kez** |
| 6b | `GET v2/me/statements` | api-system | `MemberHomeStatementChartCard._load` | ↑ tekrar |
| 7a | `GET v2/me/attendance-report?itemsPerPage=50` | api-system | `MemberTodaySummaryService` | **Aynı endpoint 2 kez** (farklı sayfa boyutu) |
| 7b | `GET v2/me/attendance-report?itemsPerPage=20` | api-system | `MemberHomeDashboardService._fetchRecentAttendance` | ↑ tekrar |
| 8a | `GET v2/me/my-schedule` | randevu | `MemberTodaySummaryService._fetchTodayScheduleLessons` | **Aynı endpoint 2 kez** |
| 8b | `GET v2/me/my-schedule` | randevu | `MemberHomeDashboardService._scheduleInsights` | ↑ tekrar |

#### Tab geçişi sorunu

`TabsScreen` → `widgetOptions.elementAt(_selectedIndex)` — `IndexedStack` kullanılmıyor. Home'dan başka tab'a geçince widget **dispose** olur, geri dönünce **initState** tekrar çalışır → **tüm istekler yeniden atılır**.

#### Özet

- **api-system'e** anasayfa init'inde ~**8–10+ istek** (paginated olanlar ek sayfa yapıyor)
- **randevu'ya** ~**2 istek** (aynı endpoint tekrar)
- **Tab her geçişinde** tümü baştan atılıyor

---

### A.7.1 — api-system: `GET v2/me/muzik-okulum/home-dashboard` (yeni birleşik endpoint)

**Route:** `routes/api_v2_member.php` → `GET v2/me/muzik-okulum/home-dashboard`
**Middleware:** `api.check-auth` (mevcut member self-service standardı)
**Controller:** `MemberSelfServiceV2Controller::muzikOkulumHomeDashboard`
**App-type guard:** Controller'da `TenantHelper::getApplicationType() === 'muzik_okulum'` kontrolü (ileride gym/swimming ayrı route + metot olarak eklenir)

Mevcut **6 ayrı endpoint'in** yaptığını **tek yanıt** olarak döndürür:

```
- [x] A.7.1.a — Route + Controller metodu: `muzikOkulumHomeDashboard` + `ApplicationTypeEnum::MUZIK_OKULUM` guard
- [x] A.7.1.b — panel_summary bloğu: `getMemberPanelSummary` (aktif paket sayısı + bugünkü ödeme)
- [x] A.7.1.c — packages bloğu: `buildPackagesSummary` — aktif paketler + Σ quantity/remain + near_expiry_count
- [x] A.7.1.d — payment_plans bloğu: `buildPaymentPlansDashboard` — overdue/today/reminder tek sorguda
- [x] A.7.1.e — statements bloğu: `buildStatementsDashboard` — son 50 satır + aylık borç/alacak (6 ay)
- [x] A.7.1.f — attendance bloğu: `fetchAttendanceForDashboard` — randevu proxy (son 50 yoklama)
```

**Örnek yanıt şekli:**

```json
{
  "output": {
    "panel_summary": {
      "active_package_count": 3,
      "today_payment_count": 1
    },
    "packages": {
      "active_items": [ { "id": 1, "name": "...", "quantity": 20, "remain_quantity": 14, "start_date": "...", "end_date": "..." } ],
      "total_quantity": 60,
      "total_remaining": 42,
      "near_expiry_count": 1
    },
    "payment_plans": {
      "overdue_count": 2,
      "overdue_items": [ { "id": 5, "amount": 500, "payment_date": "2026-03-15", ... } ],
      "today_items": [ { "id": 8, "amount": 300, "payment_date": "2026-04-10", ... } ],
      "reminder_items": [ { "id": 9, "amount": 200, "payment_date": "2026-04-18", ... } ]
    },
    "statements": {
      "recent_items": [ { "date": "...", "description": "...", "debit": 0, "credit": 500, ... } ],
      "monthly_summary": [
        { "year": 2026, "month": 4, "total_debit": 1500, "total_credit": 800 },
        { "year": 2026, "month": 3, "total_debit": 1200, "total_credit": 1200 }
      ]
    },
    "attendance": {
      "recent_items": [ { "id": 1, "lesson_name": "...", "date": "...", "status": "...", "is_makeup": false } ]
    }
  }
}
```

---

### A.7.2 — randevu: `GET v2/me/muzik-okulum/home-dashboard` (yeni birleşik endpoint)

**Route:** `routes/api_v2_member.php` → `GET v2/me/muzik-okulum/home-dashboard`
**Middleware:** `cors`, `api.check-auth`
**Controller:** `MemberScheduleController::muzikOkulumHomeDashboard` (randevu projesinde)

Mevcut **2 tekrarlayan istek** tek yanıta iner:

```
- [x] A.7.2.a — Route + Controller: `MuzikOkulumHomeDashboardController` (__invoke) + `ApplicationTypeEnum::MuzikOkulum` guard
- [x] A.7.2.b — schedule bloğu: `MuzikOkulumScheduleDashboardService.buildSchedule` → `MemberScheduleResource`
- [x] A.7.2.c — today_lesson_count bloğu: `ResarvationRepository::getTodayLessonCountByMember`
```

**Örnek yanıt şekli:**

```json
{
  "output": {
    "schedule": [
      { "day_number": 1, "start_time": "09:00", "end_time": "09:50", "service_plan_name": "Piyano", "employee_name": "Ahmet Hoca" }
    ],
    "today_lesson_count": 2
  }
}
```

---

### A.7.3 — Mobil: 60 saniyelik istemci cache

**Amaç:** Tab geçişlerinde ve widget yeniden oluşturmalarında aynı isteklerin tekrarını engellemek.

```
- [x] A.7.3.a — `MuzikOkulumHomeCacheUtils` — in-memory cache (60 sn TTL)
         - `lib/core/utils/shared-preferences/muzik_okulum_home_cache_utils.dart`
         - Generic `get<T>`, `set<T>`, `invalidate`, `invalidateAll` API
         - Serializasyon gereksiz — ham Dart nesneleri bellekte tutulur
- [x] A.7.3.b — Dashboard servislerinde cache entegrasyonu
         - `_loadHomeDashboard` → cache kontrol → cache miss → API çağrısı → cache'e yaz
         - BlocListener tetikleyicilerinde `invalidateAll()` + yeniden yükle
- [x] A.7.3.c — Tab geçişi optimizasyonu: `IndexedStack`
         - `TabsScreen` → `widgetOptions.elementAt(_selectedIndex)` yerine `IndexedStack(index: _selectedIndex, children: widgetOptions)`
         - Tüm tab widget'ları ağaçta kalır, state korunur, initState tekrar çalışmaz
```

#### Cache akışı (sequence):

```
Tab'a giriş / initState
  → CacheService.get("home_dashboard_api_system")
    → Cache var + TTL ≤ 60s → cache'den parse et, API çağrısı yok
    → Cache yok / TTL > 60s → API çağrısı yap → yanıtı cache'e yaz
  → CacheService.get("home_dashboard_randevu")
    → (aynı mantık)

Pull-to-refresh
  → CacheService.invalidateAll()
  → Her iki API'yi tekrar çağır
  → Yeni yanıtları cache'e yaz
```

---

### A.7.4 — Mobil: Dashboard servis refaktörü

```
- [x] A.7.4.a — URL sabitleri eklendi
         - `ApiHamamSpaUrlConstants.getMyMuzikOkulumHomeDashboardUrl`
         - `RandevuAlUrlConstants.getMyMuzikOkulumHomeDashboardUrl`
- [x] A.7.4.b — `MemberHomeDashboardService.loadFullDashboard` eklendi
         - `Future.wait([apiSystemHomeDashboard, randevuHomeDashboard])` → tek `MemberHomeFullDashboard` döner
         - insights, reminderPayments, statement chart data, today counts — hepsi birleşik yanıttan parse
- [x] A.7.4.c — `MemberTodaySummaryService` kaldırıldı (home init'ten)
         - Bugünkü ders/ödeme sayısı dashboard yanıtından alınıyor
         - Popup hala lazily `loadTodayOperationItems` çağırıyor (kullanıcı açtığında)
- [x] A.7.4.d — `MemberHomeRemindersService` kaldırıldı (home init'ten)
         - `payment_plans.reminder_items` dashboard yanıtından parse ediliyor
- [x] A.7.4.e — `MemberHomeStatementChartCard` refaktörü
         - `externalTotalDebit`, `externalTotalCredit`, `externalBalance`, `externalItems` props eklendi
         - Dashboard verisi sağlanırsa kendi API çağrısı yapılmaz
- [x] A.7.4.f — Fallback: `loadFullDashboard` başarısız → `_loadFullDashboardLegacy` (eski çoklu endpoint yaklaşımı)
```

---

### A.7.5 — Kazanım tablosu (beklenen)

| Metrik | Bugün | Hedef |
|--------|-------|-------|
| api-system istek sayısı (home init) | ~8–10+ (paginated sayfalar dahil) | **1** |
| randevu istek sayısı (home init) | 2 | **1** |
| Tab geçişi istek sayısı | Tüm istekler tekrar | **0** (cache / keep-alive) |
| Toplam ağ trafiği | Her tab geçişinde ~12+ istek | İlk yükleme: 2 istek, sonraki 60s: 0 |

---

### A.7.6 — Önerilen uygulama sırası

| Sıra | Görev | Proje | Bağımlılık |
|------|-------|-------|------------|
| 1 | A.7.1 — api-system `home-dashboard` endpoint | api-system | — |
| 2 | A.7.2 — randevu `home-dashboard` endpoint | randevu | — |
| 3 | A.7.3.c — Tab geçişi: `IndexedStack` | mobil | — (bağımsız) |
| 4 | A.7.3.a — Cache servisi | mobil | — (bağımsız) |
| 5 | A.7.4.a–b — URL sabitleri + dashboard servis refaktörü | mobil | Sıra 1 + 2 |
| 6 | A.7.4.c–e — Alt servis refaktörleri | mobil | Sıra 5 |
| 7 | A.7.4.f — Fallback mekanizması | mobil | Sıra 5 |
| 8 | A.7.3.b — Cache entegrasyonu | mobil | Sıra 4 + 5 |

**Not:** Sıra 1–2 (backend) ve Sıra 3–4 (mobil bağımsız iyileştirmeler) **paralel** yapılabilir. Sıra 5+ backend'ler hazır olunca başlar.

---

## B — Yoklamalar Sayfası

- [x] `muzik_okulum_attendance_screen.dart` oluşturuldu (`MuzikOkulumAttendanceScreen`)
- [x] Tarih (+ saat) bazlı DESC sıralama — her sayfa birleşiminde istemci tarafında da garanti
- [x] Sayfa başına 20 kayıt, infinite scroll (`last_page` ile)
- [x] Backend: api-system `GET v2/me/attendance-report?page=&itemsPerPage=` (`ApiHamamSpaUrlConstants.getMyAttendanceReportUrl`; randevu proxy). `attendance_history_screen.dart` ince sarmalayıcı olarak kaldı.

## C — Paket Bilgileri Sayfası

- [x] `package_list_screen.dart` oluşturuldu
- [x] Önce aktif paketler, sonra tarih bazlı DESC
- [x] Pagination (infinite scroll)
- [x] Backend endpoint: `GET v2/me/packages` (paginated, api_v2_member.php)
- [x] Durum badge: Aktif (yeşil) / Süresi Dolmuş (gri)
- [x] Kalan hak, başlangıç/bitiş tarihi, fiyat, indirim bilgileri

### C.1 — Paket özeti donut grafiği (kalan / toplam)

**Amaç:** Explore’daki üyelik **kalan gün / toplam gün** donut’una benzer görsel dil; **aktif paketlerde** (`quantity > 0`) **Σ kalan miktar ÷ Σ toplam miktar** — uygulama: müzik okulu anasayfada özet ile hızlı erişim arası.

**Metrik (kesin):** Yalnızca **aktif** paketler (`PackageListScreen` ile aynı “aktif” kuralı). Her satır için API alanları `remain_quantity` ve `quantity` — **pay** = Σ `remain_quantity`, **payda** = Σ `quantity` (sadece hak tabanlı paketler: `quantity > 0` olan satırlar toplama dahil; `quantity == 0` sınırsız/özel paketler donut dışı bırakılabilir veya ürün kararıyla ayrı gösterilir).

**Referans kod:** `lib/screen/explore.dart` (`fl_chart` `PieChart`, merkez metin); oran hesabı için `lib/data/model/member_register_chart_model.dart` örnek alınabilir (gün yerine yukarıdaki toplamlar).

- [x] **C.1.1** — Metrik tanımı: aktif paketlerde **toplam kalan miktar / toplam tanımlı miktar** (`remain_quantity` / `quantity` toplamları) — yukarıda sabitlendi
- [x] **C.1.2** — UI: Müzik okulu **anasayfa** — `MuzikOkulumHomeSummarySection` ile **Hızlı Erişim** arasında `MemberActivePackageRightsDonutCard`; tema getter’ları, tıklanınca `PackageListScreen(activeOnly: true)`
- [x] **C.1.3** — Veri: `MemberHomeDashboardService` — `GET v2/me/packages` sayfaları; özet kutusundaki “Kalan Toplam Hak” = tüm aktif `remain_quantity`; donut = yalnız `quantity > 0` satırlarında Σ kalan / Σ `quantity`
- [x] **C.1.4** — `MemberActivePackageRightsDonutCard` (`lib/core/widgets/member_active_package_rights_donut_card.dart`)
- [x] **C.1.5** — `AppLabels`: `homePackageRightsDonutTitle`, `…RemainingLegend`, `…UsedLegend`

## D — Cari Ekstre Sayfası

- [x] `statement_list_screen.dart` oluşturuldu
- [x] Satış (borç/kırmızı) ve tahsilat (alacak/yeşil) kartları
- [x] Üst kısımda bakiye özeti
- [x] İndirim, ödeme türü, açıklama bilgileri alt bölümde
- [x] Backend endpoint: `GET v2/me/statements` (MemberStatementV2Controller'a delege)

## E — Ders Programı Sayfası

- [x] `lesson_schedule_screen.dart` oluşturuldu
- [x] `service_plan_enrollments` bazlı — sadece üyenin kayıtlı olduğu dersler
- [x] DaySelector ile gün seçimi (ileri-geri navigasyon)
- [x] Sadece görüntüleme — randevu/kayıt işlemi yok
- [x] Backend endpoint: `GET v2/me/my-schedule` (randevu projesi, enrollment bazlı)
- [x] API'den tüm haftalık program tek seferde alınıyor, gün bazlı filtreleme Flutter tarafında
- [x] Bugün seçiliyken `GET v2/me/attendance-report` ile **telafi** (`is_makeup`) satırları programa eklenir (şablonda olmayan gün/slot)
- [x] Kart üstünde **Derslerim** etiketi; telafi için `makeupLesson` mini etiket
- [x] Ortak liste kartı: `PanelMemberLessonCard` (`panel_member_lesson_card_widget.dart`); opsiyonel `initialWeekday` ile derin link

## F — Öneri Şikayet Sayfası

- [x] Mevcut `SuggestionComplaint` ekranı kullanılıyor (anasayfadan erişim bağlandı)

## G — Veli Bilgisi Sayfası

- [x] `guardian_list_screen.dart` oluşturuldu
- [x] Liste görünümü (trainer list tasarımı)
- [x] Backend endpoint: `GET v2/me/guardians` (api_v2_member.php)
- [x] Yakınlık label'ları: `RelationshipType` helper (case-insensitive)
- [x] Birincil veli badge, not alanı, tıklanabilir telefon

## H — Planlı Ödeme Sayfası

- [x] `payment_plan_list_screen.dart` oluşturuldu
- [x] Ödenmeyenler üstte (en yakın tarihli), ödenenler en altta
- [x] Pagination (infinite scroll)
- [x] Backend endpoint: `GET v2/me/payment-plans` (api_v2_member.php)
- [x] Durum badge: Ödendi (yeşil), Ödenmedi (sarı), Gecikmiş (kırmızı)

## I — Eğitmen Kadrosu

- [x] Mevcut `TrainerListScreen` kullanılıyor (anasayfadan ve profilden erişim)

---

## M — Anasayfa: Özet kartı (Dashboard özeti)

**Amaç:** Üst butonların altında (veya slider üstü/altı), tek bakışta durum özeti.

- [x] **M.1** — Özet kartı: `MuzikOkulumHomeSummarySection` (`muzik_okulum_home_summary_section.dart`) + `muzik_okulum_home_screen` entegrasyonu
- [x] **M.2** — Metrikler: aktif paket + kalan hak (`panel-summary` + paketler), bu hafta ders sayısı, geciken ödeme adedi, bir sonraki günün ders slotları (`MemberHomeDashboardService` birleşimi)
- [x] **M.3** — Görsel: `BlocTheme`, üst üçlü metrik kutuları + takvim satırı; ders programı ile hizalı kart çerçevesi
- [x] **M.4** — `AppLabels` (TR/EN): özet başlıkları, sonraki ders etiketi, boş metinler, geciken liste başlığı vb.
- [x] **M.5** — Client birleşimi: `panel-summary` + sayfalı `payment-plans` + `my-schedule` (`MemberHomeDashboardService`); tek `home-insights` API yok (J.9 hâlâ öneri)
- [x] **M.6** — Özet kartında **Son yoklamalar:** bir sonraki ders bloğunun altında `GET v2/me/attendance-report` ile **son 2** kayıt (iptal hariç); ders adı, öğretmen, tarih·saat, telafi, durum chip (`AttendanceReportStatusPresentation`); tıklanınca `MuzikOkulumAttendanceScreen`; `MemberHomeDashboardService._fetchRecentAttendance` + `AppLabels.homeSummaryRecentAttendanceTitle` (2026-04)

**Detay:** Kart tıklanınca ilgili derin ekrana gidebilir (ör. ödeme özeti → planlı ödeme; ders → ders programı). İlk sürümde sadece bilgi (navigasyon opsiyonel).

---

## N — Hatırlatıcı merkezi

**Amaç:** **Ödeme** (yakın / geciken vade) ve **duyuru** hatırlatmalarını tek listede veya yatay kaydırmalı şeritte göstermek.

**Kapsam dışı (bilinçli):** **Yaklaşan / bir sonraki ders** anasayfa **özet** bölümünde (`MuzikOkulumHomeSummarySection`, **P**) zaten var; hatırlatıcı merkezinde **tekrar edilmez**.

- [x] **N.1** — UI: Anasayfada “Hatırlatıcılar” başlıklı bölüm — liste (max 3–5) veya `PageView` / yatay `ListView` kartları (`MuzikOkulumHomeRemindersSection`, 2026-04)
- [x] **N.2** — Veri kaynakları:
  - **Ödeme:** `payment-plans` — geciken + önümüzdeki N gün veya bugün/yarın vadeli ödenmemiş (özet kartındaki geciken sayım ile uyumlu kurallar) → uygulamada hatırlatıcı ödemeleri: ödenmemiş, bugün…+10 gün (`MemberHomeRemindersService`); geciken sayım özet kartında (**U**)
  - **Duyuru:** `AnnouncementCubit` / son duyuru özeti (varsa)
- [x] **N.3** — Öncelik sırası: **geciken ödeme** > **yakın vade ödeme** > **duyuru** — hatırlatıcıda önce geciken blok, sonra yakın vade, sonra duyuru; tek API taramasında ayrıştırma (`MemberHomeRemindersService.fetchPaymentRemindersPartitioned`, 2026-04)
- [x] **N.4** — Boş durum: başlık + ikon + `AppLabels.homeRemindersEmptyState` (ödeme ve duyuru yokken kart gösterilir; 2026-04)
- [x] **N.5** — Opsiyonel: “Tümünü gör” ve ödeme satırı tıklanınca → `PaymentPlanListScreen(showNearDuePaymentsOnly: true)` (hatırlatıcı penceresiyle aynı filtre; 2026-04)

**Detay:** Push bildirimi yok; bu madde **uygulama içi** hatırlatıcı. İleride aynı veri seti bildirim servisiyle paylaşılabilir.

---

## P — Sonraki ders(ler)

**Amaç:** Bir sonraki (veya önümüzdeki 3) dersi net göstermek.

- [x] **P.1** — Veri: `my-schedule` + `ScheduleDayOfWeekUtil`; bugünden sonraki ilk takvim gününün tüm slotları (`MemberHomeNextLessonModel`)
- [x] **P.2** — UI: Özet içinde “Bir Sonraki Ders/Derslerim” — ders adı → öğretmen → `dd.MM.yyyy HH:mm` (çerçevesiz metin yığını)
- [x] **P.3** — Tıklanınca `LessonScheduleScreen(initialWeekday: …)` — ilgili hafta günü seçili açılır
- [x] **P.4** — `AppLabels` — boş durum metni (TR/EN)

---

## Q — Şablon ders + yoklama birleştirme (kapsam dışı)

**Karar (2026-04):** Üye tarafında yoklama **yalnızca** `GET v2/me/attendance-report` ile; randevu programı (`my-schedule`) ile yoklama satırlarının istemcide birleştirilmesi (ör. “Son 5 birleşik ders” kartı, iki kaynak, Q.1–Q.4 kapsamı) **yapılmayacak**. Özet anasayfa: **M.6**; tam liste: `MuzikOkulumAttendanceScreen`.

- [x] **Q** — ~~Birleşik ders geçmişi + yoklama maddeleri~~ — **İptal** (yukarıdaki karar)

---

## R — İletişim (Profilim → Tesis detayları)

**Amaç:** Telefon, e-posta, adres, harita, WhatsApp — tek yerden.

- [x] **R.1** — Konum: `muzik_okulum_member_profile_screen` veya tesis detay ekranı (mevcut “Tesis detayları” akışı) — yeni “İletişim” alt bölümü veya mevcut sayfaya blok ekleme
- [x] **R.2** — Veri: `MobileAppSettings` / şube API’si / statik config — hangi alanların geldiği netleştirilir
- [x] **R.3** — UI: Satır satır `ListTile` veya kart; `url_launcher` ile tel/mail/harita/WhatsApp
- [x] **R.4** — `AppLabels` — bölüm başlığı ve boş alan metinleri

---

## S — Cari ekstre grafik gösterimi

**Amaç:** Liste yanında veya üstünde borç/alacak trendi veya dönem özeti.

- [x] **S.1** — Grafik türü: Aylık **satış / tahsilat çubukları** (`fl_chart` `BarChart`, son 6 takvim ayı) — `MemberHomeStatementChartConstants.visibleMonthCount`
- [x] **S.2** — Veri: `GET v2/me/statements` tam liste → client’ta aya göre toplam (`MemberStatementChartBucketsUtil`); backend `statements/summary` yok
- [x] **S.3** — Yerleşim: Müzik okulu **anasayfa** — **hatırlatıcı** ile **hızlı erişim** arası `MemberHomeStatementChartCard`; tema `panelDebtColor` / `panelPaidColor`. (`StatementListScreen` üstü kart: henüz yok.)
- [x] **S.5** — `AppLabels`: `homeStatementChartTitle`, `homeStatementChartSubtitle`, `homeStatementChartEmpty` (TR/EN)

---

## T — Yakında bitecek paketler & aktif paket kalan özeti

**Amaç:** Bitiş tarihi yakın paketleri vurgulama; kalan hak özeti.

- [x] **T.1** — Kural: `NearExpiryPackageConstants` — bitişe kalan tam gün sayısı 7’den küçük; haklı pakette kalan hak 2’den küçük; kalan 0 olan haklı paket yakında bitecek sayılmaz (`MemberPackageNearExpiryUtil`) — 2026-04
- [x] **T.2** — UI: **Paketlerim** donut kartı (`MemberActivePackageRightsDonutCard`) — “Paketiniz bitmek üzere” uyarı satırı; ayrı mini kart şeridi yok (ürün tercihi)
- [x] **T.3** — Tıklama: uyarı → `PackageListScreen(nearExpiryOnly: true)`; “Detaylı incele” → `PackageListScreen(activeOnly: true)`; karttan paket → `PackageDetailScreen` — 2026-04
- [x] **T.4** — Σ kalan / Σ toplam hak donut merkezinde; aktif paket listesinde kalan 0 haklı paket gösterilmez (`shouldOmitFromActivePackagesList`) — 2026-04
- [x] **T.5** — `AppLabels`: `homePackageNearExpiryWarning`, `nearExpiryPackagesListTitle` (TR/EN) — 2026-04

---

## U — Geciken ödemeler

**Amaç:** Vadesi geçmiş ödenmemiş planlı ödemeleri öne çıkarma.

- [x] **U.1** — Veri: özet yükünde `payment-plans` sayfaları taranarak geciken sayım (`MemberHomeDashboardService` / `MemberTodayPaymentPlanStatsService` mantığı ile uyumlu)
- [x] **U.2** — UI: özet kartında üçüncü metrik kutusu — geciken adet; değer > 0 iken `panelDangerColor` (ayrı “hatırlatıcı şeridi” N maddesinde değil)
- [x] **U.3** — Tıklanınca `PaymentPlanListScreen(showOverduePaymentsOnly: true)`
- [x] **U.4** — `AppLabels` — geciken liste başlığı / özet etiketleri

---

## V — Genel görsel / tasarım (ekranı sadeleştirmekten çıkarma)

**Amaç:** Tutarlı, modern panel hissi — tema ile uyumlu.

- [x] **V.2** — Özet + program: `BlocTheme` metin/renk kuralları (yeni ekranlarda hardcoded tipografi yok)
- [x] **V.3** — Özet dış çerçeve / metrik kutuları: mevcut panel radius, border, gölge ile uyum
- [x] **V.4** — Özet: yüklemede `LoadingIndicatorWidget`; boş metinler `AppLabels`
- [ ] **V.5** — Tek dashboard API + 60s istemci cache + tab keep-alive → **A.7** kapsamında çözülecek

---

## J — Backend Self-Service Endpoint'ler (Gerekli)

> Mevcut `v2/members/{id}/...` endpoint'leri staff auth ile korunuyor.
> Üye paneli için `v2/me/...` altında self-service endpoint'ler gerekli.

- [x] J.1 — Self-service route grubu oluştur (`v2/me/...`) — api_v2_member.php
- [x] J.2 — `GET v2/me/packages` — Kendi paketleri (paginated)
- [x] J.3 — `GET v2/me/statements` — Kendi cari ekstresi
- [x] J.4 — `GET v2/me/guardians` — Kendi velileri
- [x] J.5 — `GET v2/me/payment-plans` — Kendi ödeme planı (paginated)
- [x] J.6 — `GET v2/me/today-lessons` — Bugünkü dersler (randevu projesi)
- [x] J.7 — `GET v2/me/panel-summary` — Aktif paket + bugünkü ödeme sayısı
- [-] J.8 — Pagination: mevcut endpoint'ler yeterli; `home-dashboard` backend'de topluca tarayacak → **A.7.1**
- [-] J.9 — ~~Ayrı `home-insights`~~ → **A.7.1** `home-dashboard` olarak birleştirildi
- [-] J.10 — ~~Ayrı `statements/summary`~~ → **A.7.1.e** `home-dashboard.statements.monthly_summary` olarak dahil

## K — Mevcut Endpoint Kullanımı

- [x] K.1 — Ders programı: randevu `GET v2/me/my-schedule` (+ üye cari özeti için api-system proxy `GET v2/me/attendance-report`)

## L — Flutter URL Sabitleri (kapsam dışı)

**Karar:** Müzik okulu için ayrı bir `muzik_okulum_url_constants.dart` **yok**. İki backend tabanı zaten ayrı constant sınıflarında toplanıyor:

- **api-system (Hamam Spa):** `ApiHamamSpaUrlConstants` — `v2/me/panel-summary`, `packages`, `statements`, `payment-plans`, `guardians`, `attendance-report` vb.
- **Randevu:** `RandevuAlUrlConstants` — `v2/me/my-schedule`, `today-lesson-count` vb.

Üye paneli ekranları doğru tabanı seçerek bu iki sınıftan devam eder; üçüncü bir facade eklenmez (tekrar veya yanlış taban riski yaratmamak için).

- [x] L.1 — ~~Ayrı `muzik_okulum_url_constants.dart`~~ — **İptal** (yukarıdaki mimari karar, 2026-04)

---

## A.7 — Tamamlanan işler (özet)

| Madde | Kapsam | Durum |
|-------|--------|-------|
| **A.7.1** (a–f) | api-system backend | ✅ `GET v2/me/muzik-okulum/home-dashboard` — canlıda |
| **A.7.2** (a–c) | randevu backend | ✅ `GET v2/me/muzik-okulum/home-dashboard` — canlıda |
| **A.7.3** (a–c) | mobil | ✅ IndexedStack + 60s in-memory cache + cache entegrasyonu |
| **A.7.4** (a–f) | mobil | ✅ Dashboard servis refaktörü + fallback |
| **V.5** | mobil | ✅ A.7.3 ile çözüldü |
| ~~**J.8**~~ | — | ✅ A.7.1 kapsamında |
| ~~**J.9**~~ | — | ✅ A.7.1 olarak hayata geçti |
| ~~**J.10**~~ | — | ✅ A.7.1.e (monthly_summary) olarak dahil |

### A.7.5 — Kazanım (gerçekleşen)

| Metrik | Öncesi | Sonrası |
|--------|--------|---------|
| api-system istek sayısı (home init) | ~8–10+ | **1** (birleşik dashboard) |
| randevu istek sayısı (home init) | 2 | **1** (birleşik dashboard) |
| Tab geçişi istek sayısı | Tüm istekler tekrar | **0** (IndexedStack + cache) |
| Toplam ağ trafiği | Her tab geçişinde ~12+ istek | İlk yükleme: 2, sonraki 60s: 0 |

---

## Henüz yapılmayan maddeler (özet)

A.7 kapsamı tamamlandı. Bekleyen madde yok.
