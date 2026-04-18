import 'package:e_sport_life/core/l10n/app_labels.dart';

// ─────────────────────────────────────────────────────────────
// GymLabelsEn (English — default)
// ─────────────────────────────────────────────────────────────

class GymLabelsEn implements AppLabels {
  const GymLabelsEn();

  // Roles
  @override String get member => 'Member';
  @override String get trainer => 'Trainer';
  @override String get moderator => 'Manager';
  @override String get admin => 'Admin';

  // Panel Modules
  @override String get groupLesson => 'Group Lesson';
  @override String get quickReservation => 'Quick Reservation';
  @override String get personalTraining => 'PT';
  @override String get reservation => 'Reservation';
  @override String get calendar => 'Calendar';
  @override String get fitnessProgram => 'Fitness Program';
  @override String get bodyMeasurement => 'Body Measurement';
  @override String get diet => 'Diet';
  @override String get memberCard => 'Member Card';
  @override String get reports => 'Reports';
  @override String get qrScan => 'Scan QR';
  @override String get employees => 'Staff';
  @override String get locations => 'Locations';
  @override String get enrollment => 'Enrollment';
  @override String get movementCatalog => 'Exercise Catalog';

  // Admin Modules
  @override String get members => 'Members';
  @override String get packageSale => 'Package Sale';
  @override String get payment => 'Payment';
  @override String get expense => 'Expense';
  @override String get sms => 'SMS';
  @override String get announcement => 'Announcements';
  @override String get dashboard => 'Dashboard';
  @override String get settings => 'Settings';
  @override String get abilityManagement => 'Permission Management';

  // Navigation
  @override String get home => 'Home';
  @override String get profile => 'Profile';
  @override String get qrCode => 'QR Code';
  @override String get account => 'Account';
  @override String get shop => 'Shop';

  // General Actions
  @override String get save => 'Save';
  @override String get saving => 'Saving...';
  @override String get cancel => 'Cancel';
  @override String get delete => 'Delete';
  @override String get edit => 'Edit';
  @override String get add => 'Add';
  @override String get search => 'Search';
  @override String get selectCountry => 'Select Country';
  @override String get list => 'List';
  @override String get detail => 'Detail';
  @override String get confirm => 'Confirm';
  @override String get approve => 'I Approve';
  @override String get close => 'Close';
  @override String get update => 'Update';
  @override String get yes => 'Yes';
  @override String get no => 'No';
  @override String get send => 'Send';
  @override String get selectFromContacts => 'Select from Contacts';
  @override String get selectFile => 'Select File';
  @override String get takePhoto => 'Take Photo';
  @override String get chooseFromGallery => 'Choose from Gallery';
  @override String get deletePhoto => 'Delete Photo';
  @override String get photoUpdated => 'Photo updated.';
  @override String get photoDeleted => 'Photo deleted.';
  @override String get photoUpdateFailed => 'An error occurred while updating the photo.';
  @override String get previous => 'Previous';
  @override String get next => 'Next';

  // Attendance / Right Deduction
  @override String get attendance => 'Attendance';
  @override String get attendanceDescription =>
      'Find the member by QR code or card number to take attendance.';
  @override String get attendanceScanQr => 'Scan QR Code';
  @override String get scanMemberQr => 'Scan member QR code';
  @override String get cardNumber => 'Card Number';
  @override String get enterCardNumber => 'Enter 10-digit card number';
  @override String get searchMember => 'Search Member';
  @override String get cardNumberInvalid => 'Card number must be 10 digits';
  @override String get invalidOrExpiredQr => 'Invalid or expired QR code';
  @override String get memberNotFoundByCard => 'No member found for this card';
  @override String get noActivePackage => 'No active package';
  @override String get burnConfirm =>
      'Would you like to confirm attendance for this lesson?';
  @override String get burnSuccess =>
      'Attendance recorded and session deducted.';
  @override String get burnError => 'An error occurred during session deduction';
  @override String get scanNewMember => 'Scan New Member';
  @override String get activePackages => 'Active Packages';
  @override String get packageDeductions => 'Package Deductions';
  @override String get undoDeduction => 'Undo';
  @override String get undoDeductionConfirm => 'Are you sure you want to undo this deduction?';
  @override String get undoDeductionSuccess =>
      'Attendance record and session deduction undone successfully.';
  @override String get undoDeductionError => 'An error occurred while undoing the deduction';
  @override String get noDeductionHistory => 'No deduction history found';
  @override String get onlyTodayCanUndo => 'Only today\'s records can be undone';
  @override String get attendanceSelectLessonTitle => 'Which lesson is this attendance for?';
  @override String get attendanceNoLessonsToday =>
      'There are no group lessons on your schedule today. Add a lesson in the schedule or check the date.';
  @override String get scheduleTakeAttendanceFab => 'Take attendance';
  @override String get attendancePresetLessonHeading =>
      'Lesson linked to this attendance';
  @override String get attendancePresetLessonSectionHint =>
      'When you find the member via QR or card, the session is deducted for this group lesson.';
  @override String get attendanceLessonCardShowMore => 'View details';
  @override String get attendanceLessonCardShowLess => 'Show less';

  // Status
  @override String get loading => 'Loading...';
  @override String get noData => 'No Data Found';
  @override String get error => 'Error';
  @override String get success => 'Success';
  @override String get remainingRights => 'Remaining Sessions';
  @override String get burnRight => 'Deduct';
  @override String get refundRight => 'Refund';
  @override String get noAccessPermission => 'You do not have permission to access this feature.';

