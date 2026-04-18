import 'package:e_sport_life/core/enums/application_type.dart';
import 'package:e_sport_life/core/enums/supported_locale.dart';
import 'package:e_sport_life/core/l10n/app_labels_en.dart';
import 'package:flutter/widgets.dart';

abstract class AppLabels {
  // ─── Roller ───
  String get member;
  String get trainer;
  String get moderator;
  String get admin;

  // ─── Panel Modüller ───
  String get groupLesson;
  String get quickReservation;
  String get personalTraining;
  String get reservation;
  String get calendar;
  String get fitnessProgram;
  String get bodyMeasurement;
  String get diet;
  String get memberCard;
  String get reports;
  String get qrScan;
  String get employees;
  String get locations;
  String get enrollment;
  String get movementCatalog;

  // ─── Admin Modüller ───
  String get members;
  String get packageSale;
  String get payment;
  String get expense;
  String get sms;
  String get announcement;
  String get dashboard;
  String get settings;
  String get abilityManagement;

  // ─── Navigasyon ───
  String get home;
  String get profile;
  String get qrCode;
  String get account;
  String get shop;

  // ─── Genel Eylemler ───
  String get save;
  String get saving;
  String get cancel;
  String get delete;
  String get edit;
  String get add;
  String get search;
  String get selectCountry;
  String get list;
  String get detail;
  String get confirm;
  String get approve;
  String get close;
  String get update;
  String get yes;
  String get no;
  String get send;
  String get selectFromContacts;
  String get selectFile;
  String get takePhoto;
  String get chooseFromGallery;
  String get deletePhoto;
  String get photoUpdated;
  String get photoDeleted;
  String get photoUpdateFailed;
  String get previous;
  String get next;

  // ─── Yoklama / Hak Düşüm ───
  String get attendance;
  String get attendanceDescription;
  String get attendanceScanQr;
  String get scanMemberQr;
  String get cardNumber;
  String get enterCardNumber;
  String get searchMember;
  String get cardNumberInvalid;
  String get invalidOrExpiredQr;
  String get memberNotFoundByCard;
  String get noActivePackage;
  String get burnConfirm;
  String get burnSuccess;
  String get burnError;
  String get scanNewMember;
  String get activePackages;
  String get packageDeductions;
  String get undoDeduction;
  String get undoDeductionConfirm;
  String get undoDeductionSuccess;
  String get undoDeductionError;
  String get noDeductionHistory;
  String get onlyTodayCanUndo;
  String get attendanceSelectLessonTitle;
  String get attendanceNoLessonsToday;
  /// Ders programı — bugün için «Yoklama al» pill metni.
  String get scheduleTakeAttendanceFab;
  /// Yoklama ekranı — önceden seçilen ders bloğunun başlığı.
  String get attendancePresetLessonHeading;
  /// Üst başlığın altında tek satır ipucu (ne işe yaradığı).
  String get attendancePresetLessonSectionHint;
  /// Yoklama — kapalı kart satırında «devamını görüntüle» bağlantısı.
  String get attendanceLessonCardShowMore;
  String get attendanceLessonCardShowLess;

  // ─── Durum ───
  String get loading;
  String get noData;
  String get error;
  String get success;
  String get remainingRights;
  String get burnRight;
  String get refundRight;
  String get noAccessPermission;

  // ─── Giriş / Doğrulama ───
  String get verificationCode;
  String get enterVerificationCode;
  String get verificationCodeHint;
  String get verificationCodeError;
  String get serverUnreachable;
  String get codeValidating;
  String get login;
  String get logout;
  String get logoutConfirm;
  String get kvkkTitle;
  String get kvkkApprovalRequired;
  String get kvkkRead;
  String get kvkkLoadError;

  // ─── Splash / Karşılama ───
  String get welcome;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get goodNight;

  // ─── Anasayfa (Explore) ───
  String get quickAccess;
  String get remainingDays;
  String get noActiveMembership;
  String get membershipFrozen;
  String get facilityOccupancy;
  String get noOccupancyData;
  String get detailedView;
  String get fullList;
  String get featureNotActive;
  String get accountPassiveWarning;
  String get accountPassiveProfileWarning;

  // ─── Geçiş / Turnstile ───
  String get entryIn;
  String get entryOut;

  // ─── Tesis ───
  String get facilityInfo;
  String get photo;
  String get contactInfo;
  String get phoneLabel;
  String get emailLabel;
  String get whatsappLabel;
  String get addressLabel;
  String get openInMaps;
  String get sendWhatsApp;
  String get callPhone;
  String get sendEmail;

  // ─── Profil Menü ───
  String get myProfile;
  String get paymentHistory;
  String get pastEntryHistory;
  String get facilityDetails;
  String get trainerRoster;
  String get suggestionComplaint;
  String get groupLessonRules;
  String get quickReservationRules;
  String get facilityRules;
  String get membershipRules;
  String get institutionRules;
  String get about;

  // ─── Hızlı Erişim (Explore Grid) ───
  String get inviteFriend;
  String get virtualWallet;
  String get earnAsYouSpend;
  String get exerciseList;
  String get measurementInfo;
  String get nutritionInfo;
  String get groupLessons;

  // ─── Paket / Abonelik ───
  String get subscriptionInfo;
  String get purchasedBranchPackages;
  String get purchasedPtPackages;
  String get massagePackages;
  String get contractNo;
  String get startDate;
  String get discount;
  String get selectTrainer;
  String get appointmentDateTime;
  String get createAppointment;
  String get myAppointments;
  String get cancelAppointment;
  String get cancelled;
  String get appointmentCreatedSuccess;
  String get appointmentNotFound;

  // ─── Ödeme ───
  String get paymentSummary;
  String get amount;
  String get totalPaid;
  String get remaining;
  String get myPayments;
  String get upcomingPeriod;
  String get makePayment;

  // ─── Grup Dersi ───
  String get groupLessonDetail;
  String get person;
  String get minParticipation;
  String get opening;
  String get fee;
  String get paid;
  String get free;
  String get registrationAuth;
  String get purchasedMembers;
  String get day;
  String get registered;
  String get registrationAvailable;
  String get reservationOnLessonDay;
  /// [formattedDate] uzun tarih metni (ör. `13 Nisan 2026`).
  String scheduleListHeaderForDate(String formattedDate);
  String get groupLessonScheduleLessonTimeLabel;
  String get groupLessonScheduleCapacityLabel;

  // ─── Ölçüm ───
  String get myMeasurements;
  String get measurementDetail;
  String get addMeasurement;
  String get deleteMeasurement;
  String get deleteMeasurementConfirm;
  String get measurementDeletedSuccess;
  String get noMeasurementData;
  String get pdfFiles;
  String get images;
  String get weight;
  String get arm;
  String get shoulder;
  String get height;
  String get chest;
  String get abdomen;
  String get fieldRequired;

  // ─── Fitness / Egzersiz ───
  String get exerciseExecution;
  String get exerciseDone;
  String get videoNotAvailable;
  String get videoAvailable;
  String get movement;

  // ─── Dolap ───
  String get closetList;
  String get emptyElectronicCloset;
  String get closetPassword;

  // ─── Öneri ───
  String get suggestionComplaintHistory;
  String get createSuggestionComplaint;
  String get title;
  String get topicTitle;
  String get suggestionAndComplaint;
  String get writeSuggestionComplaint;
  String get sentSuccess;
  String get sendFailed;
  String get fillAllFields;
  String get viewSuggestionComplaint;
  String get submitting;
  String get currencySuffix;

  // ─── Davet ───
  String get inviteFriendTitle;
  String get enterFriendInfo;
  String get inviteSentSuccess;
  String get contactPermissionRequired;
  String get contactPickError;
  String get fillRequiredFieldsAndPhone;
  String get retry;
  String get inviteKvkkConsentPrefix;
  String get inviteKvkkConsentSuffix;

  // ─── Sanal Cüzdan / Harcadıkça Kazan ───
  String get transactionHistory;
  String get balanceLoad;
  String get spending;
  String get usablePoints;
  String get convertAndSpendPoints;
  String get transaction;
  String get earnedPoints;
  String get orderNo;
  String get description;

  // ─── Mağaza (GymExxtra) ───
  String get packageSelection;
  String get selectPackage;
  String get selectedPackage;
  String get orderHistory;
  String get orderSummary;
  String get productAmount;
  String get discountAmount;
  String get payableAmount;
  String get orderDate;
  String get purchase;
  String get enterCouponCode;
  String get couponApplied;
  String get invalidCoupon;
  String get cartError;
  String get branchInfoError;
  String get paymentPageError;
  String get cartOperationFailed;

  // ─── QR ───
  String get qrCodeGenerating;
  String get screenBrightness;
  String get scanQrCode;
  String get renewQrCode;
  String get refreshCode;
  String get tryAgain;
  String get qrCodeCreateFailed;
  String get configNotFound;
  String get securityCodeServiceUnavailable;

  // ─── Üye QR Kontrol Mesajları ───
  String get overduePaymentWarning;
  String get debtExistsWarning;
  String get membershipFrozenWarning;
  String get noActivePackageWarning;
  String get outsideEntryHoursWarning;

