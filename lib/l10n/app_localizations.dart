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