  // Login / Verification
  @override String get verificationCode => 'Verification Code';
  @override String get enterVerificationCode => 'Enter Verification Code';
  @override String get verificationCodeHint => 'Enter 6-digit verification code...';
  @override String get verificationCodeError => 'Verification code is incorrect, please check the code sent to you.';
  @override String get serverUnreachable => 'Server is unreachable, please try again later.';
  @override String get codeValidating => 'Validating Code';
  @override String get login => 'Login';
  @override String get logout => 'Logout';
  @override String get logoutConfirm => 'Are you sure you want to logout?';
  @override String get kvkkTitle => 'GDPR Privacy Notice';
  @override String get kvkkApprovalRequired => 'GDPR approval is required to login.';
  @override String get kvkkRead => 'I have read the GDPR privacy notice.';
  @override String get kvkkLoadError => 'Failed to load GDPR notice.';

  // Splash / Greeting
  @override String get welcome => 'Welcome';
  @override String get goodMorning => 'Good Morning!';
  @override String get goodAfternoon => 'Good Afternoon!';
  @override String get goodEvening => 'Good Evening!';
  @override String get goodNight => 'Good Night!';

  // Homepage (Explore)
  @override String get quickAccess => 'Quick Access';
  @override String get remainingDays => 'Remaining Days';
  @override String get noActiveMembership => 'You Have No Active Fitness Membership';
  @override String get membershipFrozen => '(Membership Frozen)';
  @override String get facilityOccupancy => 'Facility Occupancy Rate';
  @override String get noOccupancyData => 'No Occupancy Data';
  @override String get detailedView => 'Detailed View';
  @override String get fullList => 'Full List';
  @override String get featureNotActive => 'This feature is currently not active';
  @override String get accountPassiveWarning => 'Your account is passive, you cannot use this feature.';
  @override String get accountPassiveProfileWarning => 'Your account is passive, you cannot update your profile.';

  // Turnstile
  @override String get entryIn => 'Entry';
  @override String get entryOut => 'Exit';

  // Facility
  @override String get facilityInfo => 'Facility Information';
  @override String get photo => 'Photo';
  @override String get contactInfo => 'Contact Information';
  @override String get phoneLabel => 'Phone';
  @override String get emailLabel => 'Email';
  @override String get whatsappLabel => 'WhatsApp';
  @override String get addressLabel => 'Address';
  @override String get openInMaps => 'Open in Maps';
  @override String get sendWhatsApp => 'Send WhatsApp';
  @override String get callPhone => 'Call';
  @override String get sendEmail => 'Send Email';

  // Profile Menu
  @override String get myProfile => 'My Profile';
  @override String get paymentHistory => 'Payment History';
  @override String get pastEntryHistory => 'Past Entry History';
  @override String get facilityDetails => 'Facility Details';
  @override String get trainerRoster => 'Trainer Roster';
  @override String get suggestionComplaint => 'Suggestions';
  @override String get groupLessonRules => 'Group Lesson Rules';
  @override String get quickReservationRules => 'Quick Reservation Rules';
  @override String get facilityRules => 'Facility Rules';
  @override String get membershipRules => 'Membership Rules';
  @override String get institutionRules => 'Institution Rules';
  @override String get about => 'About';

  // Quick Access Grid
  @override String get inviteFriend => 'Invite\na Friend';
  @override String get virtualWallet => 'Virtual\nWallet';
  @override String get earnAsYouSpend => 'Earn as\nYou Spend';
  @override String get exerciseList => 'My\nExercises';
  @override String get measurementInfo => 'My\nMeasurements';
  @override String get nutritionInfo => 'My\nNutrition';
  @override String get groupLessons => 'Group\nLessons';

  // Package / Subscription
  @override String get subscriptionInfo => 'Subscription Info';
  @override String get purchasedBranchPackages => 'Purchased Branch Packages';
  @override String get purchasedPtPackages => 'Purchased PT Packages';
  @override String get massagePackages => 'My Massage Packages';
  @override String get contractNo => 'Contract No';
  @override String get startDate => 'Start Date';
  @override String get discount => 'Discount';
  @override String get selectTrainer => 'Select Trainer';
  @override String get appointmentDateTime => 'Appointment Date & Time';
  @override String get createAppointment => 'Create Appointment';
  @override String get myAppointments => 'My Appointments';
  @override String get cancelAppointment => 'Cancel Appointment';
  @override String get cancelled => 'Cancelled';
  @override String get appointmentCreatedSuccess => 'Appointment created successfully';
  @override String get appointmentNotFound => 'No appointment schedule found.';

  // Payment
  @override String get paymentSummary => 'Payment Summary';
  @override String get amount => 'Amount';
  @override String get totalPaid => 'Total Paid';
  @override String get remaining => 'Remaining';
  @override String get myPayments => 'My Payments';
  @override String get upcomingPeriod => 'Upcoming Period';
  @override String get makePayment => 'Make Payment';

  // Group Lesson
  @override String get groupLessonDetail => 'Group Lesson Detail';
  @override String get person => 'Person';
  @override String get minParticipation => 'Min Participation';
  @override String get opening => 'Opening';
  @override String get fee => 'Fee';
  @override String get paid => 'Paid';
  @override String get free => 'Free';
  @override String get registrationAuth => 'Registration Authority';
  @override String get purchasedMembers => 'Lesson Purchasers';
  @override String get day => 'Day';
  @override String get registered => 'Registered';
  @override String get registrationAvailable => 'Registration Available';
  @override String get reservationOnLessonDay => 'Reservation is made on lesson day.';
  @override String scheduleListHeaderForDate(String formattedDate) =>
      'Group lessons — $formattedDate';
  @override String get groupLessonScheduleLessonTimeLabel => 'Lesson time';
  @override String get groupLessonScheduleCapacityLabel => 'Capacity';