  // ─── Profil Düzenleme ───
  String get fullName;
  String get phoneNumber;
  String get email;
  String get gender;
  String get male;
  String get female;
  String get birthDate;
  String get birthDateFormat;
  /// Profil doğum tarihi ipucu (tireli gün-ay-yıl); müzik okulu vb.
  String get birthDateFormatDash;
  String get notificationsEnabled;
  String get selectFromGallery;
  String get takeFromCamera;
  String get photoProcessing;
  String get photoDeleting;
  String get mayTakeSeconds;
  String get lockerPassword;
  String get confirmEmail;
  String get emailVerified;
  String get emailNotVerified;
  String get sendVerification;
  String get verificationSent;
  String get emailVerificationSent;
  String get emailVerificationFailed;
  String get changePassword;
  String get currentPassword;
  String get newPassword;
  String get newPasswordConfirm;
  String get passwordMinLength;
  String get passwordMismatch;
  String get passwordSameAsOld;
  String get currentPasswordWrong;
  String get passwordChangeSuccess;
  String get passwordChangeFailed;
  String get changePhone;
  String get newPhone;
  String get phoneChecking;
  String get phoneAvailable;
  String get phoneTaken;
  String get phoneSameAsCurrent;
  String get invalidPhoneFormat;
  String get phoneCheckError;
  String get phoneChangeSuccess;
  String get phoneChangeFailed;
  String get changeEmail;
  String get newEmail;
  String get emailChecking;
  String get emailAvailable;
  String get emailTaken;
  String get emailSameAsCurrent;
  String get invalidEmailFormat;
  String get emailCheckError;
  String get emailChangeSuccess;
  String get emailChangeFailed;
  String get profileUpdateSuccess;
  String get profileUpdateFailed;
  String get sessionNotFoundReLogin;
  String get apiConnectionNotFound;

  // ─── Dil Seçimi ───
  String get language;
  String get languageTurkish;
  String get languageEnglish;

  // ─── Trainer Home ───
  String get todayProgram;
  String get todayGroupLessons;
  String get todayQuickReservations;
  /// Bugünün özeti popup’ta “hızlı randevu” satır grubu başlığı (yüzme kursu eğitmeninde [SwimmingCourseLabels] ile “yoklama”).
  String get trainerTodayDashboardQuickReservationSectionTitle;
  String get todayPtReservations;
  String get recentTransactions;
  String get noRecentTransactions;
  String get reservationDetail;
  String get lessonCount;
  String get personCount;

  // ─── Trainer Profil ───
  String get biography;
  String get biographyHint;
  String get expertise;
  String get selectExpertise;
  String get colorLabel;
  String get selectColor;
  String get removeColor;

  // ─── İnternet / Oturum ───
  String get noInternetConnection;
  String get checkInternetAndTryAgain;
  String get checkInternetConnection;
  String get sessionExpired;
  String get sessionExpiredReGetCode;
  String get sessionOpenedOnAnotherDevice;
  String get sessionOpenedOnAnotherDeviceReLogin;

  // ─── Genel Hata ───
  String get errorOccurred;
  String get fieldCannotBeEmpty;
  String get urlCouldNotOpen;
  String get fileUrlNotFound;
  String get fileCouldNotOpen;
  String get fileDownloadError;

  // ─── Gün İsimleri ───
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;

  // ─── Filtre ───
  String get all;

  // ─── Eğitmen Değerlendirme ───
  String get rateTrainer;
  String get selectStarRating;
  String get rate;
  String get rating;

  // ─── Duyurular ───
  String get announcementsAndNotifications;
  String get announcementNotFound;

  // ─── Uygulama Güncelleme ───
  String get newVersionAvailable;

  // ─── Müzik Okulu / Genel Panel ───
  String get todayMyLessons;
  String get todayMyPayments;
  /// Üye anasayfa üst satır — bugünkü yoklama kayıtları (yüzme vb.).
  String get todayMyAttendances;
  String get myActivePackages;
  /// Anasayfa üçüncü buton + özet ekranı başlığı
  String get todaySummaryTitle;
  /// Yüzme kursu eğitmen anasayfa — bugünkü yoklamalar özeti kartı
  String get trainerHomeTodayAttendanceTitle;
  /// Yüzme kursu eğitmen hızlı erişim — doğrudan QR tarama ile yoklama
  String get trainerQuickAccessAttendanceByQrTitle;

  // ─── Eğitmen ders ekleme (Randevu service-plans / Fitiz schedule) ───
  String get trainerScheduleAddLessonTitle;
  String get trainerScheduleEditLessonTitle;
  String get trainerScheduleEditLessonDaysHint;
  String get trainerScheduleLoadLessonFailed;
  String get trainerScheduleDeleteLessonConfirm;
  String get trainerScheduleLessonDeleted;
  String get trainerScheduleDeleteLessonFailed;
  String get trainerScheduleLessonNameLabel;
  String get trainerScheduleServiceTypeLabel;
  String get trainerScheduleWeekdayLabel;
  String get trainerScheduleStartTimeLabel;
  String get trainerScheduleStartTimeHint;
  String get trainerScheduleDurationLabel;
  String get trainerSchedulePeriodLabel;
  String get trainerSchedulePeriodWeekly;
  String get trainerSchedulePeriodOneTime;
  String get trainerSchedulePersonLimitLabel;
  String get trainerScheduleTrackPaymentLabel;
  String get trainerScheduleTrainerFixedHint;
  String get trainerScheduleNoLocationOption;
  String get trainerScheduleLessonSaved;
  String get trainerScheduleLessonSaveFailed;
  String get trainerScheduleLoadFormFailed;
  String get trainerScheduleSelectService;
  String get trainerScheduleSectionEssentials;
  String get trainerScheduleSectionSchedule;
  String get trainerScheduleSectionLimits;
  String get trainerScheduleSectionMore;
  String get trainerScheduleTrackPaymentSubtitle;
  String get trainerScheduleLessonDaysLabel;
  String get trainerScheduleLessonDaysHint;
  /// Seçilen günlere göre saat/süre kartlarının üst başlığı.
  String get trainerScheduleDayTimeSlotsTitle;
  /// Gün satırında saat alanı etiketi (gün adı ayrı gösterilir).
  String get trainerScheduleDayStartTimeShortLabel;
  /// Saat seçici (ikon / erişilebilirlik).
  String get trainerSchedulePickTimeTooltip;
  /// Saat alanı — dokunarak sistem saat seçicisi.
  String get trainerSchedulePickTimeFieldHint;
  String get trainerScheduleSelectAtLeastOneDay;
  String trainerScheduleLessonsSaveResult(int saved, int failed);

  /// Anasayfa özet kartları — bölüm başlığı
  String get homeSummarySectionTitle;
  String get homeSummaryActivePackagesLabel;
  String get homeSummaryRemainingRightsLabel;
  String get homeSummaryThisWeekLessonsLabel;
  String get homeSummaryThisWeekLessonsCaption;
  String get homeSummaryOverduePaymentsLabel;
  String get homeSummaryOverduePaymentsCaption;
  String get homeSummaryNextLessonLabel;
  String get homeSummaryNextLessonEmpty;
  /// Anasayfa özet — bir sonraki ders bloğunun altında son yoklamalar
  String get homeSummaryRecentAttendanceTitle;
  /// Özet kartı — bir sonraki ders ve altı için genişlet/daralt
  String get homeSummaryShowMore;
  String get homeSummaryShowLess;
  /// Anasayfa — özet ile hızlı erişim arası donut kart başlığı
  String get homePackageRightsDonutTitle;
  String get homePackageRightsDonutRemainingLegend;
  String get homePackageRightsDonutUsedLegend;
  /// Donut kartı — toplam hak 0 iken sol metin (Explore’daki “üyelik yok” satırı)
  String get homePackageRightsDonutEmptyStateLine;
  /// Donut kartı — kalan hak veya bitiş tarihi eşiğinde uyarı satırı (tıklanabilir)
  String get homePackageNearExpiryWarning;
  /// Paket listesi — yalnızca yakında bitecek aktif paketler başlığı
  String get nearExpiryPackagesListTitle;
  /// Anasayfa — hatırlatıcılar (ödeme + duyuru) bölüm başlığı
  String get homeRemindersSectionTitle;
  /// Hatırlatıcı bölümü — ödeme/duyuru yokken kısa metin
  String get homeRemindersEmptyState;
  /// Hatırlatıcı — planlı ödemeler listesine git
  String get homeRemindersSeeAll;
  /// Hatırlatıcı — vade takvim günü bugün
  String get homeReminderPaymentDueToday;
  /// Hatırlatıcı — vade takvim günü yarın
  String get homeReminderPaymentDueTomorrow;
  /// Hatırlatıcı — vade en az 2 gün sonra ([days] takvim günü farkı)
  String homeReminderPaymentDueInDays(int days);
  /// Hatırlatıcı — ödemeler blok başlığı
  String get homeRemindersUpcomingPaymentsSubtitle;
  /// Hatırlatıcı — duyurular blok başlığı
  String get homeRemindersAnnouncementsSubtitle;
  /// Anasayfa — cari ekstre mini grafik başlığı (hatırlatıcı / hızlı erişim arası)
  String get homeStatementChartTitle;
  /// Anasayfa — cari grafik alt açıklaması (dönem + tür)
  String get homeStatementChartSubtitle;
  /// Anasayfa — seçilen aylarda grafiklenecek satış/tahsilat yok
  String get homeStatementChartEmpty;
  /// Anasayfa — cari bakiye altı; borç/alacak yokken bilgilendirme
  String get homeStatementChartNoDebtLine;
  /// Bugünün özeti ekranı — kısa açıklama (alt başlık / boş durum üstü)
  String get summaryHintShort;
  String get summaryRowActivePackages;
  String get summaryRowLessonsToday;
  String get summaryRowPlannedPayments;
  String get summaryRowPackageRegistrationsToday;
  String get summaryRowCollectionsToday;
  String get summaryRowAttendanceToday;
  String get summaryValueNone;
  /// "işlem" / "transactions" — tahsilat satırında adet yanında
  String get summaryTransactions;
  String get summaryAttendanceRecords;
  /// Bugün işlem yoksa popup alt başlığı
  String get summaryNoActivityToday;
  /// Özet satırında adet yanında (örn. "2 ders")
  String get summaryUnitLesson;
  String get summaryUnitPlannedPayment;
  String get summaryUnitPackageSale;
  String get summaryUnitCollection;
  /// Özet alt başlığında satış+tahsilat toplamı (örn. "3 cari ekstre hareketi")
  String get summaryUnitStatementMovements;
  String get summaryUnitAttendance;
  /// Popup: planlı ödeme / cari ekstre kaynak notu (alt satır)
  String get summaryPopupFootnotePlannedAndStatement;
  /// Liste satırı üst etiketi — planlı ödeme kalemi
  String get summaryRowBadgePlannedPayment;
  /// Liste satırı üst etiketi — cari ekstre (satış veya tahsilat)
  String get summaryRowBadgeStatementMovement;
  /// Liste satırı üst etiketi — cari satış
  String get summaryRowBadgeStatementSale;
  /// Liste satırı üst etiketi — cari tahsilat
  String get summaryRowBadgeStatementCollection;
  /// Liste satırı üst etiketi — bugünkü dersler
  String get summaryRowBadgeMyLessons;
  String get packageInfo;
  /// Paket listesi — yalnızca aktif paketler (özetten giriş) başlığı
  String get activePackagesListTitle;
  /// Planlı ödeme listesi — yalnızca gecikenler (özetten giriş) başlığı
  String get overduePaymentsListTitle;
  /// Planlı ödeme listesi — bugün + yakın vade (hatırlatıcı / anasayfa penceresi)
  String get nearDuePaymentsListTitle;
  String get myAttendance;
  String get financialStatement;
  String get lessonSchedule;
  String get guardianInfo;
  String get invoiceInfo;
  String get invoiceRecipientTypeIndividual;
  String get invoiceRecipientTypeCorporate;
  String get invoiceRecipientTypeSoleTrader;
  String get invoiceVkn;
  String get invoiceTckn;
  String get invoiceTaxOffice;
  String get invoiceCompanyTitle;
  String get invoiceDefaultBadge;
  String get scheduledPayments;
  /// Üye profil menüsü kartları — tek satır (ProfileMenuCard `maxLines: 1`).
  String get profileMenuMyPackages;
  String get profileMenuLessonScheduleTitle;
  String get profileMenuPlannedPaymentTitle;
  String get profileMenuStatementTitle;
  String get profileMenuInvoiceInfoTitle;
  String get profileMenuGuardianInfoTitle;
  String get debt;
  String get credit;
  String get balance;
  String get dueDate;
  /// Tablo / kart sütun başlığı (ödeme durumu vb.)
  String get statusLabel;
  String get paidStatus;
  String get unpaidStatus;
  String get overdueStatus;
  String get activeStatus;
  String get expiredStatus;
  String get relationship;
  String get location;
  String get guardianName;
  String get studentInfo;

