class UnitSystem {
  static const Map<String, UnitCategory> unitCategories = {
    // Count-based units
    'piece': UnitCategory(
      name: 'Count',
      baseUnit: 'piece',
      units: ['piece', 'dozen', 'pair', 'box', 'packet'],
      conversions: {
        'piece': 1.0,
        'dozen': 12.0,
        'pair': 2.0,
        'box': 1.0, // Variable, user defined
        'packet': 1.0, // Variable, user defined
      },
      inputFields: ['quantity'],
      icon: 'inventory',
    ),
    
    // Weight-based units
    'kilogram': UnitCategory(
      name: 'Weight',
      baseUnit: 'gram',
      units: ['gram', 'kilogram'],
      conversions: {
        'gram': 1.0,
        'kilogram': 1000.0,
      },
      inputFields: ['weight', 'quantity'],
      icon: 'scale',
    ),
    
    'gram': UnitCategory(
      name: 'Weight',
      baseUnit: 'gram',
      units: ['gram', 'kilogram'],
      conversions: {
        'gram': 1.0,
        'kilogram': 1000.0,
      },
      inputFields: ['weight', 'quantity'],
      icon: 'scale',
    ),
    
    // Volume-based units
    'liter': UnitCategory(
      name: 'Volume',
      baseUnit: 'milliliter',
      units: ['milliliter', 'liter'],
      conversions: {
        'milliliter': 1.0,
        'liter': 1000.0,
      },
      inputFields: ['volume', 'quantity'],
      icon: 'water_drop',
    ),
    
    'milliliter': UnitCategory(
      name: 'Volume',
      baseUnit: 'milliliter',
      units: ['milliliter', 'liter'],
      conversions: {
        'milliliter': 1.0,
        'liter': 1000.0,
      },
      inputFields: ['volume', 'quantity'],
      icon: 'water_drop',
    ),
    
    // Length-based units
    'meter': UnitCategory(
      name: 'Length',
      baseUnit: 'centimeter',
      units: ['centimeter', 'meter'],
      conversions: {
        'centimeter': 1.0,
        'meter': 100.0,
      },
      inputFields: ['length', 'quantity'],
      icon: 'straighten',
    ),
    
    'centimeter': UnitCategory(
      name: 'Length',
      baseUnit: 'centimeter',
      units: ['centimeter', 'meter'],
      conversions: {
        'centimeter': 1.0,
        'meter': 100.0,
      },
      inputFields: ['length', 'quantity'],
      icon: 'straighten',
    ),
    
    // Container-based units (volume)
    'bottle': UnitCategory(
      name: 'Container (Volume)',
      baseUnit: 'milliliter',
      units: ['bottle'],
      conversions: {
        'bottle': 1.0, // User defines bottle capacity
      },
      inputFields: ['capacity', 'quantity'],
      icon: 'local_drink',
      requiresCapacity: true,
    ),
    
    // Package-based units
    'box': UnitCategory(
      name: 'Package',
      baseUnit: 'piece',
      units: ['box'],
      conversions: {
        'box': 1.0, // User defines items per box
      },
      inputFields: ['itemsPerUnit', 'quantity'],
      icon: 'inventory_2',
      requiresCapacity: true,
    ),
    
    'packet': UnitCategory(
      name: 'Package',
      baseUnit: 'piece',
      units: ['packet'],
      conversions: {
        'packet': 1.0, // User defines items per packet
      },
      inputFields: ['itemsPerUnit', 'quantity'],
      icon: 'inventory_2',
      requiresCapacity: true,
    ),
  };

  static List<String> getAllUnits() {
    return unitCategories.keys.toList();
  }

  static UnitCategory? getUnitCategory(String unit) {
    return unitCategories[unit.toLowerCase()];
  }

  static List<String> getUnitsForCategory(String unit) {
    final category = getUnitCategory(unit);
    return category?.units ?? [unit];
  }

  static double convertToBaseUnit(String unit, double value, {double? customCapacity}) {
    final category = getUnitCategory(unit);
    if (category == null) return value;

    if (category.requiresCapacity && customCapacity != null) {
      return value * customCapacity;
    }

    final conversion = category.conversions[unit] ?? 1.0;
    return value * conversion;
  }

  static double convertFromBaseUnit(String unit, double baseValue, {double? customCapacity}) {
    final category = getUnitCategory(unit);
    if (category == null) return baseValue;

    if (category.requiresCapacity && customCapacity != null) {
      return baseValue / customCapacity;
    }

    final conversion = category.conversions[unit] ?? 1.0;
    return baseValue / conversion;
  }

  static String getDisplayName(String unit) {
    switch (unit.toLowerCase()) {
      case 'piece': return 'Piece (pcs)';
      case 'kilogram': return 'Kilogram (kg)';
      case 'gram': return 'Gram (g)';
      case 'liter': return 'Liter (L)';
      case 'milliliter': return 'Milliliter (mL)';
      case 'meter': return 'Meter (m)';
      case 'centimeter': return 'Centimeter (cm)';
      case 'box': return 'Box';
      case 'packet': return 'Packet';
      case 'bottle': return 'Bottle';
      case 'dozen': return 'Dozen';
      case 'pair': return 'Pair';
      default: return unit.substring(0, 1).toUpperCase() + unit.substring(1);
    }
  }

  static List<String> getRequiredFields(String unit) {
    final category = getUnitCategory(unit);
    return category?.inputFields ?? ['quantity'];
  }

  static bool requiresCapacityInput(String unit) {
    final category = getUnitCategory(unit);
    return category?.requiresCapacity ?? false;
  }

  static String getUnitIcon(String unit) {
    final category = getUnitCategory(unit);
    return category?.icon ?? 'inventory';
  }
}

class UnitCategory {
  final String name;
  final String baseUnit;
  final List<String> units;
  final Map<String, double> conversions;
  final List<String> inputFields;
  final String icon;
  final bool requiresCapacity;

  const UnitCategory({
    required this.name,
    required this.baseUnit,
    required this.units,
    required this.conversions,
    required this.inputFields,
    required this.icon,
    this.requiresCapacity = false,
  });
}

class UnitConversion {
  static String formatQuantity(double quantity, String unit, {double? capacity}) {
    if (UnitSystem.requiresCapacityInput(unit) && capacity != null) {
      return '${quantity.toStringAsFixed(0)} $unit (${(quantity * capacity).toStringAsFixed(1)} ${_getBaseDisplayUnit(unit)})';
    }
    return '${quantity.toStringAsFixed(quantity == quantity.toInt() ? 0 : 1)} ${UnitSystem.getDisplayName(unit)}';
  }

  static String _getBaseDisplayUnit(String unit) {
    final category = UnitSystem.getUnitCategory(unit);
    if (category == null) return unit;
    
    switch (category.baseUnit) {
      case 'milliliter': return 'mL';
      case 'gram': return 'g';
      case 'centimeter': return 'cm';
      case 'piece': return 'pcs';
      default: return category.baseUnit;
    }
  }
}