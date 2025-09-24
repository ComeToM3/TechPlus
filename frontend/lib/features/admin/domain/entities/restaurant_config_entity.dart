/// Entité pour la configuration du restaurant
class RestaurantConfig {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final String phone;
  final String email;
  final String website;
  final String logo;
  final String coverImage;
  final List<OpeningHours> openingHours;
  final PaymentSettings paymentSettings;
  final CancellationPolicy cancellationPolicy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RestaurantConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.phone,
    required this.email,
    this.website = '',
    this.logo = '',
    this.coverImage = '',
    required this.openingHours,
    required this.paymentSettings,
    required this.cancellationPolicy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie avec des valeurs modifiées
  RestaurantConfig copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? logo,
    String? coverImage,
    List<OpeningHours>? openingHours,
    PaymentSettings? paymentSettings,
    CancellationPolicy? cancellationPolicy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      openingHours: openingHours ?? this.openingHours,
      paymentSettings: paymentSettings ?? this.paymentSettings,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'website': website,
      'logo': logo,
      'coverImage': coverImage,
      'openingHours': openingHours.map((h) => h.toJson()).toList(),
      'paymentSettings': paymentSettings.toJson(),
      'cancellationPolicy': cancellationPolicy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory RestaurantConfig.fromJson(Map<String, dynamic> json) {
    return RestaurantConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? '',
      openingHours: (json['openingHours'] as List)
          .map((h) => OpeningHours.fromJson(h as Map<String, dynamic>))
          .toList(),
      paymentSettings: PaymentSettings.fromJson(json['paymentSettings'] as Map<String, dynamic>),
      cancellationPolicy: CancellationPolicy.fromJson(json['cancellationPolicy'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Entité pour les heures d'ouverture
class OpeningHours {
  final String dayOfWeek;
  final bool isOpen;
  final String? openTime;
  final String? closeTime;
  final String? breakStartTime;
  final String? breakEndTime;
  final String notes;

  const OpeningHours({
    required this.dayOfWeek,
    required this.isOpen,
    this.openTime,
    this.closeTime,
    this.breakStartTime,
    this.breakEndTime,
    this.notes = '',
  });

  /// Crée une copie avec des valeurs modifiées
  OpeningHours copyWith({
    String? dayOfWeek,
    bool? isOpen,
    String? openTime,
    String? closeTime,
    String? breakStartTime,
    String? breakEndTime,
    String? notes,
  }) {
    return OpeningHours(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
      notes: notes ?? this.notes,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
      'breakStartTime': breakStartTime,
      'breakEndTime': breakEndTime,
      'notes': notes,
    };
  }

  /// Crée depuis un Map
  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      dayOfWeek: json['dayOfWeek'] as String,
      isOpen: json['isOpen'] as bool,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      breakStartTime: json['breakStartTime'] as String?,
      breakEndTime: json['breakEndTime'] as String?,
      notes: json['notes'] as String? ?? '',
    );
  }
}

/// Entité pour les paramètres de paiement
class PaymentSettings {
  final bool isStripeEnabled;
  final String? stripePublicKey;
  final String? stripeSecretKey;
  final bool isPayPalEnabled;
  final String? paypalClientId;
  final bool isCashEnabled;
  final bool isCardEnabled;
  final double depositPercentage;
  final String currency;
  final double taxRate;
  final bool isTaxIncluded;
  final String paymentTerms;

  const PaymentSettings({
    required this.isStripeEnabled,
    this.stripePublicKey,
    this.stripeSecretKey,
    required this.isPayPalEnabled,
    this.paypalClientId,
    required this.isCashEnabled,
    required this.isCardEnabled,
    required this.depositPercentage,
    required this.currency,
    required this.taxRate,
    required this.isTaxIncluded,
    required this.paymentTerms,
  });

  /// Crée une copie avec des valeurs modifiées
  PaymentSettings copyWith({
    bool? isStripeEnabled,
    String? stripePublicKey,
    String? stripeSecretKey,
    bool? isPayPalEnabled,
    String? paypalClientId,
    bool? isCashEnabled,
    bool? isCardEnabled,
    double? depositPercentage,
    String? currency,
    double? taxRate,
    bool? isTaxIncluded,
    String? paymentTerms,
  }) {
    return PaymentSettings(
      isStripeEnabled: isStripeEnabled ?? this.isStripeEnabled,
      stripePublicKey: stripePublicKey ?? this.stripePublicKey,
      stripeSecretKey: stripeSecretKey ?? this.stripeSecretKey,
      isPayPalEnabled: isPayPalEnabled ?? this.isPayPalEnabled,
      paypalClientId: paypalClientId ?? this.paypalClientId,
      isCashEnabled: isCashEnabled ?? this.isCashEnabled,
      isCardEnabled: isCardEnabled ?? this.isCardEnabled,
      depositPercentage: depositPercentage ?? this.depositPercentage,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      isTaxIncluded: isTaxIncluded ?? this.isTaxIncluded,
      paymentTerms: paymentTerms ?? this.paymentTerms,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'isStripeEnabled': isStripeEnabled,
      'stripePublicKey': stripePublicKey,
      'stripeSecretKey': stripeSecretKey,
      'isPayPalEnabled': isPayPalEnabled,
      'paypalClientId': paypalClientId,
      'isCashEnabled': isCashEnabled,
      'isCardEnabled': isCardEnabled,
      'depositPercentage': depositPercentage,
      'currency': currency,
      'taxRate': taxRate,
      'isTaxIncluded': isTaxIncluded,
      'paymentTerms': paymentTerms,
    };
  }

  /// Crée depuis un Map
  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      isStripeEnabled: json['isStripeEnabled'] as bool,
      stripePublicKey: json['stripePublicKey'] as String?,
      stripeSecretKey: json['stripeSecretKey'] as String?,
      isPayPalEnabled: json['isPayPalEnabled'] as bool,
      paypalClientId: json['paypalClientId'] as String?,
      isCashEnabled: json['isCashEnabled'] as bool,
      isCardEnabled: json['isCardEnabled'] as bool,
      depositPercentage: (json['depositPercentage'] as num).toDouble(),
      currency: json['currency'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
      isTaxIncluded: json['isTaxIncluded'] as bool,
      paymentTerms: json['paymentTerms'] as String,
    );
  }
}

/// Entité pour la politique d'annulation
class CancellationPolicy {
  final bool isRefundable;
  final int freeCancellationHours;
  final double cancellationFeePercentage;
  final String policyDescription;
  final List<CancellationRule> rules;