  // Measurement
  @override String get myMeasurements => 'My Measurements';
  @override String get measurementDetail => 'Measurement Detail';
  @override String get addMeasurement => 'Add Measurement';
  @override String get deleteMeasurement => 'Delete Measurement';
  @override String get deleteMeasurementConfirm => 'Are you sure you want to delete this measurement?';
  @override String get measurementDeletedSuccess => 'Measurement record deleted successfully.';
  @override String get noMeasurementData => 'No measurement data to display.';
  @override String get pdfFiles => 'PDF Files';
  @override String get images => 'Images';
  @override String get weight => 'Weight';
  @override String get arm => 'Arm';
  @override String get shoulder => 'Shoulder';
  @override String get height => 'Height';
  @override String get chest => 'Chest';
  @override String get abdomen => 'Abdomen';
  @override String get fieldRequired => 'field is required';

  // Fitness / Exercise
  @override String get exerciseExecution => 'Exercise Execution';
  @override String get exerciseDone => 'I Did It';
  @override String get videoNotAvailable => 'Video not available';
  @override String get videoAvailable => 'Video available';
  @override String get movement => 'movement';

  // Locker
  @override String get closetList => 'Locker List';
  @override String get emptyElectronicCloset => 'Empty Electronic Locker';
  @override String get closetPassword => 'Locker Password';

  // Suggestion
  @override String get suggestionComplaintHistory => 'Suggestion History';
  @override String get createSuggestionComplaint => 'Create Suggestion';
  @override String get title => 'Title';
  @override String get topicTitle => 'Enter Topic Title...';
  @override String get suggestionAndComplaint => 'Your Suggestion';
  @override String get writeSuggestionComplaint => 'Write Your Suggestion...';
  @override String get sentSuccess => 'Sent successfully';
  @override String get sendFailed => 'Sending failed, please try again later.';
  @override String get fillAllFields => 'Please fill in all fields';
  @override String get viewSuggestionComplaint => 'View Suggestion';
  @override String get submitting => 'Submitting...';
  @override String get currencySuffix => ' ₺';

  // Invitation
  @override String get inviteFriendTitle => 'Invite a Friend';
  @override String get enterFriendInfo => 'Enter the information of the friend you want to invite';
  @override String get inviteSentSuccess => 'Invitation sent successfully.';
  @override String get contactPermissionRequired => 'Contact access permission is required.';
  @override String get contactPickError => 'An error occurred while selecting a contact.';
  @override String get fillRequiredFieldsAndPhone => 'Please fill in all required fields and enter a valid phone number.';
  @override String get retry => 'Retry';
  @override String get inviteKvkkConsentPrefix => 'The phone number entered by the user within the scope of the invitation is processed for the purposes of conducting invitation processes, tracking invitation statuses, and providing information related to the invitation. A limited number of messages may be sent to the relevant number in accordance with applicable regulations and solely for invitation purposes. The user acknowledges that the contact information shared belongs to the relevant person and that they have the necessary authorization for this sharing. For detailed information, please review ';
  @override String get inviteKvkkConsentSuffix => '.';

  // Virtual Wallet / Earn as You Spend
  @override String get transactionHistory => 'Transaction History';
  @override String get balanceLoad => 'Load Balance';
  @override String get spending => 'Spending';
  @override String get usablePoints => 'Usable Points';
  @override String get convertAndSpendPoints => 'Convert & Spend Points';
  @override String get transaction => 'Transaction';
  @override String get earnedPoints => 'Earned Points';
  @override String get orderNo => 'Order No';
  @override String get description => 'Description';

  // Shop (GymExxtra)
  @override String get packageSelection => 'Select a Package';
  @override String get selectPackage => 'Choose Package';
  @override String get selectedPackage => 'Selected Package';
  @override String get orderHistory => 'Order History';
  @override String get orderSummary => 'Order Summary';
  @override String get productAmount => 'Product Amount';
  @override String get discountAmount => 'Discount';
  @override String get payableAmount => 'Payable Amount';
  @override String get orderDate => 'Order Date';
  @override String get purchase => 'Purchase';
  @override String get enterCouponCode => 'Enter coupon code if available';
  @override String get couponApplied => 'Coupon applied successfully.';
  @override String get invalidCoupon => 'Invalid coupon code.';
  @override String get cartError => 'Could not retrieve cart information.';
  @override String get branchInfoError => 'Could not retrieve branch information.';
  @override String get paymentPageError => 'Could not open payment page.';
  @override String get cartOperationFailed => 'Cart operation failed.';

  // QR
  @override String get qrCodeGenerating => 'Generating QR Code';
  @override String get screenBrightness => 'Screen Brightness';
  @override String get scanQrCode => 'Scan QR Code';
  @override String get renewQrCode => 'Renew QR Code';
  @override String get refreshCode => 'Refresh Code';
  @override String get tryAgain => 'Try Again';
  @override String get qrCodeCreateFailed => 'Failed to create QR code';
  @override String get configNotFound => 'Configuration not found';
  @override String get securityCodeServiceUnavailable => 'Security code service is unavailable';

  // Member QR Check Messages
  @override String get overduePaymentWarning => 'You have overdue payments, please make your payment.';
  @override String get debtExistsWarning => 'You have an outstanding balance, please make your payment.';
  @override String get membershipFrozenWarning => 'Your membership is frozen. You cannot enter or exit the facility.';
  @override String get noActivePackageWarning => 'You do not have an active package.';
  @override String get outsideEntryHoursWarning => 'You are outside your entry hours. Please contact reception.';

