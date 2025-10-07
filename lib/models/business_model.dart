class Business {
  final String businessId;
  final String businessName;
  final String businessType;
  final BusinessAddress businessAddress;
  final String? gstNumber;
  final String upiId;
  final ContactDetails? contactDetails;
  final Map<String, OperatingHours>? operatingHours;
  final String businessStatus;
  final String verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.businessId,
    required this.businessName,
    required this.businessType,
    required this.businessAddress,
    this.gstNumber,
    required this.upiId,
    this.contactDetails,
    this.operatingHours,
    required this.businessStatus,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      businessId: json['business_id'] ?? '',
      businessName: json['business_name'] ?? '',
      businessType: json['business_type'] ?? '',
      businessAddress: BusinessAddress.fromJson(json['business_address'] ?? {}),
      gstNumber: json['gst_number'],
      upiId: json['upi_id'] ?? '',
      contactDetails: json['contact_details'] != null
          ? ContactDetails.fromJson(json['contact_details'])
          : null,
      operatingHours: json['operating_hours'] != null
          ? _parseOperatingHours(json['operating_hours'])
          : null,
      businessStatus: json['business_status'] ?? 'Active',
      verificationStatus: json['verification_status'] ?? 'Pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  static Map<String, OperatingHours> _parseOperatingHours(Map<String, dynamic> json) {
    Map<String, OperatingHours> hours = {};
    json.forEach((day, value) {
      if (value is Map<String, dynamic>) {
        hours[day] = OperatingHours.fromJson(value);
      }
    });
    return hours;
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'business_name': businessName,
      'business_type': businessType,
      'business_address': businessAddress.toJson(),
      'gst_number': gstNumber,
      'upi_id': upiId,
      'contact_details': contactDetails?.toJson(),
      'operating_hours': operatingHours?.map((key, value) => MapEntry(key, value.toJson())),
      'business_status': businessStatus,
      'verification_status': verificationStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullAddress => businessAddress.fullAddress;

  bool get isVerified => verificationStatus == 'Verified';
  bool get isActive => businessStatus == 'Active';
  bool get hasGST => gstNumber != null && gstNumber!.isNotEmpty;
}

class BusinessAddress {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;

  BusinessAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
  });

  factory BusinessAddress.fromJson(Map<String, dynamic> json) {
    return BusinessAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }

  String get fullAddress => '$street, $city, $state - $pincode, $country';
}

class ContactDetails {
  final String? phone;
  final String? email;
  final String? website;

  ContactDetails({
    this.phone,
    this.email,
    this.website,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'website': website,
    };
  }
}

class OperatingHours {
  final String? open;
  final String? close;
  final bool isClosed;

  OperatingHours({
    this.open,
    this.close,
    this.isClosed = false,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      open: json['open'],
      close: json['close'],
      isClosed: json['is_closed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
      'is_closed': isClosed,
    };
  }

  String get displayText {
    if (isClosed) return 'Closed';
    if (open != null && close != null) {
      return '$open - $close';
    }
    return 'Not set';
  }
}

class BusinessType {
  static const List<String> types = [
    'Grocery',
    'Electronics',
    'Pharmacy',
    'Restaurant',
    'Clothing',
    'Hardware',
    'Stationery',
    'Mobile Shop',
    'Medical Store',
    'General Store',
    'Automobile',
    'Beauty & Cosmetics',
    'Books & Media',
    'Furniture',
    'Jewelry',
    'Sports & Fitness',
    'Toys & Games',
    'Other',
  ];

  static String getDisplayName(String type) {
    return types.contains(type) ? type : 'Other';
  }
}