  const CancellationPolicy({
    required this.isRefundable,
    required this.freeCancellationHours,
    required this.cancellationFeePercentage,
    required this.policyDescription,
    required this.rules,
  });

  /// Crée une copie avec des valeurs modifiées
  CancellationPolicy copyWith({
    bool? isRefundable,
    int? freeCancellationHours,
    double? cancellationFeePercentage,
    String? policyDescription,
    List<CancellationRule>? rules,
  }) {
    return CancellationPolicy(
      isRefundable: isRefundable ?? this.isRefundable,
      freeCancellationHours: freeCancellationHours ?? this.freeCancellationHours,
      cancellationFeePercentage: cancellationFeePercentage ?? this.cancellationFeePercentage,
      policyDescription: policyDescription ?? this.policyDescription,
      rules: rules ?? this.rules,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'isRefundable': isRefundable,
      'freeCancellationHours': freeCancellationHours,
      'cancellationFeePercentage': cancellationFeePercentage,
      'policyDescription': policyDescription,
      'rules': rules.map((r) => r.toJson()).toList(),
    };
  }

  /// Crée depuis un Map
  factory CancellationPolicy.fromJson(Map<String, dynamic> json) {
    return CancellationPolicy(
      isRefundable: json['isRefundable'] as bool,
      freeCancellationHours: json['freeCancellationHours'] as int,
      cancellationFeePercentage: (json['cancellationFeePercentage'] as num).toDouble(),
      policyDescription: json['policyDescription'] as String,
      rules: (json['rules'] as List)
          .map((r) => CancellationRule.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Entité pour les règles d'annulation
class CancellationRule {
  final int hoursBeforeReservation;
  final double feePercentage;
  final String description;

  const CancellationRule({
    required this.hoursBeforeReservation,
    required this.feePercentage,
    required this.description,
  });

  /// Crée une copie avec des valeurs modifiées
  CancellationRule copyWith({
    int? hoursBeforeReservation,
    double? feePercentage,
    String? description,
  }) {
    return CancellationRule(
      hoursBeforeReservation: hoursBeforeReservation ?? this.hoursBeforeReservation,
      feePercentage: feePercentage ?? this.feePercentage,
      description: description ?? this.description,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'hoursBeforeReservation': hoursBeforeReservation,
      'feePercentage': feePercentage,
      'description': description,
    };
  }

  /// Crée depuis un Map
  factory CancellationRule.fromJson(Map<String, dynamic> json) {
    return CancellationRule(
      hoursBeforeReservation: json['hoursBeforeReservation'] as int,
      feePercentage: (json['feePercentage'] as num).toDouble(),
      description: json['description'] as String,
    );
  }
}

/// Requêtes pour la configuration du restaurant
class UpdateRestaurantConfigRequest {
  final String? name;
  final String? description;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? email;
  final String? website;
  final String? logo;
  final String? coverImage;
  final List<OpeningHours>? openingHours;
  final PaymentSettings? paymentSettings;
  final CancellationPolicy? cancellationPolicy;

  const UpdateRestaurantConfigRequest({
    this.name,
    this.description,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.logo,
    this.coverImage,
    this.openingHours,
    this.paymentSettings,
    this.cancellationPolicy,
  });

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (postalCode != null) 'postalCode': postalCode,
      if (country != null) 'country': country,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (logo != null) 'logo': logo,
      if (coverImage != null) 'coverImage': coverImage,
      if (openingHours != null) 'openingHours': openingHours!.map((h) => h.toJson()).toList(),
      if (paymentSettings != null) 'paymentSettings': paymentSettings!.toJson(),
      if (cancellationPolicy != null) 'cancellationPolicy': cancellationPolicy!.toJson(),
    };
  }
}