  // Profile Edit
  @override String get fullName => 'Full Name';
  @override String get phoneNumber => 'Phone Number';
  @override String get email => 'Email';
  @override String get gender => 'Gender';
  @override String get male => 'MALE';
  @override String get female => 'FEMALE';
  @override String get birthDate => 'Birth Date';
  @override String get birthDateFormat => 'DD/MM/YYYY';
  @override String get birthDateFormatDash => birthDateFormat;
  @override String get notificationsEnabled => 'I Want to Receive Notifications';
  @override String get selectFromGallery => 'Select from Gallery';
  @override String get takeFromCamera => 'Take from Camera';
  @override String get photoProcessing => 'Processing photo...';
  @override String get photoDeleting => 'Deleting photo...';
  @override String get mayTakeSeconds => 'May take up to 10 seconds';
  @override String get lockerPassword => 'Locker Password';
  @override String get confirmEmail => 'Verify Email';
  @override String get emailVerified => 'Email verified';
  @override String get emailNotVerified => 'Email not verified';
  @override String get sendVerification => 'Verify';
  @override String get verificationSent => 'Sent';
  @override String get emailVerificationSent => 'Email verification link has been sent. Please check your inbox.';
  @override String get emailVerificationFailed => 'An error occurred while sending the email verification link. Please try again.';
  @override String get changePassword => 'Change Password';
  @override String get currentPassword => 'Current Password';
  @override String get newPassword => 'New Password';
  @override String get newPasswordConfirm => 'New Password (Confirm)';
  @override String get passwordMinLength => 'Password must be at least 6 characters.';
  @override String get passwordMismatch => 'New passwords do not match.';
  @override String get passwordSameAsOld => 'New password must be different from current password.';
  @override String get currentPasswordWrong => 'Current password is incorrect.';
  @override String get passwordChangeSuccess => 'Your password has been changed successfully.';
  @override String get passwordChangeFailed => 'An error occurred while changing password.';
  @override String get changePhone => 'Change Phone Number';
  @override String get newPhone => 'New Phone Number';
  @override String get phoneChecking => 'Checking...';
  @override String get phoneAvailable => 'This phone number is available.';
  @override String get phoneTaken => 'This phone number is already registered.';
  @override String get phoneSameAsCurrent => 'The phone number is the same as the current one.';
  @override String get invalidPhoneFormat => 'Please enter a valid phone number.';
  @override String get phoneCheckError => 'An error occurred during the check.';
  @override String get phoneChangeSuccess => 'Phone number updated successfully.';
  @override String get phoneChangeFailed => 'An error occurred while updating phone.';
  @override String get changeEmail => 'Change Email';
  @override String get newEmail => 'New Email Address';
  @override String get emailChecking => 'Checking...';
  @override String get emailAvailable => 'This email address is available.';
  @override String get emailTaken => 'This email address is already registered.';
  @override String get emailSameAsCurrent => 'The email address is the same as the current one.';
  @override String get invalidEmailFormat => 'Please enter a valid email address.';
  @override String get emailCheckError => 'An error occurred during the check.';
  @override String get emailChangeSuccess => 'Email address updated successfully.';
  @override String get emailChangeFailed => 'An error occurred while updating email.';
  @override String get profileUpdateSuccess => 'Your information has been updated successfully.';
  @override String get profileUpdateFailed => 'An error occurred while updating your information. Please try again.';
  @override String get sessionNotFoundReLogin => 'Session not found. Please log in again.';
  @override String get apiConnectionNotFound => 'API connection information not found.';

  // Language
  @override String get language => 'Language';
  @override String get languageTurkish => 'Türkçe';
  @override String get languageEnglish => 'English';

  // Trainer Home
  @override String get todayProgram => 'Today\'s Program';
  @override String get todayGroupLessons => 'Today\'s Group Lessons';
  @override String get todayQuickReservations => 'Today\'s Quick Reservations';
  @override String get trainerTodayDashboardQuickReservationSectionTitle =>
      todayQuickReservations;
  @override String get todayPtReservations => 'Today\'s PT Reservations';
  @override String get recentTransactions => 'Recent Transactions';
  @override String get noRecentTransactions => 'No transactions yet';
  @override String get reservationDetail => 'Reservation Detail';
  @override String get lessonCount => 'lessons';
  @override String get personCount => 'people';

  // Trainer Profile
  @override String get biography => 'About Me';
  @override String get biographyHint => 'Tell us briefly about yourself...';
  @override String get expertise => 'Expertise';
  @override String get selectExpertise => 'Select your areas of expertise';
  @override String get colorLabel => 'Color';
  @override String get selectColor => 'Select a color';
  @override String get removeColor => 'Remove Color';

  // Internet / Session
  @override String get noInternetConnection => 'No Internet Connection';
  @override String get checkInternetAndTryAgain => 'Please check your internet connection\nand try again.';
  @override String get checkInternetConnection => 'Please check your\ninternet connection.';
  @override String get sessionExpired => 'Session has expired';
  @override String get sessionExpiredReGetCode => 'Session has expired, please get a new verification code.';
  @override String get sessionOpenedOnAnotherDevice => 'Session opened on another device';
  @override String get sessionOpenedOnAnotherDeviceReLogin => 'Session opened on another device. Please log in again.';