  // ─── Cari Ekstre ───
  String get saleLabel;
  String get collectionLabel;
  String get packagePrice;
  String get netPrice;
  String get registrationDate;

  // ─── Paket Bilgileri ───
  String get endDate;
  String get unitPrice;
  String get totalPrice;
  String get discountLabel;
  String get packageNameLabel;
  String get quantity;

  // ─── Ödeme Türü Etiketleri ───
  Map<String, String> get paymentTypeLabels;

  String get paymentType;
  String get paidDate;
  String get paidExplanation;

  // ─── Paket Detay (Derse Katılım & İşlem Geçmişi) ───
  String get lessonAttendance;
  String get lesson;
  String get teacher;
  String get classroom;
  String get date;
  String get time;
  String get attendanceStatus;
  String get attended;
  String get notAttended;
  String get burned;
  String get deducted;
  String get notDeducted;
  String get actionLabel;
  String get changeLabel;
  String get remainAfter;
  String get noReservations;
  String get noLogs;
  Map<String, String> get logActionLabels;

  // ─── Üye yoklama geçmişi ───
  String get makeupLesson;
  String get lessonTypeGroupShort;
  String get lessonTypeIndividualShort;
  String get cancelledLesson;
  String get noAttendanceRecords;

  // ─── Yakınlık Derecesi Etiketleri ───
  Map<String, String> get relationshipLabels;

  // ─── Veli Kartı ───
  String get primaryGuardian;
  String get note;
  String get call;
  /// Veli listesi — api-system `secondary_phone`
  String get guardianSecondaryPhone;
  /// Veli listesi — api-system `profession_group` satır başlığı
  String get guardianProfessionGroupField;
  String get guardianProvinceField;
  String get guardianDistrictField;
  String get guardianAddressField;

  /// `MemberGuardianProfessionGroupEnum` API anahtarları (api-system).
  Map<String, String> get guardianProfessionGroupLabels;

  // ─── Meslek Etiketleri ───
  Map<String, String> get professionLabels;

  // ─── Factory ───

  static AppLabels _current = const GymLabels();
  static ApplicationType _currentType = ApplicationType.openGym;
  static SupportedLocale _currentLocale = SupportedLocale.tr;

  static AppLabels get current => _current;
  static SupportedLocale get currentLocale => _currentLocale;
  static ApplicationType get currentAppType => _currentType;

  static void init(ApplicationType type,
      {SupportedLocale locale = SupportedLocale.tr}) {
    _currentType = type;
    _currentLocale = locale;
    _current = _resolve(type, locale);
  }

  static void changeLocale(SupportedLocale locale) {
    _currentLocale = locale;
    _current = _resolve(_currentType, locale);
  }

  static AppLabels _resolve(ApplicationType type, SupportedLocale locale) {
    switch (locale) {
      case SupportedLocale.en:
        return _resolveEn(type);
      case SupportedLocale.tr:
        return _resolveTr(type);
    }
  }

  static AppLabels _resolveTr(ApplicationType type) {
    switch (type) {
      case ApplicationType.muzikOkulum:
        return const MusicSchoolLabels();
      case ApplicationType.swimmingCourse:
        return const SwimmingCourseLabels();
      default:
        return const GymLabels();
    }
  }

  static AppLabels _resolveEn(ApplicationType type) {
    switch (type) {
      case ApplicationType.muzikOkulum:
        return const MusicSchoolLabelsEn();
      case ApplicationType.swimmingCourse:
        return const SwimmingCourseLabelsEn();
      default:
        return const GymLabelsEn();
    }
  }

  static AppLabels of(BuildContext context) => _current;
}

// ─────────────────────────────────────────────────────────────
// GymLabels (varsayılan)
// ─────────────────────────────────────────────────────────────

class GymLabels implements AppLabels {
  const GymLabels();

  // Roller
  @override String get member => 'Üye';
  @override String get trainer => 'Eğitmen';
  @override String get moderator => 'Yönetici';
  @override String get admin => 'Admin';

  // Panel Modüller
  @override String get groupLesson => 'Grup Dersi';
  @override String get quickReservation => 'Hızlı Randevu';
  @override String get personalTraining => 'PT';
  @override String get reservation => 'Rezervasyon';
  @override String get calendar => 'Takvim';
  @override String get fitnessProgram => 'Fitness Programı';
  @override String get bodyMeasurement => 'Vücut Ölçümü';
  @override String get diet => 'Diyet';
  @override String get memberCard => 'Üye Kartı';
  @override String get reports => 'Raporlar';
  @override String get qrScan => 'QR Okut';
  @override String get employees => 'Personel';
  @override String get locations => 'Lokasyonlar';
  @override String get enrollment => 'Öğrenci Kayıt';
  @override String get movementCatalog => 'Hareket Kataloğu';

  // Admin Modüller
  @override String get members => 'Üyeler';
  @override String get packageSale => 'Paket Satış';
  @override String get payment => 'Ödeme';
  @override String get expense => 'Gider';
  @override String get sms => 'SMS';
  @override String get announcement => 'Duyurular';
  @override String get dashboard => 'Dashboard';
  @override String get settings => 'Ayarlar';
  @override String get abilityManagement => 'Yetki Yönetimi';

  // Navigasyon
  @override String get home => 'Anasayfa';
  @override String get profile => 'Profil';
  @override String get qrCode => 'QR Kod';
  @override String get account => 'Hesap';
  @override String get shop => 'Mağaza';

  // Genel Eylemler
  @override String get save => 'Kaydet';
  @override String get saving => 'Kaydediliyor...';
  @override String get cancel => 'İptal';
  @override String get delete => 'Sil';
  @override String get edit => 'Düzenle';
  @override String get add => 'Ekle';
  @override String get search => 'Ara';
  @override String get selectCountry => 'Ülke Seçin';
  @override String get list => 'Liste';
  @override String get detail => 'Detay';
  @override String get confirm => 'Onayla';
  @override String get approve => 'Onaylıyorum';
  @override String get close => 'Kapat';
  @override String get update => 'Güncelle';
  @override String get yes => 'Evet';
  @override String get no => 'Hayır';
  @override String get send => 'Gönder';
  @override String get selectFromContacts => 'Rehberden Seç';
  @override String get selectFile => 'Dosya Seç';
  @override String get takePhoto => 'Fotoğraf Çek';
  @override String get chooseFromGallery => 'Galeriden Seç';
  @override String get deletePhoto => 'Fotoğrafı Sil';
  @override String get photoUpdated => 'Fotoğraf güncellendi.';
  @override String get photoDeleted => 'Fotoğraf silindi.';
  @override String get photoUpdateFailed => 'Fotoğraf güncellenirken bir hata oluştu.';
  @override String get previous => 'Önceki';
  @override String get next => 'Sonraki';

