# Yüzme kursu (`swimming_course`) — üye paneli görevleri

## Tamamlanan (temel)

- [x] Müzik okulu üye panelinin kopyası: `lib/screen/panel/member/swimming-course/` (anasayfa, özet/hatırlatma bölümleri, yoklama, profil menüsü, üye profili).
- [x] `ApplicationType.usesSchoolStyleMemberPanel` (`muzik_okulum` | `swimming_course`) — üç sekmeli düzen.
- [x] `Tabs` + `BottomNavigationBarWidget`: `swimming_course` üyede Ana / QR / Profil.
- [x] `MemberQrScreen` ön kontrolleri: okul tarzı panelde gym QR kuralları atlanır (müzik okulu ile aynı).

## Tamamlanan (UI sadeleştirme)

1. [x] **Anasayfa özet** — Aktif paket / haftalık ders / gecikmiş ödeme ve sonraki ders kaldırıldı; yalnızca son yoklamalar (`SwimmingCourseHomeSummarySection`).
2. [x] **Hızlı erişim** — Ders programı kısayolu kaldırıldı (`SwimmingCourseHomeScreen` ilk satır).
3. [x] **Profil menüsü** — Ders programı, tesis detayları, kurum kuralları kaldırıldı (`SwimmingCourseProfileMenuScreen`).

## Eğitmen / Randevu (`system.randevual.online`)

- [x] **Takvim `employee_id`** — `GET api/v2/me/service-plans/calendar`: Randevu `TrainerServicePlanCalendarController` JWT `user.id` değerini `employee_id` olarak zorlar; mobil sorgu parametresi göndermez (`RandevuAlUrlConstants.getV2ServicePlansCalendarUrl`).
- [ ] **POST ders planı `employee_id`** — `POST api/v2/me/service-plans` gövdesinde `employee_id` alanını JWT’den dolduran eğitmen wrapper (şu an istemci gönderiyor); staff `ServicePlanV2Controller::store` ile DRY.