  // General Errors
  @override String get errorOccurred => 'An error occurred';
  @override String get fieldCannotBeEmpty => 'field cannot be empty';
  @override String get urlCouldNotOpen => 'URL could not be opened';
  @override String get fileUrlNotFound => 'File URL not found.';
  @override String get fileCouldNotOpen => 'Could not open file.';
  @override String get fileDownloadError => 'An error occurred while downloading the file.';

  // Day Names
  @override String get monday => 'Monday';
  @override String get tuesday => 'Tuesday';
  @override String get wednesday => 'Wednesday';
  @override String get thursday => 'Thursday';
  @override String get friday => 'Friday';
  @override String get saturday => 'Saturday';
  @override String get sunday => 'Sunday';

  // Filter
  @override String get all => 'All';

  // Trainer Rating
  @override String get rateTrainer => 'Rate';
  @override String get selectStarRating => 'Select Your Star Rating';
  @override String get rate => 'Rate';
  @override String get rating => 'Rating';

  // Announcements
  @override String get announcementsAndNotifications => 'Announcements / Notifications';
  @override String get announcementNotFound => 'No announcements found';

  // App Update
  @override String get newVersionAvailable => 'A new version is available. Would you like to update the app?';

  // Music School / General Panel
  @override String get todayMyLessons => 'Today\'s\nLessons';
  @override String get todayMyPayments => 'Today\'s\nPayments';
  @override String get todayMyAttendances => 'Today\'s\nAttendance';
  @override String get myActivePackages => 'Active\nPackages';
  @override String get todaySummaryTitle => 'Today\'s\nSummary';
  @override String get trainerHomeTodayAttendanceTitle => 'Today\'s\nAttendance';
  @override String get trainerQuickAccessAttendanceByQrTitle => 'Attendance\nby QR';
  @override String get trainerScheduleAddLessonTitle => 'Add lesson';
  @override String get trainerScheduleEditLessonTitle => 'Edit lesson';
  @override String get trainerScheduleEditLessonDaysHint =>
      'This plan\'s weekday is fixed; you can update time, duration, and other fields.';
  @override String get trainerScheduleLoadLessonFailed => 'Could not load lesson details';
  @override String get trainerScheduleDeleteLessonConfirm =>
      'Do you want to delete this lesson?';
  @override String get trainerScheduleLessonDeleted => 'Lesson deleted';
  @override String get trainerScheduleDeleteLessonFailed => 'Could not delete lesson';
  @override String get trainerScheduleLessonNameLabel => 'Lesson';
  @override String get trainerScheduleServiceTypeLabel => 'Lesson type';
  @override String get trainerScheduleWeekdayLabel => 'Lesson day';
  @override String get trainerScheduleStartTimeLabel => 'Start time';
  @override String get trainerScheduleStartTimeHint => 'HH:mm (e.g. 09:00)';
  @override String get trainerScheduleDurationLabel => 'Duration (hours)';
  @override String get trainerSchedulePeriodLabel => 'Recurrence';
  @override String get trainerSchedulePeriodWeekly => 'Weekly';
  @override String get trainerSchedulePeriodOneTime => 'One-time';
  @override String get trainerSchedulePersonLimitLabel => 'Capacity';
  @override String get trainerScheduleTrackPaymentLabel =>
      'Track package/credits (paid lesson)';
  @override String get trainerScheduleTrainerFixedHint =>
      'Plans are saved only for your trainer account.';
  @override String get trainerScheduleNoLocationOption => 'No location';
  @override String get trainerScheduleLessonSaved => 'Lesson plan saved';
  @override String get trainerScheduleLessonSaveFailed => 'Could not save lesson plan';
  @override String get trainerScheduleLoadFormFailed => 'Could not load form data';
  @override String get trainerScheduleSelectService => 'Select lesson type';
  @override String get trainerScheduleSectionEssentials => 'Basics';
  @override String get trainerScheduleSectionSchedule => 'Day & duration';
  @override String get trainerScheduleSectionLimits => 'Capacity';
  @override String get trainerScheduleSectionMore => 'Location & notes';
  @override String get trainerScheduleTrackPaymentSubtitle =>
      'When on, the lesson is treated as paid and deducts from the member package.';
  @override String get trainerScheduleLessonDaysLabel => 'Lesson days';
  @override String get trainerScheduleLessonDaysHint =>
      'Select one or more days; a separate plan is created for each. Each day can have its own start time and duration.';
  @override String get trainerScheduleDayTimeSlotsTitle =>
      'Time and duration per selected day';
  @override String get trainerScheduleDayStartTimeShortLabel => 'Time';
  @override String get trainerSchedulePickTimeTooltip => 'Choose time';
  @override String get trainerSchedulePickTimeFieldHint => 'Tap to select';
  @override String get trainerScheduleSelectAtLeastOneDay =>
      'Select at least one lesson day';
  @override String trainerScheduleLessonsSaveResult(int saved, int failed) {
    if (failed == 0) {
      return saved == 1
          ? 'Lesson plan saved'
          : 'Saved $saved lesson plans';
    }
    if (saved == 0) {
      return failed == 1
          ? 'Could not save lesson plan'
          : 'Could not save $failed lesson plans';
    }
    return 'Saved $saved lesson plans, $failed failed';
  }