  // Yoklama / Hak Düşüm
  @override String get attendance => 'Yoklama';
  @override String get attendanceDescription =>
      'QR kod veya kart numarası ile üyeyi bularak yoklama alabilirsiniz.';
  @override String get attendanceScanQr => 'QR Kod Tara';
  @override String get scanMemberQr => 'Üye QR kodunu okutun';
  @override String get cardNumber => 'Kart Numarası';
  @override String get enterCardNumber => '10 haneli kart numarasını giriniz';
  @override String get searchMember => 'Üye Ara';
  @override String get cardNumberInvalid => 'Kart numarası 10 haneli olmalıdır';
  @override String get invalidOrExpiredQr => 'Geçersiz veya süresi dolmuş QR kod';
  @override String get memberNotFoundByCard => 'Bu karta kayıtlı üye bulunamadı';
  @override String get noActivePackage => 'Aktif paketi bulunmuyor';
  @override String get burnConfirm =>
      'Bu ders için katılımı onaylamak istiyor musunuz?';
  @override String get burnSuccess =>
      'Yoklama kaydı alındı ve paket düşümü yapıldı.';
  @override String get burnError => 'Paket düşümü sırasında hata oluştu';
  @override String get scanNewMember => 'Yeni Üye Ara';
  @override String get activePackages => 'Aktif Paketler';
  @override String get packageDeductions => 'Paket Düşümleri';
  @override String get undoDeduction => 'Geri Al';
  @override String get undoDeductionConfirm => 'Paket düşümünü geri almak istediğinize emin misiniz?';
  @override String get undoDeductionSuccess =>
      'Yoklama kaydı ve paket düşümü başarıyla geri alındı.';
  @override String get undoDeductionError => 'Paket düşümü geri alınırken hata oluştu';
  @override String get noDeductionHistory => 'Veri Bulunamadı';
  @override String get onlyTodayCanUndo => 'Sadece bugünkü kayıtlar geri alınabilir';
  @override String get attendanceSelectLessonTitle => 'Hangi derse katılım kaydedilsin?';
  @override String get attendanceNoLessonsToday =>
      'Bugün takviminizde grup dersi yok; önce ders programından ders ekleyin veya tarihi kontrol edin.';
  @override String get scheduleTakeAttendanceFab => 'Yoklama al';
  @override String get attendancePresetLessonHeading =>
      'Bu yoklamanın bağlı olduğu ders';
  @override String get attendancePresetLessonSectionHint =>
      'Üyeyi QR veya kart ile bulduğunuzda hak düşümü bu grup dersine yazılır.';
  @override String get attendanceLessonCardShowMore => 'Devamını görüntüle';
  @override String get attendanceLessonCardShowLess => 'Daha az göster';

  // Durum
  @override String get loading => 'Yükleniyor...';
  @override String get noData => 'Veri Bulunamadı';
  @override String get error => 'Hata';
  @override String get success => 'Başarılı';
  @override String get remainingRights => 'Kalan Hak';
  @override String get burnRight => 'Hak Düş';
  @override String get refundRight => 'Hak İade';
  @override String get noAccessPermission => 'Bu özelliğe erişim yetkiniz bulunmamaktadır.';

  // Giriş / Doğrulama
  @override String get verificationCode => 'Doğrulama Kodu';
  @override String get enterVerificationCode => 'Doğrulama Kodunu Giriniz';
  @override String get verificationCodeHint => '6 haneli doğrulama kodunu giriniz...';
  @override String get verificationCodeError => 'Doğrulama kodu hatalı, lütfen gelen doğrulama kodunu kontrol ediniz.';
  @override String get serverUnreachable => 'Sunucuya ulaşılamıyor, lütfen daha sonra tekrar deneyiniz.';
  @override String get codeValidating => 'Kod Doğrulanıyor';
  @override String get login => 'Giriş Yap';
  @override String get logout => 'Çıkış Yap';
  @override String get logoutConfirm => 'Uygulamadan çıkış yapmak istediğinize emin misiniz';
  @override String get kvkkTitle => 'KVKK Aydınlatma Metni';
  @override String get kvkkApprovalRequired => 'Giriş yapmak için KVKK onayı gereklidir.';
  @override String get kvkkRead => 'KVKK aydınlatma metnini okudum.';
  @override String get kvkkLoadError => 'KVKK metni yüklenemedi.';

  // Splash / Karşılama
  @override String get welcome => 'Hoş Geldiniz';
  @override String get goodMorning => 'Günaydın!';
  @override String get goodAfternoon => 'İyi Günler!';
  @override String get goodEvening => 'İyi Akşamlar!';
  @override String get goodNight => 'İyi Geceler!';

  // Anasayfa (Explore)
  @override String get quickAccess => 'Hızlı Erişim';
  @override String get remainingDays => 'Kalan Gün Sayısı';
  @override String get noActiveMembership => 'Aktif Fitness Üyeliğiniz Bulunmamaktadır';
  @override String get membershipFrozen => '(Üyelik Donduruldu)';
  @override String get facilityOccupancy => 'Tesis Doluluk Oranı';
  @override String get noOccupancyData => 'Doluluk Bilgisi Yok';
  @override String get detailedView => 'Detaylı İncele';
  @override String get fullList => 'Tüm Liste';
  @override String get featureNotActive => 'Bu özellik şuanda aktif değil';
  @override String get accountPassiveWarning => 'Hesabınız pasif durumda, bu özelliği kullanamazsınız.';
  @override String get accountPassiveProfileWarning => 'Hesabınız pasif durumda, profil bilgilerinizi güncelleyemezsiniz.';

  // Geçiş / Turnstile
  @override String get entryIn => 'Giriş';
  @override String get entryOut => 'Çıkış';

  // Tesis
  @override String get facilityInfo => 'Tesis Bilgileri';
  @override String get photo => 'Fotoğraf';
  @override String get contactInfo => 'İletişim Bilgileri';
  @override String get phoneLabel => 'Telefon';
  @override String get emailLabel => 'E-posta';
  @override String get whatsappLabel => 'WhatsApp';
  @override String get addressLabel => 'Adres';
  @override String get openInMaps => 'Haritada Aç';
  @override String get sendWhatsApp => 'WhatsApp Gönder';
  @override String get callPhone => 'Ara';
  @override String get sendEmail => 'E-posta Gönder';

  // Profil Menü
  @override String get myProfile => 'Profilim';
  @override String get paymentHistory => 'Ödeme Geçmişi';
  @override String get pastEntryHistory => 'Geçmiş Geçiş Bilgilerim';
  @override String get facilityDetails => 'Tesis Detayları';
  @override String get trainerRoster => 'Eğitmen Kadrosu';
  @override String get suggestionComplaint => 'Öneriler';
  @override String get groupLessonRules => 'Grup Dersi Kuralları';
  @override String get quickReservationRules => 'Hızlı Randevu Kuralları';
  @override String get facilityRules => 'Tesis Kuralları';
  @override String get membershipRules => 'Üyelik Kuralları';
  @override String get institutionRules => 'Kurum Kuralları';
  @override String get about => 'Hakkında';

  // Hızlı Erişim Grid
  @override String get inviteFriend => 'Arkadaşını\nDavet Et';
  @override String get virtualWallet => 'Sanal\nCüzdan';
  @override String get earnAsYouSpend => 'Harcadıkça\nKazan';
  @override String get exerciseList => 'Egzersiz\nListem';
  @override String get measurementInfo => 'Ölçüm\nBilgilerim';
  @override String get nutritionInfo => 'Beslenme\nBilgilerim';
  @override String get groupLessons => 'Grup\nDersleri';

  // Paket / Abonelik
  @override String get subscriptionInfo => 'Abonelik Bilgileri';
  @override String get purchasedBranchPackages => 'Satın Alınan Branş Paketleri';
  @override String get purchasedPtPackages => 'Satın Alınan PT Paketleri';
  @override String get massagePackages => 'Masaj Paketlerim';
  @override String get contractNo => 'Sözleşme No';
  @override String get startDate => 'Başlangıç';
  @override String get discount => 'İndirim';
  @override String get selectTrainer => 'Eğitmen Seçin';
  @override String get appointmentDateTime => 'Randevu Günü & Saati';
  @override String get createAppointment => 'Randevu Oluştur';
  @override String get myAppointments => 'Randevularım';
  @override String get cancelAppointment => 'Randevuyu İptal Et';
  @override String get cancelled => 'İptal Edildi';
  @override String get appointmentCreatedSuccess => 'Randevu başarıyla oluşturuldu';
  @override String get appointmentNotFound => 'Randevu planı bulunamadı.';

  // Ödeme
  @override String get paymentSummary => 'Ödeme Özeti';
  @override String get amount => 'Tutar';
  @override String get totalPaid => 'Toplam Ödenen';
  @override String get remaining => 'Kalan';
  @override String get myPayments => 'Ödediklerim';
  @override String get upcomingPeriod => 'Gelecek Dönem';
  @override String get makePayment => 'Ödeme Yap';

  // Grup Dersi
  @override String get groupLessonDetail => 'Grup Ders Detayı';
  @override String get person => 'Kişi';
  @override String get minParticipation => 'Min Katılım';
  @override String get opening => 'Açılış';
  @override String get fee => 'Ücret';
  @override String get paid => 'Ücretli';
  @override String get free => 'Ücretsiz';
  @override String get registrationAuth => 'Kayıt Yetkisi';
  @override String get purchasedMembers => 'Dersi satın alanlar';
  @override String get day => 'Gün';
  @override String get registered => 'Kayıt Yapıldı';
  @override String get registrationAvailable => 'Kayıt Yapılabilir';
  @override String get reservationOnLessonDay => 'Rezervasyon ders günü yapılır.';
  @override String scheduleListHeaderForDate(String formattedDate) =>
      '$formattedDate Grup Dersi Listesi';
  @override String get groupLessonScheduleLessonTimeLabel => 'Ders Saati';
  @override String get groupLessonScheduleCapacityLabel => 'Kontenjan';

