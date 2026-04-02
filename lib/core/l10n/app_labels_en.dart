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
  @override String get attendanceDescription => 'Find the member by QR code, NFC card or card number to take attendance.';
  @override String get attendanceScanQr => 'Scan QR Code';
  @override String get scanMemberQr => 'Scan member QR code';
  @override String get readNfcCard => 'Scan NFC Card';
  @override String get nfcComingSoon => 'NFC card scanning will be available soon.';
  @override String get nfcReadDescription => 'Hold the member NFC card near the device';
  @override String get nfcNotAvailable => 'NFC is not available on this device.';
  @override String get nfcReadingCard => 'Waiting for card... Please hold the NFC card near the device.';
  @override String get nfcReadError => 'Could not read NFC card, please try again.';
  @override String get cardNumber => 'Card Number';
  @override String get enterCardNumber => 'Enter 10-digit card number';
  @override String get searchMember => 'Search Member';
  @override String get cardNumberInvalid => 'Card number must be 10 digits';
  @override String get invalidOrExpiredQr => 'Invalid or expired QR code';
  @override String get memberNotFoundByCard => 'No member found for this card';
  @override String get noActivePackage => 'No active package';
  @override String get burnConfirm => 'Are you sure you want to deduct a session?';
  @override String get burnSuccess => 'Session deducted successfully';
  @override String get burnError => 'An error occurred during session deduction';
  @override String get scanNewMember => 'Scan New Member';
  @override String get activePackages => 'Active Packages';
  @override String get packageDeductions => 'Package Deductions';
  @override String get undoDeduction => 'Undo';
  @override String get undoDeductionConfirm => 'Are you sure you want to undo this deduction?';
  @override String get undoDeductionSuccess => 'Deduction undone successfully';
  @override String get undoDeductionError => 'An error occurred while undoing the deduction';
  @override String get noDeductionHistory => 'No deduction history found';
  @override String get onlyTodayCanUndo => 'Only today\'s records can be undone';

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

  // Profile Menu
  @override String get myProfile => 'My Profile';
  @override String get paymentHistory => 'Payment History';
  @override String get pastEntryHistory => 'Past Entry History';
  @override String get facilityDetails => 'Facility Details';
  @override String get trainerRoster => 'Trainer Roster';
  @override String get suggestionComplaint => 'Suggestions & Complaints';
  @override String get groupLessonRules => 'Group Lesson Rules';
  @override String get quickReservationRules => 'Quick Reservation Rules';
  @override String get facilityRules => 'Facility Rules';
  @override String get membershipRules => 'Membership Rules';
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

  // Suggestion / Complaint
  @override String get suggestionComplaintHistory => 'Suggestion & Complaint History';
  @override String get createSuggestionComplaint => 'Create Suggestion & Complaint';
  @override String get title => 'Title';
  @override String get topicTitle => 'Enter Topic Title...';
  @override String get suggestionAndComplaint => 'Suggestion & Complaint';
  @override String get writeSuggestionComplaint => 'Write Your Suggestion & Complaint...';
  @override String get sentSuccess => 'Sent successfully';
  @override String get sendFailed => 'Sending failed, please try again later.';
  @override String get fillAllFields => 'Please fill in all fields';

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