  @override String get homeSummarySectionTitle => 'Overview';
  @override String get homeSummaryActivePackagesLabel => 'Active Packages';
  @override String get homeSummaryRemainingRightsLabel => 'Total Remaining Credits';
  @override String get homeSummaryThisWeekLessonsLabel => 'Lesson Count';
  @override String get homeSummaryThisWeekLessonsCaption =>
      'This Week\'s Lesson Count';
  @override String get homeSummaryOverduePaymentsLabel => 'Overdue';
  @override String get homeSummaryOverduePaymentsCaption =>
      'Overdue Payment Count';
  @override String get homeSummaryNextLessonLabel =>
      'My Next Lesson/Lessons';
  @override String get homeSummaryNextLessonEmpty => 'No upcoming lessons';
  @override String get homeSummaryRecentAttendanceTitle => 'Recent attendance';
  @override String get homeSummaryShowMore => 'Show more';
  @override String get homeSummaryShowLess => 'Show less';
  @override String get homePackageRightsDonutTitle => 'My packages';
  @override String get homePackageRightsDonutRemainingLegend => 'Remaining';
  @override String get homePackageRightsDonutUsedLegend => 'Used';
  @override String get homePackageRightsDonutEmptyStateLine =>
      'No active packages with lesson credits';
  @override String get homePackageNearExpiryWarning =>
      'Your package is ending soon';
  @override String get nearExpiryPackagesListTitle =>
      'Packages ending soon';
  @override String get homeRemindersSectionTitle => 'Reminders';
  @override String get homeRemindersEmptyState =>
      'No upcoming payments or announcements.';
  @override String get homeRemindersSeeAll => 'See all';
  @override String get homeReminderPaymentDueToday => 'Today';
  @override String get homeReminderPaymentDueTomorrow => 'Tomorrow';
  @override String homeReminderPaymentDueInDays(int days) => 'In $days days';
  @override String get homeRemindersUpcomingPaymentsSubtitle =>
      'Upcoming payments';
  @override String get homeRemindersAnnouncementsSubtitle => 'Announcements';
  @override String get homeStatementChartTitle => 'Statement Overview';
  @override String get homeStatementChartSubtitle =>
      'Last 6 months — monthly sales and collections';
  @override String get homeStatementChartEmpty =>
      'No chartable movements in this period';
  @override String get homeStatementChartNoDebtLine =>
      'You have no outstanding debt';
  @override String get summaryHintShort =>
      'Overview Of Packages, Collections, Attendance, Planned Payments And Today\'s Lessons.';
  @override String get summaryRowActivePackages => 'Active packages';
  @override String get summaryRowLessonsToday => 'Today\'s lessons';
  @override String get summaryRowPlannedPayments => 'Planned payments (today)';
  @override String get summaryRowPackageRegistrationsToday =>
      'Package registrations today';
  @override String get summaryRowCollectionsToday => 'Collections today';
  @override String get summaryRowAttendanceToday => 'Attendance today';
  @override String get summaryValueNone => '—';
  @override String get summaryTransactions => 'transactions';
  @override String get summaryAttendanceRecords => 'records';
  @override String get summaryNoActivityToday =>
      'No Activity To Show For Today.';
  @override String get summaryUnitLesson => 'Lessons';
  @override String get summaryUnitPlannedPayment => 'Planned Payments';
  @override String get summaryUnitPackageSale => 'Package Registrations';
  @override String get summaryUnitCollection => 'Collections';
  @override String get summaryUnitStatementMovements =>
      'Financial Statement Items';
  @override String get summaryUnitAttendance => 'Attendance';
  @override String get summaryPopupFootnotePlannedAndStatement =>
      'Below: Today\'s Planned Payments And Sales/Collection Lines From Your Financial Statement.';
  @override String get summaryRowBadgePlannedPayment => 'Planned Payment';
  @override String get summaryRowBadgeStatementMovement => 'Statement';
  @override String get summaryRowBadgeStatementSale => 'Sale';
  @override String get summaryRowBadgeStatementCollection => 'Collection';
  @override String get summaryRowBadgeMyLessons => 'My Lessons';
  @override String get packageInfo => 'Package\nInfo';
  @override String get activePackagesListTitle => 'Active Packages';
  @override String get overduePaymentsListTitle => 'Overdue Payments';
  @override String get nearDuePaymentsListTitle => 'Due Today & Soon';
  @override String get myAttendance => 'Attendance';
  @override String get financialStatement => 'Financial\nStatement';
  @override String get lessonSchedule => 'Lesson\nSchedule';
  @override String get guardianInfo => 'Guardian\nInfo';
  @override String get invoiceInfo => 'Invoice\nInfo';
  @override String get invoiceRecipientTypeIndividual => 'Individual';
  @override String get invoiceRecipientTypeCorporate => 'Corporate';
  @override String get invoiceRecipientTypeSoleTrader => 'Sole Trader';
  @override String get invoiceVkn => 'Tax ID';
  @override String get invoiceTckn => 'ID No';
  @override String get invoiceTaxOffice => 'Tax Office';
  @override String get invoiceCompanyTitle => 'Company Name';
  @override String get invoiceDefaultBadge => 'Default';
  @override String get scheduledPayments => 'Scheduled\nPayments';
  @override String get profileMenuMyPackages => 'My Packages';
  @override String get profileMenuLessonScheduleTitle => 'Lesson Schedule';
  @override String get profileMenuPlannedPaymentTitle => 'Scheduled Payment';
  @override String get profileMenuStatementTitle => 'Financial Statement';
  @override String get profileMenuInvoiceInfoTitle => 'Billing Information';
  @override String get profileMenuGuardianInfoTitle => 'Guardian Information';
  @override String get debt => 'Debt';
  @override String get credit => 'Credit';
  @override String get balance => 'Balance';
  @override String get dueDate => 'Due Date';
  @override String get statusLabel => 'Status';
  @override String get paidStatus => 'Paid';
  @override String get unpaidStatus => 'Unpaid';
  @override String get overdueStatus => 'Overdue';
  @override String get saleLabel => 'Sale';
  @override String get collectionLabel => 'Collection';
  @override String get packagePrice => 'Package Price';
  @override String get netPrice => 'Net Price';
  @override String get registrationDate => 'Registration Date';
  @override String get endDate => 'End Date';
  @override String get unitPrice => 'Unit Price';
  @override String get totalPrice => 'Total Price';
  @override String get discountLabel => 'Discount';
  @override String get packageNameLabel => 'Package Name';
  @override String get quantity => 'Quantity';
  @override String get activeStatus => 'Active';
  @override String get expiredStatus => 'Expired';
  @override String get relationship => 'Relationship';
  @override String get location => 'Location';
  @override String get guardianName => 'Guardian Name';
  @override String get studentInfo => 'Student Info';