  // Ölçüm
  @override String get myMeasurements => 'Ölçümlerim';
  @override String get measurementDetail => 'Ölçüm Detayı';
  @override String get addMeasurement => 'Ölçüm Ekle';
  @override String get deleteMeasurement => 'Ölçümü Sil';
  @override String get deleteMeasurementConfirm => 'Ölçümü silmek istediğinize emin misiniz?';
  @override String get measurementDeletedSuccess => 'Ölçüm kaydı başarıyla silindi.';
  @override String get noMeasurementData => 'Ölçüm kaydında görüntülenecek veri bulunmamaktadır.';
  @override String get pdfFiles => 'PDF Dosyaları';
  @override String get images => 'Görseller';
  @override String get weight => 'Kilo';
  @override String get arm => 'Kol';
  @override String get shoulder => 'Omuz';
  @override String get height => 'Boy';
  @override String get chest => 'Göğüs';
  @override String get abdomen => 'Karın';
  @override String get fieldRequired => 'alanı boş olamaz';

  // Fitness / Egzersiz
  @override String get exerciseExecution => 'Egzersizin Yapılışı';
  @override String get exerciseDone => 'Hareketi Yaptım';
  @override String get videoNotAvailable => 'Video yüklenemedi';
  @override String get videoAvailable => 'Video mevcut';
  @override String get movement => 'hareket';

  // Dolap
  @override String get closetList => 'Dolap Listesi';
  @override String get emptyElectronicCloset => 'Boş Elektronik Dolap';
  @override String get closetPassword => 'Dolap Şifresi';

  // Öneri
  @override String get suggestionComplaintHistory => 'Öneri Geçmişi';
  @override String get createSuggestionComplaint => 'Öneri Oluştur';
  @override String get title => 'Başlık';
  @override String get topicTitle => 'Konu Başlığını Yazınız...';
  @override String get suggestionAndComplaint => 'Öneriniz';
  @override String get writeSuggestionComplaint => 'Önerilerinizi Yazınız...';
  @override String get sentSuccess => 'Başarıyla gönderildi';
  @override String get sendFailed => 'Gönderim başarısız, lütfen daha sonra tekrar deneyiniz.';
  @override String get fillAllFields => 'Lütfen tüm alanları doldurunuz';
  @override String get viewSuggestionComplaint => 'Öneri Görüntüle';
  @override String get submitting => 'Gönderiliyor...';
  @override String get currencySuffix => ' ₺';

  // Davet
  @override String get inviteFriendTitle => 'Arkadaşını Davet Et';
  @override String get enterFriendInfo => 'Davet Etmek İstediğiniz Arkadaşınızın Bilgilerini Giriniz';
  @override String get inviteSentSuccess => 'Davet başarıyla gönderildi.';
  @override String get contactPermissionRequired => 'Rehbere erişim izni gereklidir.';
  @override String get contactPickError => 'Rehberden kişi seçilirken bir hata oluştu.';
  @override String get fillRequiredFieldsAndPhone => 'Lütfen tüm zorunlu alanları doldurunuz ve geçerli bir telefon numarası giriniz.';
  @override String get retry => 'Tekrarla';
  @override String get inviteKvkkConsentPrefix => 'Davet kapsamında kullanıcı tarafından girilen telefon numarası; davet süreçlerinin yürütülmesi, davet durumlarının takibi ve davete ilişkin bilgilendirme yapılması amaçlarıyla işlenmektedir. İlgili numaraya, mevzuata uygun şekilde ve yalnızca davet amacıyla sınırlı sayıda ileti gönderilebilir. Kullanıcı, paylaştığı iletişim bilgilerinin ilgili kişiye ait olduğunu ve bu paylaşım için gerekli yetkiye sahip olduğunu kabul eder. Detaylı bilgi için ';
  @override String get inviteKvkkConsentSuffix => '\'ni inceleyiniz.';

  // Sanal Cüzdan / Harcadıkça Kazan
  @override String get transactionHistory => 'İşlem Geçmişi';
  @override String get balanceLoad => 'Bakiye Yükleme';
  @override String get spending => 'Harcama';
  @override String get usablePoints => 'Kullanılabilir Puan';
  @override String get convertAndSpendPoints => 'Puanları Dönüştür ve Harca';
  @override String get transaction => 'İşlem';
  @override String get earnedPoints => 'Kazanılan Puan';
  @override String get orderNo => 'Sipariş No';
  @override String get description => 'Açıklama';

  // Mağaza (GymExxtra)
  @override String get packageSelection => 'Paket Seçimi Yapınız';
  @override String get selectPackage => 'Paket Seçiniz';
  @override String get selectedPackage => 'Seçili Paket';
  @override String get orderHistory => 'Sipariş Geçmişi';
  @override String get orderSummary => 'Sipariş Özeti';
  @override String get productAmount => 'Ürün Tutarı';
  @override String get discountAmount => 'İndirim';
  @override String get payableAmount => 'Ödenecek Tutar';
  @override String get orderDate => 'Sipariş Tarihi';
  @override String get purchase => 'Satın Al';
  @override String get enterCouponCode => 'Varsa kupon kodunuzu giriniz';
  @override String get couponApplied => 'Kupon başarıyla uygulandı.';
  @override String get invalidCoupon => 'Geçersiz kupon kodu.';
  @override String get cartError => 'Sepet bilgisi alınamadı.';
  @override String get branchInfoError => 'Şube bilgisi alınamadı.';
  @override String get paymentPageError => 'Ödeme sayfası açılamadı.';
  @override String get cartOperationFailed => 'Sepet işlemi başarısız oldu.';

  // QR
  @override String get qrCodeGenerating => 'QR Kod Oluşturuluyor';
  @override String get screenBrightness => 'Ekran Parlaklığı';
  @override String get scanQrCode => 'QR Kodu Okutunuz';
  @override String get renewQrCode => 'QR Kodu Yenileyiniz';
  @override String get refreshCode => 'Kodu Yenile';
  @override String get tryAgain => 'Tekrar Dene';
  @override String get qrCodeCreateFailed => 'QR kod oluşturulamadı';
  @override String get configNotFound => 'Yapılandırma bilgisi bulunamadı';
  @override String get securityCodeServiceUnavailable => 'Güvenlik kodu oluşturma servisine ulaşılamıyor';

  // Üye QR Kontrol Mesajları
  @override String get overduePaymentWarning => 'Vadesi geçmiş ödemeniz bulunmaktadır, lütfen ödemenizi yapınız.';
  @override String get debtExistsWarning => 'Bakiyeniz bulunmaktadır, lütfen ödemenizi yapınız.';
  @override String get membershipFrozenWarning => 'Üyeliğiniz dondurulmuştur. Tesise giriş çıkış yapamazsınız.';
  @override String get noActivePackageWarning => 'Aktif bir paketiniz bulunmamaktadır.';
  @override String get outsideEntryHoursWarning => 'Giriş saatiniz dışındasınız. Lütfen resepsiyon ile görüşünüz.';

  // Profil Düzenleme
  @override String get fullName => 'Adı Soyadı';
  @override String get phoneNumber => 'Telefon Numarası';
  @override String get email => 'E-posta';
  @override String get gender => 'Cinsiyet';
  @override String get male => 'ERKEK';
  @override String get female => 'KADIN';
  @override String get birthDate => 'Doğum Tarihi';
  @override String get birthDateFormat => 'GG/AA/YYYY';
  @override String get birthDateFormatDash => birthDateFormat;
  @override String get notificationsEnabled => 'Bildirimleri Almak İstiyorum';
  @override String get selectFromGallery => 'Galeriden Seç';
  @override String get takeFromCamera => 'Kameradan Çek';
  @override String get photoProcessing => 'Fotoğraf işleniyor...';
  @override String get photoDeleting => 'Fotoğraf siliniyor...';
  @override String get mayTakeSeconds => '10 sn. kadar sürebilir';
  @override String get lockerPassword => 'Dolap Şifresi';
  @override String get confirmEmail => 'Emaili Onayla';
  @override String get emailVerified => 'E-posta doğrulandı';
  @override String get emailNotVerified => 'E-posta doğrulanmadı';
  @override String get sendVerification => 'Doğrula';
  @override String get verificationSent => 'Gönderildi';
  @override String get emailVerificationSent => 'E-posta doğrulama bağlantısı gönderildi. Lütfen e-posta kutunuzu kontrol ediniz.';
  @override String get emailVerificationFailed => 'E-posta doğrulama bağlantısı gönderilirken bir hata oluştu. Lütfen tekrar deneyiniz.';
  @override String get changePassword => 'Şifre Değiştir';
  @override String get currentPassword => 'Mevcut Şifre';
  @override String get newPassword => 'Yeni Şifre';
  @override String get newPasswordConfirm => 'Yeni Şifre (Tekrar)';
  @override String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır.';
  @override String get passwordMismatch => 'Yeni şifreler eşleşmiyor.';
  @override String get passwordSameAsOld => 'Yeni şifre mevcut şifreden farklı olmalıdır.';
  @override String get currentPasswordWrong => 'Mevcut şifre hatalı.';
  @override String get passwordChangeSuccess => 'Şifreniz başarıyla değiştirildi.';
  @override String get passwordChangeFailed => 'Şifre değiştirilirken bir hata oluştu.';
  @override String get changePhone => 'Telefon Numarasını Değiştir';
  @override String get newPhone => 'Yeni Telefon Numarası';
  @override String get phoneChecking => 'Kontrol ediliyor...';
  @override String get phoneAvailable => 'Bu telefon numarası kullanıma uygundur.';
  @override String get phoneTaken => 'Bu telefon numarası sistemde kayıtlıdır.';
  @override String get phoneSameAsCurrent => 'Girilen numara mevcut numara ile aynıdır.';
  @override String get invalidPhoneFormat => 'Geçerli bir telefon numarası giriniz.';
  @override String get phoneCheckError => 'Kontrol sırasında bir hata oluştu.';
  @override String get phoneChangeSuccess => 'Telefon numarası başarıyla güncellendi.';
  @override String get phoneChangeFailed => 'Telefon güncellenirken bir hata oluştu.';
  @override String get changeEmail => 'E-postayı Değiştir';
  @override String get newEmail => 'Yeni E-posta Adresi';
  @override String get emailChecking => 'Kontrol ediliyor...';
  @override String get emailAvailable => 'Bu e-posta adresi kullanıma uygundur.';
  @override String get emailTaken => 'Bu e-posta adresi sistemde kayıtlıdır.';
  @override String get emailSameAsCurrent => 'Girilen e-posta mevcut adresle aynıdır.';
  @override String get invalidEmailFormat => 'Geçerli bir e-posta adresi giriniz.';
  @override String get emailCheckError => 'Kontrol sırasında bir hata oluştu.';
  @override String get emailChangeSuccess => 'E-posta adresi başarıyla güncellendi.';
  @override String get emailChangeFailed => 'E-posta güncellenirken bir hata oluştu.';
  @override String get profileUpdateSuccess => 'Bilgileriniz başarıyla güncellendi.';
  @override String get profileUpdateFailed => 'Bilgileriniz güncellenirken bir hata oluştu. Lütfen tekrar deneyiniz.';
  @override String get sessionNotFoundReLogin => 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapınız.';
  @override String get apiConnectionNotFound => 'API bağlantı bilgisi bulunamadı.';

