const String kLogFileName = 'app.log';

/// Play Store applicationId of the published Android app.
/// Used by the in-app review flow to deep-link to the store listing.
const String kGooglePlayIdentifier = 'com.solguruz.skelter';

/// Numeric App Store ID from App Store Connect (e.g. `'1234567890'`).
/// Placeholder — replace before iOS release. Not read by the native review
/// dialog (StoreKit uses bundle id); only consumed by `launchStore()`.
const String kAppStoreIdentifier = '0000000000';

const kMimeTypeVideo = 'video/';
const kMimeTypeImage = 'image/';
const kSVGWithDot = '.svg';
const kPNGWithDot = '.png';

const kPdf = 'pdf';
const kText = 'txt';
const kDoc = 'doc';
const kMp4 = 'mp4';

/// MIME types for identifying PDF, TXT, Word DOC, and MP4 files
const kPdfMimeType = 'application/pdf';
const kTextMimeType = 'text/plain';
const kDocMimeType = 'application/msword';
const kVideoMimeType = 'video/mp4';

/// PDF files start with "%PDF-" as a magic number to identify real PDFs, and
/// MP4/ISO media files contain "ftyp" near the header to verify valid media format
const String kPdfFileSignature = '%PDF-';
const String kFileTypeBoxSignature = 'ftyp';

/// Signature bytes that identify a Microsoft OLE Compound File (used by legacy
/// Microsoft Office formats such as `.doc`, `.xls`, `.ppt`).
/// We use this constant for file type detection/validation — e.g., to check
/// whether a given file is a valid legacy Office document before processing.
const List<int> kDocOleFileSignature = [
  0xD0,
  0xCF,
  0x11,
  0xE0,
  0xA1,
  0xB1,
  0x1A,
  0xE1,
];

const String kSomethingWentWrong = 'Oops! Something went wrong';

// Chat messaging constants
const String kHeroAnimationPrefix = 'fullscreen_image_0';

// Regex patterns
final kEmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

// Auth exception codes
const kAuthWeakPasswordException = 'weak-password';
const kAuthUserNotFoundException = 'user-not-found';
const kAuthWrongPasswordException = 'wrong-password';
const kAuthTooManyRequestsException = 'too-many-requests';
const kAuthInvalidCodeException = 'invalid-verification-code';
const kAuthSessionExpiredException = 'session-expired';
const kAuthSessionEmailAlreadyInUse = 'email-already-in-use';
const kAuthRequiresRecentLogin = 'requires-recent-login';

// Supabase database exception codes
const String kDatabasePermissionDenied = 'permission-denied';
const String kDatabaseNotFound = 'not-found';
const String kDatabaseAlreadyExists = 'already-exists';
const String kDatabaseResourceExhausted = 'resource-exhausted';
const String kDatabaseUnauthenticated = 'unauthenticated';
const String kDatabaseUnavailable = 'unavailable';
const String kDatabaseCancelled = 'cancelled';
const String kDatabaseDeadlineExceeded = 'deadline-exceeded';
const String kDatabaseInvalidArgument = 'invalid-argument';
const String kDatabaseInternal = 'internal';
const String kDatabaseDataLoss = 'data-loss';

// Network/SSL pinning constants
const String kConnectionIsNotSecureError = 'Connection is not secure';

// Cache Api Response
const String kApiCache = 'api_cache';

// Date formats
const String kDefaultDateFormat = 'dd-MM-yyyy';
const String kDefaultTimeFormat12Hour = 'hh:mm a';
const String kProduct = 'product';
const String kHome = 'home';

// RevenueCat subscription constants
const revenueCatTestStoreApiKey = 'REVENEUCAT_TEST_STORE_API_KEY';
const revenueCatMonthly = 'monthly';

// Invoice constants
const String expectedDeliveryDate = '9:00 am, Sat, 15 Apr';
const String paymentMethodAxis = 'Axis Bank **** **** **** 8395';

// Performance Monitoring Traces
const String kTraceApiGetProducts = 'api_get_products';
const String kTraceLoginEmailPassword = 'login_email_password';
const String kTraceLoginGoogle = 'login_google';
const String kTraceLoginApple = 'login_apple';
const String kTraceLoginPhone = 'login_phone';
const String kTraceSignupEmail = 'signup_email';
const String kTraceApiGetProductDetail = 'api_get_product_detail';
const String kTraceAIDescriptionGeneration = 'ai_description_generation';
const String kTraceAIVisionGeneration = 'ai_vision_generation';
const String kTraceCheckoutProcess = 'checkout_process';
const String kTraceDeleteAccount = 'delete_account';
const String kTraceSignOut = 'sign_out';
const String kTraceFetchSubscriptionPackages = 'fetch_subscription_packages';
const String kTracePurchaseSubscription = 'purchase_subscription';
const String kTraceRestoreSubscription = 'restore_subscription';
const String kTraceApiGetOrders = 'api_get_orders';

// Performance Monitoring Trace Attribute Keys
const String kTraceAttrSuccess = 'success';
const String kTraceAttrError = 'error';