  @override Map<String, String> get relationshipLabels => const {
    'parent': 'Parent',
    'mother': 'Mother',
    'father': 'Father',
    'sibling': 'Sibling',
    'spouse': 'Spouse',
    'grandparent': 'Grandparent',
    'uncle_aunt': 'Uncle/Aunt',
    'other': 'Other',
    'anne': 'Mother',
    'anna': 'Mother',
    'baba': 'Father',
    'kardeş': 'Sibling',
    'eş': 'Spouse',
    'ebeveyn': 'Parent',
    'veli': 'Guardian',
    'dede': 'Grandfather',
    'büyükanne': 'Grandmother',
    'büyükbaba': 'Grandfather',
    'amca': 'Uncle',
    'dayı': 'Uncle',
    'teyze': 'Aunt',
    'hala': 'Aunt',
    'diğer': 'Other',
  };

  @override String get primaryGuardian => 'Primary Guardian';
  @override String get note => 'Note';
  @override String get call => 'Call';
  @override String get guardianSecondaryPhone => 'Secondary phone';
  @override String get guardianProfessionGroupField => 'Profession group';
  @override String get guardianProvinceField => 'Province';
  @override String get guardianDistrictField => 'District';
  @override String get guardianAddressField => 'Address';

  @override Map<String, String> get guardianProfessionGroupLabels => const {
        'health_wellness': 'Health & wellness',
        'education': 'Education',
        'it_technology': 'IT & technology',
        'finance_business': 'Finance & business',
        'legal_advocacy': 'Legal',
        'engineering_technical': 'Engineering & technical',
        'architecture_construction': 'Architecture & construction',
        'agriculture_food': 'Agriculture & food',
        'manufacturing_industry': 'Manufacturing & industry',
        'retail_service': 'Retail & service',
        'hospitality_tourism': 'Hospitality & tourism',
        'transport_logistics': 'Transport & logistics',
        'energy_utilities': 'Energy & utilities',
        'media_marketing': 'Media & marketing',
        'hr_administration': 'HR & administration',
        'public_sector': 'Public sector',
        'security_defense': 'Security & defense',
        'science_research': 'Science & research',
        'nonprofit_ngo': 'Nonprofit & NGO',
        'freelance_art': 'Freelance & arts',
        'homemaker': 'Homemaker',
        'student_retired': 'Student or retired',
        'unemployed': 'Unemployed',
        'other': 'Other',
      };

  @override String get lessonAttendance => 'Lesson Attendance';
  @override String get lesson => 'Lesson';
  @override String get teacher => 'Teacher';
  @override String get classroom => 'Classroom';
  @override String get date => 'Date';
  @override String get time => 'Time';
  @override String get attendanceStatus => 'Attendance';
  @override String get attended => 'Attended';
  @override String get notAttended => 'Not Attended';
  @override String get burned => 'Burned';
  @override String get deducted => 'Deducted';
  @override String get notDeducted => 'Not Deducted';
  @override String get actionLabel => 'Action';
  @override String get changeLabel => 'Change';
  @override String get remainAfter => 'Remaining';
  @override String get noReservations => 'No lesson attendance records found';
  @override String get noLogs => 'No transaction history found';
  @override String get makeupLesson => 'Makeup lesson';
  @override String get lessonTypeGroupShort => 'Group';
  @override String get lessonTypeIndividualShort => 'Private';
  @override String get cancelledLesson => 'Cancelled lesson';
  @override String get noAttendanceRecords => 'No attendance records found';
  @override Map<String, String> get logActionLabels => const {
    'manual_deduction': 'Manual Deduction',
    'burn': 'Burn',
    'unburn': 'Unburn',
    'attendance': 'Attendance',
    'attendance_removed': 'Attendance Removed',
    'attendance_deduction': 'Attendance Deduction',
    'attendance_refund': 'Attendance Refund',
  };

  @override Map<String, String> get paymentTypeLabels => const {
    'NAKIT': 'Cash',
    'KREDI_KARTI': 'Credit Card',
    'EFT_HAVALE': 'Bank Transfer',
    'ONLINE_ODEME': 'Online Payment',
  };
  @override String get paymentType => 'Payment Type';
  @override String get paidDate => 'Payment Date';
  @override String get paidExplanation => 'Description';

  @override Map<String, String> get professionLabels => const {
    'fitness_trainer': 'Fitness Trainer',
    'plates_trainer': 'Pilates Trainer',
    'kickbox_trainer': 'Kickbox Trainer',
    'yoga_trainer': 'Yoga Trainer',
    'zumba_trainer': 'Zumba Trainer',
    'bungee_fly_trainer': 'Bungee Fly Trainer',
    'pound_trainer': 'Pound Trainer',
    'dietician': 'Dietician',
    'physiotherapist': 'Physiotherapist',
    'cycle': 'Cycle Trainer',
    'head_coach': 'Head Coach',
    'dance_coach': 'Dance Coach',
  };
}