  // Dil Seçimi
  @override String get language => 'Dil';
  @override String get languageTurkish => 'Türkçe';
  @override String get languageEnglish => 'English';

  // Trainer Home
  @override String get todayProgram => 'Bugünün Programı';
  @override String get todayGroupLessons => 'Bugünkü Grup Dersleri';
  @override String get todayQuickReservations => 'Bugünkü Hızlı Randevular';
  @override String get trainerTodayDashboardQuickReservationSectionTitle =>
      todayQuickReservations;
  @override String get todayPtReservations => 'Bugünkü PT Randevuları';
  @override String get recentTransactions => 'Son İşlemler';
  @override String get noRecentTransactions => 'Henüz işlem bulunmuyor';
  @override String get reservationDetail => 'Randevu Detayı';
  @override String get lessonCount => 'ders';
  @override String get personCount => 'kişi';

  // Trainer Profil
  @override String get biography => 'Hakkımda';
  @override String get biographyHint => 'Kendinizden kısaca bahsedin...';
  @override String get expertise => 'Uzmanlık';
  @override String get selectExpertise => 'Uzmanlık alanlarınızı seçin';
  @override String get colorLabel => 'Renk';
  @override String get selectColor => 'Renk seçin';
  @override String get removeColor => 'Rengi Kaldır';

  // İnternet / Oturum
  @override String get noInternetConnection => 'İnternet Bağlantısı Yok';
  @override String get checkInternetAndTryAgain => 'İnternet bağlantınızı kontrol edip\ntekrar deneyiniz.';
  @override String get checkInternetConnection => 'Lütfen internet bağlantınızı\nkontrol ediniz.';
  @override String get sessionExpired => 'Oturum süresi dolmuştur';
  @override String get sessionExpiredReGetCode => 'Oturum süresi dolmuştur, lütfen yeni doğrulama kodu alınız.';
  @override String get sessionOpenedOnAnotherDevice => 'Başka bir cihazda oturum açıldı';
  @override String get sessionOpenedOnAnotherDeviceReLogin => 'Başka bir cihazda oturum açıldı. Lütfen yeniden giriş yapınız.';

  // Genel Hata
  @override String get errorOccurred => 'Bir hata oluştu';
  @override String get fieldCannotBeEmpty => 'alanı boş olamaz';
  @override String get urlCouldNotOpen => 'URL açılamadı';
  @override String get fileUrlNotFound => 'Dosya URL\'si bulunamadı.';
  @override String get fileCouldNotOpen => 'Dosya açılamadı.';
  @override String get fileDownloadError => 'Dosya indirilirken bir hata oluştu.';

  // Gün İsimleri
  @override String get monday => 'Pazartesi';
  @override String get tuesday => 'Salı';
  @override String get wednesday => 'Çarşamba';
  @override String get thursday => 'Perşembe';
  @override String get friday => 'Cuma';
  @override String get saturday => 'Cumartesi';
  @override String get sunday => 'Pazar';

  // Filtre
  @override String get all => 'Tümü';

  // Eğitmen Değerlendirme
  @override String get rateTrainer => 'Değerlendir';
  @override String get selectStarRating => 'Değerlendirme İçin Yıldız Derecenizi Seçiniz';
  @override String get rate => 'Değerlendir';
  @override String get rating => 'Derecelendirme';

  // Duyurular
  @override String get announcementsAndNotifications => 'Duyurular / Bildirimler';
  @override String get announcementNotFound => 'Duyuru bulunamadı';

  // Uygulama Güncelleme
  @override String get newVersionAvailable => 'Yeni bir sürüm mevcut. Uygulamayı güncellemek ister misiniz?';

  // Müzik Okulu / Genel Panel
  @override String get todayMyLessons => 'Bugünkü\nDerslerim';
  @override String get todayMyPayments => 'Bugünkü\nÖdemelerim';
  @override String get todayMyAttendances => 'Bugünkü\nYoklamalarım';
  @override String get myActivePackages => 'Aktif\nPaketlerim';
  @override String get todaySummaryTitle => 'Bugünün\nÖzeti';
  @override String get trainerHomeTodayAttendanceTitle => 'Bugünkü\nYoklamalarım';
  @override String get trainerQuickAccessAttendanceByQrTitle => 'QR ile\nYoklama';
  @override String get trainerScheduleAddLessonTitle => 'Ders ekle';
  @override String get trainerScheduleEditLessonTitle => 'Dersi düzenle';
  @override String get trainerScheduleEditLessonDaysHint =>
      'Bu planın ders günü sabittir; saat, süre ve diğer alanları güncelleyebilirsiniz.';
  @override String get trainerScheduleLoadLessonFailed => 'Ders bilgileri yüklenemedi';
  @override String get trainerScheduleDeleteLessonConfirm =>
      'Bu dersi silmek istiyor musunuz?';
  @override String get trainerScheduleLessonDeleted => 'Ders silindi';
  @override String get trainerScheduleDeleteLessonFailed => 'Ders silinemedi';
  @override String get trainerScheduleLessonNameLabel => 'Ders';
  @override String get trainerScheduleServiceTypeLabel => 'Ders türü';
  @override String get trainerScheduleWeekdayLabel => 'Ders günü';
  @override String get trainerScheduleStartTimeLabel => 'Başlangıç saati';
  @override String get trainerScheduleStartTimeHint => 'SS:DD (ör. 09:00)';
  @override String get trainerScheduleDurationLabel => 'Süre (saat)';
  @override String get trainerSchedulePeriodLabel => 'Tekrar';
  @override String get trainerSchedulePeriodWeekly => 'Haftalık';
  @override String get trainerSchedulePeriodOneTime => 'Tek seferlik';
  @override String get trainerSchedulePersonLimitLabel => 'Kontenjan';
  @override String get trainerScheduleTrackPaymentLabel =>
      'Paket / hak takibi (ücretli ders)';
  @override String get trainerScheduleTrainerFixedHint =>
      'Eğitmen olarak yalnızca kendi adınıza plan oluşturabilirsiniz.';
  @override String get trainerScheduleNoLocationOption => 'Lokasyon yok';
  @override String get trainerScheduleLessonSaved => 'Ders planı kaydedildi';
  @override String get trainerScheduleLessonSaveFailed => 'Ders planı kaydedilemedi';
  @override String get trainerScheduleLoadFormFailed => 'Form verileri yüklenemedi';
  @override String get trainerScheduleSelectService => 'Ders türü seçin';
  @override String get trainerScheduleSectionEssentials => 'Temel bilgiler';
  @override String get trainerScheduleSectionSchedule => 'Gün ve süre';
  @override String get trainerScheduleSectionLimits => 'Kontenjan';
  @override String get trainerScheduleSectionMore => 'Konum ve notlar';
  @override String get trainerScheduleTrackPaymentSubtitle =>
      'Açıkken ders, üye paketinden ücretli / hak düşümü olarak işlenir.';
  @override String get trainerScheduleLessonDaysLabel => 'Ders günleri';
  @override String get trainerScheduleLessonDaysHint =>
      'Birden fazla gün seçebilirsiniz; her gün için ayrı plan oluşturulur. Günlerin saat ve süreleri farklı olabilir.';
  @override String get trainerScheduleDayTimeSlotsTitle =>
      'Seçili günlere göre saat ve süre';
  @override String get trainerScheduleDayStartTimeShortLabel => 'Saat';
  @override String get trainerSchedulePickTimeTooltip => 'Saat seç';
  @override String get trainerSchedulePickTimeFieldHint => 'Seçmek için dokunun';
  @override String get trainerScheduleSelectAtLeastOneDay =>
      'En az bir ders günü seçin';
  @override String trainerScheduleLessonsSaveResult(int saved, int failed) {
    if (failed == 0) {
      return saved == 1
          ? 'Ders planı kaydedildi'
          : '$saved ders planı kaydedildi';
    }
    if (saved == 0) {
      return failed == 1
          ? 'Ders planı kaydedilemedi'
          : '$failed ders planı kaydedilemedi';
    }
    return '$saved ders planı kaydedildi, $failed kaydedilemedi';
  }

