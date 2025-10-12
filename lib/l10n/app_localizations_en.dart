// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Invoiz';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get businessDetails => 'Business Details';

  @override
  String get subscriptionPlans => 'Subscription Plans';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get gujarati => 'ગુજરાતી';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get manageBusinessInformation => 'Manage your business information';

  @override
  String get upgradeOrManageSubscription =>
      'Upgrade or manage your subscription';

  @override
  String get subscriptionStatus => 'Subscription Status';

  @override
  String get noActiveSubscription => 'No active subscription';

  @override
  String get activeSubscription => 'Active Subscription';

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get businessRegistered => 'Business Registered';

  @override
  String get notRegistered => 'Not registered';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessType => 'Business Type';

  @override
  String get businessAddress => 'Business Address';

  @override
  String get businessInformation => 'Business Information';

  @override
  String get contactDetails => 'Contact Details';

  @override
  String get refreshBusinessDetails => 'Refresh business details';

  @override
  String get businessDetailsRefreshed => 'Business details refreshed';

  @override
  String get editBusinessDetails => 'Edit Business Details';

  @override
  String get requestVerification => 'Request Verification';

  @override
  String get editBusinessFeatureComingSoon =>
      'Edit business feature coming soon!';

  @override
  String get businessVerificationFeatureComingSoon =>
      'Business verification feature coming soon!';

  @override
  String get noBusinessRegistered => 'No Business Registered';

  @override
  String get registerBusinessToAccessFeatures =>
      'Register your business to access all features';

  @override
  String get registerBusiness => 'Register Business';

  @override
  String get businessRegistrationFeatureComingSoon =>
      'Business registration feature coming soon!';

  @override
  String get street => 'Street';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get pincode => 'Pincode';

  @override
  String get country => 'Country';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get website => 'Website';

  @override
  String get businessId => 'Business ID';

  @override
  String get status => 'Status';

  @override
  String get gstNumber => 'GST Number';

  @override
  String get upiId => 'UPI ID';

  @override
  String get verified => 'Verified';

  @override
  String get pending => 'Pending';

  @override
  String get products => 'Products';

  @override
  String get invoices => 'Invoices';

  @override
  String get createInvoice => 'Create Invoice';

  @override
  String get selectProducts => 'Select Products';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get addProduct => 'Add Product';

  @override
  String get productName => 'Product Name';

  @override
  String get productPrice => 'Product Price';

  @override
  String get productQuantity => 'Quantity';

  @override
  String get category => 'Category';

  @override
  String get cost => 'Cost';

  @override
  String get unit => 'Unit';

  @override
  String get stockQuantity => 'Stock Quantity';

  @override
  String get minimumStock => 'Minimum Stock';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Customer Phone';

  @override
  String get customerEmail => 'Customer Email';

  @override
  String get customerAddress => 'Customer Address';

  @override
  String get invoicePreview => 'Invoice Preview';

  @override
  String get invoiceNumber => 'Invoice Number';

  @override
  String get invoiceDate => 'Invoice Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get upi => 'UPI';

  @override
  String get bank => 'Bank Transfer';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get generateQrCode => 'Generate QR Code';

  @override
  String get scanToPay => 'Scan to Pay';

  @override
  String get qrCodeForPayment => 'QR Code for Payment';

  @override
  String get shareInvoice => 'Share Invoice';

  @override
  String get downloadInvoice => 'Download Invoice';

  @override
  String get printInvoice => 'Print Invoice';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get amount => 'Amount';

  @override
  String get enterQuantity => 'Enter Quantity';

  @override
  String get invalidQuantity => 'Invalid quantity';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get inStock => 'In Stock';

  @override
  String availableStock(int count) {
    return 'Available Stock: $count';
  }

  @override
  String get discountPercentage => 'Discount (%)';

  @override
  String get discountAmount => 'Discount Amount';

  @override
  String get applyDiscount => 'Apply Discount';

  @override
  String get removeDiscount => 'Remove Discount';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get addNewCustomer => 'Add New Customer';

  @override
  String get customerRequired => 'Customer details are required';

  @override
  String get productsRequired => 'Please add at least one product';

  @override
  String get invoiceCreated => 'Invoice created successfully';

  @override
  String get invoiceCreationFailed => 'Failed to create invoice';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signInHere => 'Sign in here';

  @override
  String get signUpHere => 'Sign up here';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get getStarted => 'Get Started';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get billTo => 'Bill To:';

  @override
  String get items => 'Items:';

  @override
  String get product => 'Product';

  @override
  String get qty => 'Qty';

  @override
  String get per => 'per';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get paymentInformation => 'Payment Information:';

  @override
  String get paymentMethodLabel => 'Payment Method:';

  @override
  String get online => 'Online (UPI)';

  @override
  String get thankYouBusiness => 'Thank you for your business!';

  @override
  String get generatedOn => 'Generated on';

  @override
  String get invoiceGenerated => 'Invoice Generated';

  @override
  String get fullScreen => 'Full Screen';

  @override
  String get exitFullScreen => 'Exit Full Screen';

  @override
  String get send => 'SEND';

  @override
  String get print => 'PRINT';

  @override
  String get createNewInvoice => 'Create New Invoice';

  @override
  String get reports => 'Reports';

  @override
  String get recalculateReports => 'Recalculate Reports';

  @override
  String get cleanupOldData => 'Cleanup Old Data';

  @override
  String get retry => 'Retry';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get currentMonth => 'Current Month';

  @override
  String get currentYear => 'Current Year';

  @override
  String get revenue => 'Revenue';

  @override
  String get investment => 'Investment';

  @override
  String get profit => 'Profit';

  @override
  String get selectYear => 'Select Year';

  @override
  String get noDataAvailable => 'No Data Available';

  @override
  String get margin => 'Margin';

  @override
  String get recalculatingReports => 'Recalculating reports...';

  @override
  String get dataCleanedUp => 'Old data has been cleaned up';

  @override
  String get readyToManage => 'Ready to manage your business today?';

  @override
  String get upgradeToAccess => 'Upgrade to access all features';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get newInvoice => 'New invoice';

  @override
  String get viewProducts => 'View Products';

  @override
  String get manageStock => 'Manage stock';

  @override
  String get overview => 'Overview';

  @override
  String get totalRevenue => 'Monthly Revenue';

  @override
  String get tapToViewDetails => 'Tap to view details';
}