// ─────────────────────────────────────────────────────────────
// MusicSchoolLabelsEn
// ─────────────────────────────────────────────────────────────

class MusicSchoolLabelsEn extends GymLabelsEn {
  const MusicSchoolLabelsEn();

  @override String get birthDateFormatDash => 'DD-MM-YYYY';

  @override String get member => 'Student';
  @override String get trainer => 'Teacher';
  @override String get groupLesson => 'Lesson';
  @override String get personalTraining => 'Private Lesson';
  @override String get fitnessProgram => 'Music Program';
  @override String get bodyMeasurement => 'Progress Tracking';
  @override String get diet => 'Nutrition';
  @override String get memberCard => 'Student Card';
  @override String get enrollment => 'Student Enrollment';
  @override String get members => 'Students';
  @override String get employees => 'Teachers';
  @override String get movementCatalog => 'Exercise Catalog';

  @override String get noActiveMembership => 'You Have No Active Enrollment';
  @override String get trainerRoster => 'Teacher Roster';
  @override String get groupLessonRules => 'Lesson Rules';
  @override String get groupLessons => 'Lessons';
  @override String get groupLessonDetail => 'Lesson Detail';
  @override String get purchasedMembers => 'Lesson Purchasers';
  @override String get exerciseList => 'My\nExercises';
  @override String get measurementInfo => 'Progress\nTracking';
  @override String get nutritionInfo => 'My\nNutrition';
  @override String get selectTrainer => 'Select Teacher';
  @override String get subscriptionInfo => 'Enrollment Info';
  @override String get membershipRules => 'Enrollment Rules';
  @override String get membershipFrozen => '(Enrollment Frozen)';
  @override String get myMeasurements => 'My Progress';
  @override String get addMeasurement => 'Add Progress Record';
  @override String get deleteMeasurement => 'Delete Record';
  @override String get deleteMeasurementConfirm => 'Are you sure you want to delete this record?';
  @override String get measurementDeletedSuccess => 'Record deleted successfully.';
  @override String get noMeasurementData => 'No data to display.';

  @override Map<String, String> get professionLabels => const {
    'piano_teacher': 'Piano Teacher',
    'guitar_teacher': 'Guitar Teacher',
    'classical_guitar_teacher': 'Classical Guitar Teacher',
    'electric_guitar_teacher': 'Electric Guitar Teacher',
    'bass_guitar_teacher': 'Bass Guitar Teacher',
    'violin_teacher': 'Violin Teacher',
    'drum_teacher': 'Drums Teacher',
    'flute_teacher': 'Flute Teacher',
    'viola_teacher': 'Viola Teacher',
    'cello_teacher': 'Cello Teacher',
    'vocal_teacher': 'Vocal Teacher',
    'solfege_teacher': 'Solfège Teacher',
    'baglama_teacher': 'Bağlama Teacher',
    'ud_teacher': 'Oud Teacher',
    'keyboard_teacher': 'Keyboard Teacher',
    'music_theory_teacher': 'Music Theory Teacher',
    'composition_teacher': 'Composition Teacher',
    'music_instructor': 'Music Instructor',
    'art_teacher': 'Art Teacher',
    'drama_teacher': 'Drama Teacher',
  };
}

// ─────────────────────────────────────────────────────────────
// SwimmingCourseLabelsEn
// ─────────────────────────────────────────────────────────────

class SwimmingCourseLabelsEn extends GymLabelsEn {
  const SwimmingCourseLabelsEn();

  /// Swimming course: lesson summary wording without “group”.
  @override String get todayGroupLessons => 'Today\'s lessons';

  @override String get member => 'Trainee';
  @override String get groupLesson => 'Swimming Lesson';
  @override String get personalTraining => 'Private Swimming Lesson';
  @override String get fitnessProgram => 'Training Program';
  @override String get bodyMeasurement => 'Progress Tracking';
  @override String get memberCard => 'Trainee Card';
  @override String get enrollment => 'Trainee Enrollment';
  @override String get members => 'Trainees';

  @override String get noActiveMembership => 'You Have No Active Course Enrollment';
  @override String get trainerRoster => 'Trainer Roster';
  @override String get groupLessonRules => 'Swimming Lesson Rules';
  @override String get groupLessons => 'Swimming\nLessons';
  @override String get groupLessonDetail => 'Swimming Lesson Detail';
  @override String scheduleListHeaderForDate(String formattedDate) =>
      'Swimming lessons — $formattedDate';
  @override String get trainerScheduleAddLessonTitle => 'Add swimming lesson';
  @override String get trainerScheduleEditLessonTitle => 'Edit swimming lesson';
  @override String get trainerScheduleDeleteLessonConfirm =>
      'Do you want to delete this swimming lesson?';
  @override String get trainerScheduleLessonDeleted => 'Swimming lesson deleted';
  @override String get trainerScheduleDeleteLessonFailed =>
      'Could not delete swimming lesson';
  @override String get trainerTodayDashboardQuickReservationSectionTitle =>
      'Today\'s attendance';
  @override String get subscriptionInfo => 'Course Info';
  @override String get membershipRules => 'Course Rules';
  @override String get membershipFrozen => '(Course Frozen)';
  @override String get measurementInfo => 'Progress\nTracking';
  @override String get myMeasurements => 'My Progress';
  @override String get addMeasurement => 'Add Progress Record';

  @override Map<String, String> get professionLabels => const {
    'swimming_trainer': 'Swimming Trainer',
    'head_coach': 'Head Coach',
    'physiotherapist': 'Physiotherapist',
  };
}