  @override String get homeSummarySectionTitle => 'Özet';
  @override String get homeSummaryActivePackagesLabel => 'Aktif Paket';
  @override String get homeSummaryRemainingRightsLabel => 'Kalan Toplam Hak';
  @override String get homeSummaryThisWeekLessonsLabel => 'Ders Sayısı';
  @override String get homeSummaryThisWeekLessonsCaption =>
      'Bu Haftaki Ders Sayısı';
  @override String get homeSummaryOverduePaymentsLabel => 'G. Ödeme';
  @override String get homeSummaryOverduePaymentsCaption =>
      'Geciken Ödeme Sayısı';
  @override String get homeSummaryNextLessonLabel =>
      'Bir Sonraki Ders/Derslerim';
  @override String get homeSummaryNextLessonEmpty => 'Yaklaşan ders yok';
  @override String get homeSummaryRecentAttendanceTitle => 'Son Yoklamalar';
  @override String get homeSummaryShowMore => 'Daha fazla göster';
  @override String get homeSummaryShowLess => 'Daha az göster';
  @override String get homePackageRightsDonutTitle => 'Paketlerim';
  @override String get homePackageRightsDonutRemainingLegend => 'Kalan';
  @override String get homePackageRightsDonutUsedLegend => 'Kullanılan';
  @override String get homePackageRightsDonutEmptyStateLine =>
      'Ders hakkı bulunan aktif paketiniz yok';
  @override String get homePackageNearExpiryWarning =>
      'Paketiniz bitmek üzere';
  @override String get nearExpiryPackagesListTitle => 'Yakında bitecek paketler';
  @override String get homeRemindersSectionTitle => 'Hatırlatıcı';
  @override String get homeRemindersEmptyState =>
      'Yaklaşan Ödeme veya Duyuru Bulunmuyor.';
  @override String get homeRemindersSeeAll => 'Tümünü gör';
  @override String get homeReminderPaymentDueToday => 'Bugün';
  @override String get homeReminderPaymentDueTomorrow => 'Yarın';
  @override String homeReminderPaymentDueInDays(int days) => '$days gün sonra';
  @override String get homeRemindersUpcomingPaymentsSubtitle =>
      'Yaklaşan Ödemeler';
  @override String get homeRemindersAnnouncementsSubtitle => 'Duyurular';
  @override String get homeStatementChartTitle => 'Cari Özeti';
  @override String get homeStatementChartSubtitle =>
      'Son 6 ay — aylık satış ve tahsilat';
  @override String get homeStatementChartEmpty =>
      'Bu dönemde grafiklenecek hareket yok';
  @override String get homeStatementChartNoDebtLine =>
      'Borcunuz bulunmamaktadır';
  @override String get summaryHintShort =>
      'Paket, Tahsilat, Yoklama, Planlı Ödeme Ve Bugünkü Derslerin Özeti.';
  @override String get summaryRowActivePackages => 'Aktif paketler';
  @override String get summaryRowLessonsToday => 'Bugünkü dersler';
  @override String get summaryRowPlannedPayments => 'Planlı ödemeler (bugün)';
  @override String get summaryRowPackageRegistrationsToday =>
      'Bugünkü paket kayıtları';
  @override String get summaryRowCollectionsToday => 'Bugünkü tahsilatlar';
  @override String get summaryRowAttendanceToday => 'Bugünkü yoklama';
  @override String get summaryValueNone => '—';
  @override String get summaryTransactions => 'işlem';
  @override String get summaryAttendanceRecords => 'kayıt';
  @override String get summaryNoActivityToday =>
      'Bugün Listelenecek Bir İşlem Yok.';
  @override String get summaryUnitLesson => 'Ders';
  @override String get summaryUnitPlannedPayment => 'Planlı Ödeme';
  @override String get summaryUnitPackageSale => 'Paket Kaydı';
  @override String get summaryUnitCollection => 'Tahsilat';
  @override String get summaryUnitStatementMovements => 'Cari Ekstre Hareketi';
  @override String get summaryUnitAttendance => 'Yoklama';
  @override String get summaryPopupFootnotePlannedAndStatement =>
      'Planlı Ödemeler Ve Cari Ekstreden Bugünkü Satış/Tahsilat Satırları Aşağıda Listelenir.';
  @override String get summaryRowBadgePlannedPayment => 'Planlı Ödeme';
  @override String get summaryRowBadgeStatementMovement => 'Cari Ekstre';
  @override String get summaryRowBadgeStatementSale => 'Satış';
  @override String get summaryRowBadgeStatementCollection => 'Tahsilat';
  @override String get summaryRowBadgeMyLessons => 'Derslerim';
  @override String get packageInfo => 'Paket\nBilgileri';
  @override String get activePackagesListTitle => 'Aktif Paketler';
  @override String get overduePaymentsListTitle => 'Geciken Ödemeler';
  @override String get nearDuePaymentsListTitle => 'Yaklaşan Ödemeler';
  @override String get myAttendance => 'Yoklamalar';
  @override String get financialStatement => 'Cari\nEkstre';
  @override String get lessonSchedule => 'Ders\nProgramı';
  @override String get guardianInfo => 'Veli\nBilgisi';
  @override String get invoiceInfo => 'Fatura\nBilgisi';
  @override String get invoiceRecipientTypeIndividual => 'Bireysel';
  @override String get invoiceRecipientTypeCorporate => 'Kurumsal';
  @override String get invoiceRecipientTypeSoleTrader => 'Şahıs Şirketi';
  @override String get invoiceVkn => 'VKN';
  @override String get invoiceTckn => 'TCKN';
  @override String get invoiceTaxOffice => 'Vergi Dairesi';
  @override String get invoiceCompanyTitle => 'Firma Unvanı';
  @override String get invoiceDefaultBadge => 'Varsayılan';
  @override String get scheduledPayments => 'Planlı\nÖdeme';
  @override String get profileMenuMyPackages => 'Paketlerim';
  @override String get profileMenuLessonScheduleTitle => 'Ders programı';
  @override String get profileMenuPlannedPaymentTitle => 'Planlı Ödeme';
  @override String get profileMenuStatementTitle => 'Cari Ekstre';
  @override String get profileMenuInvoiceInfoTitle => 'Fatura Bilgileri';
  @override String get profileMenuGuardianInfoTitle => 'Veli Bilgisi';
  @override String get debt => 'Borç';
  @override String get credit => 'Alacak';
  @override String get balance => 'Bakiye';
  @override String get dueDate => 'Vade Tarihi';
  @override String get statusLabel => 'Durum';
  @override String get paidStatus => 'Ödendi';
  @override String get unpaidStatus => 'Ödenmedi';
  @override String get overdueStatus => 'Gecikmiş';
  @override String get saleLabel => 'Satış';
  @override String get collectionLabel => 'Tahsilat';
  @override String get packagePrice => 'Paket Ücreti';
  @override String get netPrice => 'Net Tutar';
  @override String get registrationDate => 'Kayıt Tarihi';
  @override String get endDate => 'Bitiş Tarihi';
  @override String get unitPrice => 'Birim Fiyat';
  @override String get totalPrice => 'Toplam Tutar';
  @override String get discountLabel => 'İndirim';
  @override String get packageNameLabel => 'Paket Adı';
  @override String get quantity => 'Adet';
  @override String get activeStatus => 'Aktif';
  @override String get expiredStatus => 'Süresi Dolmuş';
  @override String get relationship => 'Yakınlık Derecesi';
  @override String get location => 'Lokasyon';
  @override String get guardianName => 'Veli Adı';
  @override String get studentInfo => 'Öğrenci Bilgisi';

  @override Map<String, String> get relationshipLabels => const {
    'parent': 'Ebeveyn',
    'mother': 'Anne',
    'father': 'Baba',
    'sibling': 'Kardeş',
    'spouse': 'Eş',
    'grandparent': 'Büyükanne/Büyükbaba',
    'uncle_aunt': 'Amca/Teyze/Dayı/Hala',
    'other': 'Diğer',
    'anne': 'Anne',
    'baba': 'Baba',
    'kardeş': 'Kardeş',
    'eş': 'Eş',
    'ebeveyn': 'Ebeveyn',
    'anna': 'Anne',
    'veli': 'Veli',
    'dede': 'Dede',
    'büyükanne': 'Büyükanne',
    'büyükbaba': 'Büyükbaba',
    'amca': 'Amca',
    'dayı': 'Dayı',
    'teyze': 'Teyze',
    'hala': 'Hala',
    'diğer': 'Diğer',
  };

  @override String get primaryGuardian => 'Birincil Veli';
  @override String get note => 'Not';
  @override String get call => 'Ara';
  @override String get guardianSecondaryPhone => 'İkinci telefon';
  @override String get guardianProfessionGroupField => 'Meslek grubu';
  @override String get guardianProvinceField => 'İl';
  @override String get guardianDistrictField => 'İlçe';
  @override String get guardianAddressField => 'Adres';

  @override Map<String, String> get guardianProfessionGroupLabels => const {
        'health_wellness': 'Sağlık ve wellness',
        'education': 'Eğitim',
        'it_technology': 'Bilişim ve teknoloji',
        'finance_business': 'Finans ve iş dünyası',
        'legal_advocacy': 'Hukuk ve avukatlık',
        'engineering_technical': 'Mühendislik ve teknik',
        'architecture_construction': 'Mimarlık ve inşaat',
        'agriculture_food': 'Tarım ve gıda',
        'manufacturing_industry': 'Üretim ve sanayi',
        'retail_service': 'Perakende ve hizmet',
        'hospitality_tourism': 'Konaklama ve turizm',
        'transport_logistics': 'Ulaştırma ve lojistik',
        'energy_utilities': 'Enerji ve kamu hizmetleri',
        'media_marketing': 'Medya ve pazarlama',
        'hr_administration': 'İK ve idari',
        'public_sector': 'Kamu sektörü',
        'security_defense': 'Güvenlik ve savunma',
        'science_research': 'Bilim ve araştırma',
        'nonprofit_ngo': 'STK ve sivil toplum',
        'freelance_art': 'Serbest meslek ve sanat',
        'homemaker': 'Ev içi',
        'student_retired': 'Öğrenci veya emekli',
        'unemployed': 'İşsiz',
        'other': 'Diğer',
      };

