import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Invoiz'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Business details menu item
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get businessDetails;

  /// Subscription plans menu item
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionPlans;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Language settings menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Gujarati language option
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get gujarati;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Business details subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your business information'**
  String get manageBusinessInformation;

  /// Subscription plans subtitle
  ///
  /// In en, this message translates to:
  /// **'Upgrade or manage your subscription'**
  String get upgradeOrManageSubscription;

  /// Subscription status label
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get subscriptionStatus;

  /// No subscription message
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get noActiveSubscription;

  /// Active subscription label
  ///
  /// In en, this message translates to:
  /// **'Active Subscription'**
  String get activeSubscription;

  /// Days remaining in subscription
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(int count);

  /// Business registered status
  ///
  /// In en, this message translates to:
  /// **'Business Registered'**
  String get businessRegistered;

  /// Business not registered status
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get notRegistered;

  /// Business name label
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// Business type label
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessType;

  /// Business address label
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// Business information section title
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInformation;

  /// Contact details section title
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// Refresh business details tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh business details'**
  String get refreshBusinessDetails;

  /// Business details refreshed message
  ///
  /// In en, this message translates to:
  /// **'Business details refreshed'**
  String get businessDetailsRefreshed;

  /// Edit business details button
  ///
  /// In en, this message translates to:
  /// **'Edit Business Details'**
  String get editBusinessDetails;

  /// Request verification button
  ///
  /// In en, this message translates to:
  /// **'Request Verification'**
  String get requestVerification;

  /// Edit business feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Edit business feature coming soon!'**
  String get editBusinessFeatureComingSoon;

  /// Business verification feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Business verification feature coming soon!'**
  String get businessVerificationFeatureComingSoon;

  /// No business registered title
  ///
  /// In en, this message translates to:
  /// **'No Business Registered'**
  String get noBusinessRegistered;

  /// Register business message
  ///
  /// In en, this message translates to:
  /// **'Register your business to access all features'**
  String get registerBusinessToAccessFeatures;

  /// Register business button
  ///
  /// In en, this message translates to:
  /// **'Register Business'**
  String get registerBusiness;

  /// Business registration feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Business registration feature coming soon!'**
  String get businessRegistrationFeatureComingSoon;

  /// Street address label
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// City label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// State label
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// Pincode label
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// Country label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Website label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Business ID label
  ///
  /// In en, this message translates to:
  /// **'Business ID'**
  String get businessId;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// GST number label
  ///
  /// In en, this message translates to:
  /// **'GST Number'**
  String get gstNumber;

  /// UPI ID label
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// Verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Products tab label
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Invoices tab label
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// Create invoice button
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// Select products title
  ///
  /// In en, this message translates to:
  /// **'Select Products'**
  String get selectProducts;

  /// Search products placeholder
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No products found message
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Add product button
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Product name label
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Product price label
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get productPrice;

  /// Product quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productQuantity;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Cost label
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// Unit label
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Stock quantity label
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// Minimum stock label
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock'**
  String get minimumStock;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Info message
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Customer details title
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// Customer name label
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// Customer phone label
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get customerPhone;

  /// Customer email label
  ///
  /// In en, this message translates to:
  /// **'Customer Email'**
  String get customerEmail;

  /// Customer address label
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get customerAddress;

  /// Invoice preview title
  ///
  /// In en, this message translates to:
  /// **'Invoice Preview'**
  String get invoicePreview;

  /// Invoice number label
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// Invoice date label
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoiceDate;

  /// Due date label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Subtotal label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Discount label
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Cash payment method
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Card payment method
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// UPI payment method
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// Bank transfer payment method
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bank;

  /// Select payment method title
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// Generate QR code button
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get generateQrCode;

  /// Scan to pay title
  ///
  /// In en, this message translates to:
  /// **'Scan to Pay'**
  String get scanToPay;

  /// QR code for payment title
  ///
  /// In en, this message translates to:
  /// **'QR Code for Payment'**
  String get qrCodeForPayment;

  /// Share invoice button
  ///
  /// In en, this message translates to:
  /// **'Share Invoice'**
  String get shareInvoice;

  /// Download invoice button
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// Print invoice button
  ///
  /// In en, this message translates to:
  /// **'Print Invoice'**
  String get printInvoice;

  /// Quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Price label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Enter quantity dialog title
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get enterQuantity;

  /// Invalid quantity error
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity'**
  String get invalidQuantity;

  /// Out of stock label
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// Low stock label
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// In stock label
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// Available stock label
  ///
  /// In en, this message translates to:
  /// **'Available Stock: {count}'**
  String availableStock(int count);

  /// Discount percentage label
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get discountPercentage;

  /// Discount amount label
  ///
  /// In en, this message translates to:
  /// **'Discount Amount'**
  String get discountAmount;

  /// Apply discount button
  ///
  /// In en, this message translates to:
  /// **'Apply Discount'**
  String get applyDiscount;

  /// Remove discount button
  ///
  /// In en, this message translates to:
  /// **'Remove Discount'**
  String get removeDiscount;

  /// Select customer button
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// Add new customer button
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get addNewCustomer;

  /// Customer required error
  ///
  /// In en, this message translates to:
  /// **'Customer details are required'**
  String get customerRequired;

  /// Products required error
  ///
  /// In en, this message translates to:
  /// **'Please add at least one product'**
  String get productsRequired;

  /// Invoice created success message
  ///
  /// In en, this message translates to:
  /// **'Invoice created successfully'**
  String get invoiceCreated;

  /// Invoice creation failed error
  ///
  /// In en, this message translates to:
  /// **'Failed to create invoice'**
  String get invoiceCreationFailed;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// First name label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Mobile number label
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// Email address label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Don't have account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign in here link
  ///
  /// In en, this message translates to:
  /// **'Sign in here'**
  String get signInHere;

  /// Sign up here link
  ///
  /// In en, this message translates to:
  /// **'Sign up here'**
  String get signUpHere;

  /// Welcome message in dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// Get started title
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Invalid email error
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// Invalid phone error
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// Password too short error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// Passwords do not match error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Field required error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Login successful message
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// Registration successful message
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// Login failed error
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// Registration failed error
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// Bill To label
  ///
  /// In en, this message translates to:
  /// **'Bill To:'**
  String get billTo;

  /// Items label
  ///
  /// In en, this message translates to:
  /// **'Items:'**
  String get items;

  /// Product column header
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// Quantity column header
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// Per unit label
  ///
  /// In en, this message translates to:
  /// **'per'**
  String get per;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Payment information section title
  ///
  /// In en, this message translates to:
  /// **'Payment Information:'**
  String get paymentInformation;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method:'**
  String get paymentMethodLabel;

  /// Online payment method
  ///
  /// In en, this message translates to:
  /// **'Online (UPI)'**
  String get online;

  /// Thank you message
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business!'**
  String get thankYouBusiness;

  /// Generated on timestamp label
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get generatedOn;

  /// Invoice generated screen title
  ///
  /// In en, this message translates to:
  /// **'Invoice Generated'**
  String get invoiceGenerated;

  /// Full screen tooltip
  ///
  /// In en, this message translates to:
  /// **'Full Screen'**
  String get fullScreen;

  /// Exit full screen tooltip
  ///
  /// In en, this message translates to:
  /// **'Exit Full Screen'**
  String get exitFullScreen;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'SEND'**
  String get send;

  /// Print button
  ///
  /// In en, this message translates to:
  /// **'PRINT'**
  String get print;

  /// Create new invoice button
  ///
  /// In en, this message translates to:
  /// **'Create New Invoice'**
  String get createNewInvoice;

  /// Reports screen title
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Recalculate reports menu item
  ///
  /// In en, this message translates to:
  /// **'Recalculate Reports'**
  String get recalculateReports;

  /// Cleanup old data menu item
  ///
  /// In en, this message translates to:
  /// **'Cleanup Old Data'**
  String get cleanupOldData;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Monthly tab label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly tab label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Current month label
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonth;

  /// Current year label
  ///
  /// In en, this message translates to:
  /// **'Current Year'**
  String get currentYear;

  /// Revenue label
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// Investment label
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// Profit label
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// Select year dropdown label
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No data available message
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get noDataAvailable;

  /// Margin label
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// Recalculating reports message
  ///
  /// In en, this message translates to:
  /// **'Recalculating reports...'**
  String get recalculatingReports;

  /// Data cleaned up message
  ///
  /// In en, this message translates to:
  /// **'Old data has been cleaned up'**
  String get dataCleanedUp;

  /// Ready to manage business message
  ///
  /// In en, this message translates to:
  /// **'Ready to manage your business today?'**
  String get readyToManage;

  /// Upgrade subscription message
  ///
  /// In en, this message translates to:
  /// **'Upgrade to access all features'**
  String get upgradeToAccess;

  /// Upgrade button text
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// New invoice subtitle
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get newInvoice;

  /// View products action title
  ///
  /// In en, this message translates to:
  /// **'View Products'**
  String get viewProducts;

  /// Manage stock subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage stock'**
  String get manageStock;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Monthly revenue card title
  ///
  /// In en, this message translates to:
  /// **'Monthly Revenue'**
  String get totalRevenue;

  /// Hint text for interactive cards
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