  @override String get lessonAttendance => 'Derse Katılım';
  @override String get lesson => 'Ders';
  @override String get teacher => 'Öğretmen';
  @override String get classroom => 'Sınıf';
  @override String get date => 'Tarih';
  @override String get time => 'Saat';
  @override String get attendanceStatus => 'Yoklama';
  @override String get attended => 'Geldi';
  @override String get notAttended => 'Gelmedi';
  @override String get burned => 'Yakıldı';
  @override String get deducted => 'Hak düşüldü';
  @override String get notDeducted => 'Hak düşülmedi';
  @override String get actionLabel => 'İşlem';
  @override String get changeLabel => 'Değişim';
  @override String get remainAfter => 'Kalan Hak';
  @override String get noReservations => 'Derse katılım kaydı bulunamadı';
  @override String get noLogs => 'İşlem geçmişi bulunamadı';
  @override String get makeupLesson => 'Telafi dersi';
  @override String get lessonTypeGroupShort => 'Grup';
  @override String get lessonTypeIndividualShort => 'Bireysel';
  @override String get cancelledLesson => 'İptal edilen ders';
  @override String get noAttendanceRecords => 'Yoklama kaydı bulunamadı';
  @override Map<String, String> get logActionLabels => const {
    'manual_deduction': 'Manuel Düşüm',
    'burn': 'Yakma',
    'unburn': 'Yakma İptali',
    'attendance': 'Yoklama',
    'attendance_removed': 'Yoklama İptali',
    'attendance_deduction': 'Yoklama Düşümü',
    'attendance_refund': 'Yoklama İadesi',
  };

  @override Map<String, String> get paymentTypeLabels => const {
    'NAKIT': 'Nakit',
    'KREDI_KARTI': 'Kredi Kartı',
    'EFT_HAVALE': 'EFT / Havale',
    'ONLINE_ODEME': 'Online Ödeme',
  };
  @override String get paymentType => 'Ödeme Türü';
  @override String get paidDate => 'Ödeme Tarihi';
  @override String get paidExplanation => 'Açıklama';

  @override Map<String, String> get professionLabels => const {
    'fitness_trainer': 'Fitness Eğitmeni',
    'plates_trainer': 'Pilates Eğitmeni',
    'kickbox_trainer': 'Kickbox Eğitmeni',
    'yoga_trainer': 'Yoga Eğitmeni',
    'zumba_trainer': 'Zumba Eğitmeni',
    'bungee_fly_trainer': 'Bungee Fly Eğitmeni',
    'pound_trainer': 'Pound Eğitmeni',
    'dietician': 'Diyetisyen',
    'physiotherapist': 'Fizyoterapist',
    'cycle': 'Cycle Eğitmeni',
    'head_coach': 'Baş Antrenör',
    'dance_coach': 'Dans Eğitmeni',
  };
}

// ─────────────────────────────────────────────────────────────
// MusicSchoolLabels
// ─────────────────────────────────────────────────────────────

class MusicSchoolLabels extends GymLabels {
  const MusicSchoolLabels();

  @override String get birthDateFormatDash => 'GG-AA-YYYY';

  @override String get member => 'Öğrenci';
  @override String get trainer => 'Öğretmen';
  @override String get groupLesson => 'Ders';
  @override String get personalTraining => 'Özel Ders';
  @override String get fitnessProgram => 'Müzik Programı';
  @override String get bodyMeasurement => 'Gelişim Takibi';
  @override String get diet => 'Beslenme';
  @override String get memberCard => 'Öğrenci Kartı';
  @override String get enrollment => 'Öğrenci Kayıt';
  @override String get members => 'Öğrenciler';
  @override String get employees => 'Öğretmenler';
  @override String get movementCatalog => 'Egzersiz Kataloğu';

  @override String get noActiveMembership => 'Aktif Kaydınız Bulunmamaktadır';
  @override String get trainerRoster => 'Öğretmen Kadrosu';
  @override String get groupLessonRules => 'Ders Kuralları';
  @override String get groupLessons => 'Dersler';
  @override String get groupLessonDetail => 'Ders Detayı';
  @override String get purchasedMembers => 'Dersi satın alanlar';
  @override String get exerciseList => 'Egzersiz\nListem';
  @override String get measurementInfo => 'Gelişim\nTakibi';
  @override String get nutritionInfo => 'Beslenme\nBilgilerim';
  @override String get selectTrainer => 'Öğretmen Seçin';
  @override String get subscriptionInfo => 'Kayıt Bilgileri';
  @override String get membershipRules => 'Kayıt Kuralları';
  @override String get membershipFrozen => '(Kayıt Donduruldu)';
  @override String get myMeasurements => 'Gelişim Takibim';
  @override String get addMeasurement => 'Gelişim Kaydı Ekle';
  @override String get deleteMeasurement => 'Kaydı Sil';
  @override String get deleteMeasurementConfirm => 'Kaydı silmek istediğinize emin misiniz?';
  @override String get measurementDeletedSuccess => 'Kayıt başarıyla silindi.';
  @override String get noMeasurementData => 'Görüntülenecek veri bulunmamaktadır.';

  @override Map<String, String> get professionLabels => const {
    'piano_teacher': 'Piyano Öğretmeni',
    'guitar_teacher': 'Gitar Öğretmeni',
    'classical_guitar_teacher': 'Klasik Gitar Öğretmeni',
    'electric_guitar_teacher': 'Elektro Gitar Öğretmeni',
    'bass_guitar_teacher': 'Bas Gitar Öğretmeni',
    'violin_teacher': 'Keman Öğretmeni',
    'drum_teacher': 'Bateri / Davul Öğretmeni',
    'flute_teacher': 'Yan Flüt Öğretmeni',
    'viola_teacher': 'Viyola Öğretmeni',
    'cello_teacher': 'Çello Öğretmeni',
    'vocal_teacher': 'Şan Öğretmeni',
    'solfege_teacher': 'Solfej Öğretmeni',
    'baglama_teacher': 'Bağlama Öğretmeni',
    'ud_teacher': 'Ud Öğretmeni',
    'keyboard_teacher': 'Klavye Öğretmeni',
    'music_theory_teacher': 'Müzik Teorisi Öğretmeni',
    'composition_teacher': 'Bestecilik Öğretmeni',
    'music_instructor': 'Müzik Eğitmeni',
    'art_teacher': 'Resim Öğretmeni',
    'drama_teacher': 'Tiyatro/Drama Öğretmeni',
  };
}

// ─────────────────────────────────────────────────────────────
// SwimmingCourseLabels
// ─────────────────────────────────────────────────────────────

class SwimmingCourseLabels extends GymLabels {
  const SwimmingCourseLabels();

  /// Özet popup / eğitmen kartlarında “grup” vurgusu yok — yüzme bağlamında genel “bugünkü dersler”.
  @override String get todayGroupLessons => 'Bugünkü dersler';

  @override String get member => 'Kursiyer';
  @override String get groupLesson => 'Yüzme Dersi';
  @override String get personalTraining => 'Özel Yüzme Dersi';
  @override String get fitnessProgram => 'Antrenman Programı';
  @override String get bodyMeasurement => 'Gelişim Takibi';
  @override String get memberCard => 'Kursiyer Kartı';
  @override String get enrollment => 'Kursiyer Kayıt';
  @override String get members => 'Kursiyerler';

  @override String get noActiveMembership => 'Aktif Kurs Kaydınız Bulunmamaktadır';
  @override String get trainerRoster => 'Eğitmen Kadrosu';
  @override String get groupLessonRules => 'Yüzme Dersi Kuralları';
  @override String get groupLessons => 'Yüzme\nDersleri';
  @override String get groupLessonDetail => 'Yüzme Dersi Detayı';
  @override String scheduleListHeaderForDate(String formattedDate) =>
      '$formattedDate Yüzme dersleri listesi';
  @override String get trainerScheduleAddLessonTitle => 'Yüzme dersi ekle';
  @override String get trainerScheduleEditLessonTitle => 'Yüzme Dersini Düzenle';
  @override String get trainerScheduleDeleteLessonConfirm =>
      'Bu yüzme dersini silmek istiyor musunuz?';
  @override String get trainerScheduleLessonDeleted => 'Yüzme dersi silindi';
  @override String get trainerScheduleDeleteLessonFailed => 'Yüzme dersi silinemedi';
  @override String get trainerTodayDashboardQuickReservationSectionTitle =>
      'Bugünkü Yoklamalar';
  @override String get trainerScheduleTrainerFixedHint =>
      'Plan, yüzme eğitmeni olarak yalnızca sizin hesabınıza kaydedilir.';
  @override String get subscriptionInfo => 'Kurs Bilgileri';
  @override String get membershipRules => 'Kurs Kuralları';
  @override String get membershipFrozen => '(Kurs Donduruldu)';
  @override String get measurementInfo => 'Gelişim\nTakibi';
  @override String get myMeasurements => 'Gelişim Takibim';
  @override String get addMeasurement => 'Gelişim Kaydı Ekle';

  @override Map<String, String> get professionLabels => const {
    'swimming_trainer': 'Yüzme Eğitmeni',
    'head_coach': 'Baş Antrenör',
    'physiotherapist': 'Fizyoterapist',
  };
}
