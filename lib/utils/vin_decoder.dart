/// VIN (Vehicle Identification Number) decoder supporting post-1981
/// standard 17-character VINs, pre-1981 Italian manufacturer formats,
/// and pre-1981 US manufacturer formats (GM, Ford).

class VinResult {
  final String manufacturer;
  final String country;
  final String modelIndicator;
  final int? year;
  final String? assemblyPlant;
  final String? serialNumber;
  final bool isPreStandard;
  final bool isValid;
  final String rawVin;

  const VinResult({
    required this.manufacturer,
    required this.country,
    required this.modelIndicator,
    this.year,
    this.assemblyPlant,
    this.serialNumber,
    required this.isPreStandard,
    required this.isValid,
    required this.rawVin,
  });

  @override
  String toString() {
    return 'VinResult('
        'manufacturer: $manufacturer, '
        'country: $country, '
        'modelIndicator: $modelIndicator, '
        'year: $year, '
        'assemblyPlant: $assemblyPlant, '
        'serialNumber: $serialNumber, '
        'isPreStandard: $isPreStandard, '
        'isValid: $isValid'
        ')';
  }
}

class VinDecoder {
  VinDecoder._();

  // -----------------------------------------------------------------------
  // WMI lookup table for known manufacturers
  // -----------------------------------------------------------------------
  static const Map<String, String> _wmiManufacturers = {
    // Italian manufacturers
    'ZAR': 'Alfa Romeo',
    'ZFA': 'Fiat',
    'ZLA': 'Lancia',
    'ZFF': 'Ferrari',
    'ZAM': 'Maserati',
    'ZHW': 'Lamborghini',
    'ZDF': 'Ferrari',
    // US manufacturers
    '1G1': 'Chevrolet',
    '1G2': 'Pontiac',
    '1G3': 'Oldsmobile',
    '1G4': 'Buick',
    '1GC': 'Chevrolet Truck',
    '1FA': 'Ford',
    '1FB': 'Ford',
    '1FT': 'Ford Truck',
    '2G1': 'Chevrolet (Canada)',
    '3G4': 'Oldsmobile',
    // European manufacturers
    'WBA': 'BMW',
    'WDB': 'Mercedes-Benz',
    'WP0': 'Porsche',
    'SAJ': 'Jaguar',
    'SAL': 'Land Rover',
    'WVW': 'Volkswagen',
    'WF0': 'Ford (Europe)',
    'TRU': 'Audi',
    'YV1': 'Volvo',
  };

  // Country is derived from the first character of the WMI.
  static const Map<String, String> _wmiCountryPrefixes = {
    'Z': 'Italy',
    'W': 'Germany',
    'S': 'United Kingdom',
    'V': 'France / Spain',
    'J': 'Japan',
    '1': 'United States',
    '2': 'Canada',
    '3': 'Mexico',
    '4': 'United States',
    '5': 'United States',
    '9': 'Brazil',
    'K': 'South Korea',
    'L': 'China',
    'Y': 'Sweden / Finland',
  };

  // Transliteration table for check-digit calculation (ISO 3779).
  static const Map<String, int> _transliteration = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
    'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
  };

  // Positional weights for check-digit calculation.
  static const List<int> _weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

  // Model-year character mapping (position 10 of a standard VIN).
  static const String _yearChars = 'ABCDEFGHJKLMNPRSTVWXY123456789';
  static const int _yearBase = 1980;

  // -----------------------------------------------------------------------
  // Public API
  // -----------------------------------------------------------------------

  /// Decodes a VIN string and returns a [VinResult].
  ///
  /// Supports 17-character post-1981 standard VINs, shorter pre-1981
  /// Italian manufacturer formats (Alfa Romeo, Fiat, Ferrari, Lancia,
  /// Maserati), and pre-1981 US formats (GM divisions, Ford).
  static VinResult decode(String vin) {
    final cleaned = vin.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

    if (cleaned.isEmpty) {
      return _invalid(cleaned);
    }

    // Try pre-1981 Italian formats first when the VIN is clearly not
    // a standard 17-character string.
    if (cleaned.length != 17) {
      final preResult = _tryDecodePreStandard(cleaned);
      if (preResult != null) return preResult;
      return _invalid(cleaned);
    }

    // Validate character set (I, O, Q are not allowed in standard VINs).
    if (RegExp(r'[IOQ]').hasMatch(cleaned)) {
      return _invalid(cleaned);
    }

    return _decodeStandard(cleaned);
  }

  /// Returns a map of factory specifications that can be inferred from the
  /// VIN and, optionally, a model name already identified by the caller.
  ///
  /// The returned map may contain keys such as `engineType`, `transmission`,
  /// `bodyStyle`, `displacement`, `fuelSystem`, and `driveType`.  Values are
  /// best-effort and may be `null` for unknown combinations.
  static Map<String, String?> getOriginalSpecs(
    String vin, {
    String? identifiedModel,
  }) {
    final result = decode(vin);
    final specs = <String, String?>{};

    if (!result.isValid) return specs;

    final manufacturer = result.manufacturer;
    final model = identifiedModel?.toLowerCase() ?? '';
    final vds = vin.length == 17
        ? vin.toUpperCase().substring(3, 9)
        : '';

    // ----- Alfa Romeo --------------------------------------------------
    if (manufacturer == 'Alfa Romeo') {
      specs['driveType'] = 'RWD';

      if (model.contains('giulia') || result.modelIndicator.contains('105')) {
        specs['bodyStyle'] = model.contains('spider') ? 'Spider' : 'Sedan / Coupe';
        specs['engineType'] = 'Inline-4 DOHC';
        specs['displacement'] = '1290cc - 1962cc';
        specs['fuelSystem'] = 'Weber DCOE carburetors';
        specs['transmission'] = '5-speed manual';
      } else if (model.contains('spider') || model.contains('duetto')) {
        specs['bodyStyle'] = 'Spider';
        specs['engineType'] = 'Inline-4 DOHC';
        specs['displacement'] = '1570cc - 1962cc';
        specs['fuelSystem'] = 'SPICA fuel injection / Weber carburetors';
        specs['transmission'] = '5-speed manual';
      } else if (model.contains('gtv') || model.contains('alfetta')) {
        specs['bodyStyle'] = model.contains('gtv') ? 'Coupe' : 'Sedan';
        specs['engineType'] = 'Inline-4 DOHC';
        specs['displacement'] = '1570cc - 1962cc';
        specs['fuelSystem'] = 'SPICA fuel injection';
        specs['transmission'] = '5-speed manual (transaxle)';
      } else if (model.contains('montreal')) {
        specs['bodyStyle'] = 'Coupe';
        specs['engineType'] = 'V8 DOHC';
        specs['displacement'] = '2593cc';
        specs['fuelSystem'] = 'SPICA mechanical fuel injection';
        specs['transmission'] = '5-speed manual (ZF)';
      }
    }

    // ----- Ferrari -----------------------------------------------------
    if (manufacturer == 'Ferrari') {
      specs['driveType'] = 'RWD';
      specs['transmission'] = '5-speed manual (gated)';

      if (model.contains('308')) {
        specs['bodyStyle'] = model.contains('gts') ? 'Targa' : 'Berlinetta';
        specs['engineType'] = 'V8 DOHC';
        specs['displacement'] = '2926cc';
        specs['fuelSystem'] = 'Bosch K-Jetronic fuel injection';
      } else if (model.contains('328')) {
        specs['bodyStyle'] = model.contains('gts') ? 'Targa' : 'Berlinetta';
        specs['engineType'] = 'V8 DOHC';
        specs['displacement'] = '3185cc';
        specs['fuelSystem'] = 'Bosch KE-Jetronic fuel injection';
      } else if (model.contains('275')) {
        specs['bodyStyle'] = model.contains('spider') ? 'Spider' : 'Berlinetta';
        specs['engineType'] = 'V12 SOHC';
        specs['displacement'] = '3286cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '5-speed manual (rear transaxle)';
      } else if (model.contains('250')) {
        specs['bodyStyle'] = 'Berlinetta / Spider';
        specs['engineType'] = 'V12 SOHC';
        specs['displacement'] = '2953cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '4-speed manual';
      } else if (model.contains('testarossa')) {
        specs['bodyStyle'] = 'Berlinetta';
        specs['engineType'] = 'Flat-12 DOHC';
        specs['displacement'] = '4942cc';
        specs['fuelSystem'] = 'Bosch KE-Jetronic fuel injection';
      } else if (model.contains('f40')) {
        specs['bodyStyle'] = 'Berlinetta';
        specs['engineType'] = 'V8 Twin-Turbo DOHC';
        specs['displacement'] = '2936cc';
        specs['fuelSystem'] = 'Weber-Marelli electronic fuel injection';
      }
    }

    // ----- Fiat --------------------------------------------------------
    if (manufacturer == 'Fiat') {
      if (model.contains('500') && !model.contains('abarth')) {
        specs['bodyStyle'] = 'Sedan / Convertible';
        specs['engineType'] = 'Inline-2 OHV';
        specs['displacement'] = '499cc - 594cc';
        specs['fuelSystem'] = 'Weber carburetor';
        specs['transmission'] = '4-speed manual (non-synchro 1st)';
        specs['driveType'] = 'RWD';
      } else if (model.contains('124') && model.contains('spider')) {
        specs['bodyStyle'] = 'Spider';
        specs['engineType'] = 'Inline-4 DOHC';
        specs['displacement'] = '1438cc - 1995cc';
        specs['fuelSystem'] = 'Weber carburetors / Bosch fuel injection';
        specs['transmission'] = '5-speed manual';
        specs['driveType'] = 'RWD';
      } else if (model.contains('130')) {
        specs['bodyStyle'] = 'Sedan / Coupe';
        specs['engineType'] = 'V6 DOHC';
        specs['displacement'] = '3235cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '3-speed automatic / 5-speed manual';
        specs['driveType'] = 'RWD';
      } else if (model.contains('abarth')) {
        specs['bodyStyle'] = 'Coupe';
        specs['engineType'] = 'Inline-4 DOHC';
        specs['displacement'] = '1946cc';
        specs['fuelSystem'] = 'Weber DCOE carburetors';
        specs['transmission'] = '5-speed manual';
        specs['driveType'] = 'RWD';
      }
    }

    // ----- Lancia ------------------------------------------------------
    if (manufacturer == 'Lancia') {
      specs['driveType'] = 'RWD';

      if (model.contains('fulvia')) {
        specs['bodyStyle'] = model.contains('coupe') ? 'Coupe' : 'Sedan';
        specs['engineType'] = 'Narrow V4 DOHC';
        specs['displacement'] = '1216cc - 1584cc';
        specs['fuelSystem'] = 'Solex carburetors';
        specs['transmission'] = '4-speed manual';
        specs['driveType'] = 'FWD';
      } else if (model.contains('stratos')) {
        specs['bodyStyle'] = 'Berlinetta';
        specs['engineType'] = 'V6 DOHC (Ferrari Dino)';
        specs['displacement'] = '2418cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '5-speed manual';
      } else if (model.contains('aurelia')) {
        specs['bodyStyle'] = 'Sedan / Coupe / Spider';
        specs['engineType'] = 'V6';
        specs['displacement'] = '1991cc - 2451cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '4-speed manual';
      } else if (model.contains('037') || model.contains('rally')) {
        specs['bodyStyle'] = 'Coupe';
        specs['engineType'] = 'Inline-4 Supercharged DOHC';
        specs['displacement'] = '1995cc';
        specs['fuelSystem'] = 'Bosch fuel injection';
        specs['transmission'] = '5-speed manual (ZF)';
      } else if (model.contains('delta') && model.contains('integrale')) {
        specs['bodyStyle'] = 'Hatchback';
        specs['engineType'] = 'Inline-4 Turbo DOHC';
        specs['displacement'] = '1995cc';
        specs['fuelSystem'] = 'Weber-Marelli electronic fuel injection';
        specs['transmission'] = '5-speed manual';
        specs['driveType'] = 'AWD';
      }
    }

    // ----- Maserati ----------------------------------------------------
    if (manufacturer == 'Maserati') {
      specs['driveType'] = 'RWD';

      if (model.contains('ghibli') && (result.year == null || result.year! < 1997)) {
        specs['bodyStyle'] = 'Coupe / Spider';
        specs['engineType'] = 'V8 DOHC';
        specs['displacement'] = '4719cc - 4930cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '5-speed manual (ZF)';
      } else if (model.contains('bora')) {
        specs['bodyStyle'] = 'Coupe (mid-engine)';
        specs['engineType'] = 'V8 DOHC';
        specs['displacement'] = '4719cc - 4930cc';
        specs['fuelSystem'] = 'Bosch fuel injection';
        specs['transmission'] = '5-speed manual (ZF)';
      } else if (model.contains('merak')) {
        specs['bodyStyle'] = 'Coupe (mid-engine)';
        specs['engineType'] = 'V6 DOHC';
        specs['displacement'] = '2965cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '5-speed manual (Citroen)';
      } else if (model.contains('khamsin')) {
        specs['bodyStyle'] = 'Coupe';
        specs['engineType'] = 'V8 DOHC';
        specs['displacement'] = '4930cc';
        specs['fuelSystem'] = 'Bosch fuel injection';
        specs['transmission'] = '5-speed manual (ZF) / 3-speed automatic';
      }
    }

    // ----- Lamborghini -------------------------------------------------
    if (manufacturer == 'Lamborghini') {
      specs['driveType'] = 'RWD';

      if (model.contains('countach')) {
        specs['bodyStyle'] = 'Coupe (mid-engine)';
        specs['engineType'] = 'V12 DOHC';
        specs['displacement'] = '3929cc - 5167cc';
        specs['fuelSystem'] = 'Weber carburetors / fuel injection (QV)';
        specs['transmission'] = '5-speed manual';
      } else if (model.contains('miura')) {
        specs['bodyStyle'] = 'Coupe (mid-engine)';
        specs['engineType'] = 'V12 DOHC (transverse)';
        specs['displacement'] = '3929cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '5-speed manual';
      } else if (model.contains('diablo')) {
        specs['bodyStyle'] = 'Coupe (mid-engine)';
        specs['engineType'] = 'V12 DOHC';
        specs['displacement'] = '5707cc';
        specs['fuelSystem'] = 'Lamborghini electronic fuel injection';
        specs['transmission'] = '5-speed manual';
      } else if (model.contains('espada')) {
        specs['bodyStyle'] = 'Grand Tourer (4-seat)';
        specs['engineType'] = 'V12 DOHC';
        specs['displacement'] = '3929cc';
        specs['fuelSystem'] = 'Weber carburetors';
        specs['transmission'] = '5-speed manual / 3-speed automatic';
      }
    }

    // Attempt to extract engine info from VDS for standard VINs when
    // no model-specific data was matched.
    if (specs.isEmpty && vds.isNotEmpty) {
      specs['vdsCode'] = vds;
    }

    return specs;
  }

  // -----------------------------------------------------------------------
  // Standard 17-character VIN decoding
  // -----------------------------------------------------------------------

  static VinResult _decodeStandard(String vin) {
    final wmi = vin.substring(0, 3);
    final vds = vin.substring(3, 9);

    final manufacturer = _wmiManufacturers[wmi] ?? _guessManufacturer(wmi);
    final country = _resolveCountry(vin[0]);

    final yearChar = vin[9];
    final year = _decodeYearChar(yearChar);

    final assemblyPlant = vin[10];
    final serialNumber = vin.substring(11, 17);

    final valid = _validateCheckDigit(vin);

    return VinResult(
      manufacturer: manufacturer,
      country: country,
      modelIndicator: vds,
      year: year,
      assemblyPlant: String.fromCharCode(assemblyPlant.codeUnitAt(0)),
      serialNumber: serialNumber,
      isPreStandard: false,
      isValid: valid,
      rawVin: vin,
    );
  }

  // -----------------------------------------------------------------------
  // Pre-1981 Italian format detection
  // -----------------------------------------------------------------------

  static VinResult? _tryDecodePreStandard(String vin) {
    // Alfa Romeo: "AR" prefix followed by a type/serial number.
    // Example: AR1054830, AR750.2500123
    final alfaPattern = RegExp(r'^AR\s?(\d{3,4})[.\-]?(\d+)$');
    final alfaMatch = alfaPattern.firstMatch(vin);
    if (alfaMatch != null) {
      return VinResult(
        manufacturer: 'Alfa Romeo',
        country: 'Italy',
        modelIndicator: alfaMatch.group(1)!,
        year: null,
        assemblyPlant: null,
        serialNumber: alfaMatch.group(2),
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    // Maserati: "AM" prefix followed by type number.
    // Example: AM117, AM117/49.1234
    final maseratiPattern = RegExp(r'^AM\s?(\d{2,3})[/.\-]?(\d+)?[.\-]?(\d+)?$');
    final maseratiMatch = maseratiPattern.firstMatch(vin);
    if (maseratiMatch != null) {
      final typeNum = maseratiMatch.group(1)!;
      final sub = maseratiMatch.group(2);
      final serial = maseratiMatch.group(3) ?? sub;
      return VinResult(
        manufacturer: 'Maserati',
        country: 'Italy',
        modelIndicator: 'AM$typeNum',
        year: null,
        assemblyPlant: null,
        serialNumber: serial,
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    // Ferrari: sequential 4-5 digit serial numbers, optionally with a
    // type prefix like "F" or a chassis code.
    final ferrariPattern = RegExp(r'^F?\s?(\d{4,5})$');
    final ferrariMatch = ferrariPattern.firstMatch(vin);
    if (ferrariMatch != null) {
      return VinResult(
        manufacturer: 'Ferrari',
        country: 'Italy',
        modelIndicator: 'Unknown',
        year: null,
        assemblyPlant: 'Maranello',
        serialNumber: ferrariMatch.group(1),
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    // Lancia: typically starts with a model code (numeric or alphanumeric).
    // Examples: 818.432.001234, HF1600.12345
    final lanciaPattern = RegExp(r'^(HF\d{0,4}|8\d{2})[.\-]?(\d{3})?[.\-]?(\d+)$');
    final lanciaMatch = lanciaPattern.firstMatch(vin);
    if (lanciaMatch != null) {
      final modelCode = lanciaMatch.group(1)!;
      final variant = lanciaMatch.group(2);
      final serial = lanciaMatch.group(3)!;
      return VinResult(
        manufacturer: 'Lancia',
        country: 'Italy',
        modelIndicator: variant != null ? '$modelCode.$variant' : modelCode,
        year: null,
        assemblyPlant: null,
        serialNumber: serial,
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    // Fiat: various formats. Common patterns include model number followed
    // by serial, e.g. 110F.048.12345, 124AS.0012345
    final fiatPattern = RegExp(r'^(\d{3}[A-Z]{0,2})[.\-]?(\d{3})?[.\-]?(\d+)$');
    final fiatMatch = fiatPattern.firstMatch(vin);
    if (fiatMatch != null) {
      final modelCode = fiatMatch.group(1)!;
      final variant = fiatMatch.group(2);
      final serial = fiatMatch.group(3)!;
      return VinResult(
        manufacturer: 'Fiat',
        country: 'Italy',
        modelIndicator: variant != null ? '$modelCode.$variant' : modelCode,
        year: null,
        assemblyPlant: null,
        serialNumber: serial,
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    // Try US pre-standard formats (GM, Ford, Chrysler 1964-1980).
    final usResult = _tryDecodePreStandardUS(vin);
    if (usResult != null) return usResult;

    return null;
  }

  // -----------------------------------------------------------------------
  // Pre-1981 US format detection (GM / Ford / Chrysler)
  // -----------------------------------------------------------------------

  /// GM division codes used in position 1 of pre-standard VINs (1964-1980).
  static const Map<String, String> _gmDivisions = {
    '1': 'Chevrolet',
    '2': 'Pontiac',
    '3': 'Oldsmobile',
    '4': 'Buick',
    '5': 'Oldsmobile',
    '6': 'Cadillac',
    '9': 'GMC Truck',
  };

  /// Model year codes at position 6 for GM pre-standard VINs.
  /// Digits 0-9 map to 1970-1979, letter A maps to 1980.
  static const Map<String, int> _gmPreStandardYears = {
    '0': 1970,
    '1': 1971,
    '2': 1972,
    '3': 1973,
    '4': 1974,
    '5': 1975,
    '6': 1976,
    '7': 1977,
    '8': 1978,
    '9': 1979,
    'A': 1980,
  };

  /// Known GM assembly plant codes (position 7) for pre-standard VINs.
  static const Map<String, String> _gmAssemblyPlants = {
    'A': 'Atlanta, GA',
    'B': 'Baltimore, MD',
    'C': 'Southgate, CA',
    'D': 'Doraville, GA',
    'F': 'Flint, MI',
    'G': 'Framingham, MA',
    'H': 'Flint, MI',
    'J': 'Janesville, WI',
    'K': 'Kansas City, MO',
    'L': 'Van Nuys, CA',
    'M': 'Lansing, MI',
    'N': 'Norwood, OH',
    'P': 'Pontiac, MI',
    'R': 'Arlington, TX',
    'S': 'St. Louis, MO',
    'T': 'Tarrytown, NY',
    'U': 'Lordstown, OH',
    'W': 'Willow Run, MI',
    'X': 'Fairfax, KS',
    'Y': 'Wilmington, DE',
    'Z': 'Fremont, CA',
  };

  /// Attempts to decode a pre-1981 US VIN (primarily GM format).
  ///
  /// GM format (13 characters, 1970-1980):
  ///   Position 1:   Division code (see [_gmDivisions])
  ///   Position 2:   Series letter
  ///   Position 3-4: Body style (two digits)
  ///   Position 5:   Engine code letter
  ///   Position 6:   Model year digit/letter (see [_gmPreStandardYears])
  ///   Position 7:   Assembly plant letter (see [_gmAssemblyPlants])
  ///   Position 8-13: Sequential production number
  static VinResult? _tryDecodePreStandardUS(String vin) {
    // GM format: 13 characters — digit, letter, 2 digits, letter, alnum,
    // letter, then 6 digits for the sequential number.
    final gmPattern = RegExp(
      r'^([1-69])([A-Z])(\d{2})([A-Z])([0-9A])'
      r'([A-Z])(\d{6})$',
    );
    final gmMatch = gmPattern.firstMatch(vin);
    if (gmMatch != null) {
      final divisionCode = gmMatch.group(1)!;
      final seriesLetter = gmMatch.group(2)!;
      final bodyStyle = gmMatch.group(3)!;
      final yearCode = gmMatch.group(5)!;
      final plantCode = gmMatch.group(6)!;
      final serial = gmMatch.group(7)!;

      final manufacturer = _gmDivisions[divisionCode];
      if (manufacturer == null) return null;

      final year = _gmPreStandardYears[yearCode];
      final plant = _gmAssemblyPlants[plantCode];

      return VinResult(
        manufacturer: manufacturer,
        country: 'United States',
        modelIndicator: '$seriesLetter$bodyStyle',
        year: year,
        assemblyPlant: plant,
        serialNumber: serial,
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    // Ford pre-standard format: typically 11 characters (1964-1980).
    // Position 1:   Model year digit (last digit of year)
    // Position 2:   Assembly plant letter
    // Position 3-4: Body/model code (two digits)
    // Position 5:   Engine code letter
    // Position 6-11: Sequential production number
    final fordPattern = RegExp(r'^(\d)([A-Z])(\d{2})([A-Z])(\d{6})$');
    final fordMatch = fordPattern.firstMatch(vin);
    if (fordMatch != null && vin.length == 11) {
      final yearDigit = int.parse(fordMatch.group(1)!);
      final plantCode = fordMatch.group(2)!;
      final bodyCode = fordMatch.group(3)!;
      final serial = fordMatch.group(5)!;

      // Year digit is the last digit — assume 1960s-1970s range.
      final year = yearDigit >= 4 ? 1960 + yearDigit : 1970 + yearDigit;

      return VinResult(
        manufacturer: 'Ford',
        country: 'United States',
        modelIndicator: bodyCode,
        year: year,
        assemblyPlant: plantCode,
        serialNumber: serial,
        isPreStandard: true,
        isValid: true,
        rawVin: vin,
      );
    }

    return null;
  }

  // -----------------------------------------------------------------------
  // Check digit validation (ISO 3779)
  // -----------------------------------------------------------------------

  static bool _validateCheckDigit(String vin) {
    if (vin.length != 17) return false;

    int sum = 0;
    for (int i = 0; i < 17; i++) {
      final char = vin[i];
      int value;
      if (RegExp(r'\d').hasMatch(char)) {
        value = int.parse(char);
      } else {
        value = _transliteration[char] ?? 0;
      }
      sum += value * _weights[i];
    }

    final remainder = sum % 11;
    final expected = remainder == 10 ? 'X' : remainder.toString();

    return vin[8] == expected;
  }

  // -----------------------------------------------------------------------
  // Year decoding from position 10
  // -----------------------------------------------------------------------

  static int? _decodeYearChar(String char) {
    final index = _yearChars.indexOf(char);
    if (index < 0) return null;

    // The cycle repeats every 30 years: 1980-2009, then 2010-2039.
    // We return the most recent matching year that is not in the future.
    final baseYear = _yearBase + index;
    final now = DateTime.now().year;

    // Try the latest cycle first.
    int year = baseYear;
    while (year + 30 <= now) {
      year += 30;
    }
    return year;
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  static String _resolveCountry(String firstChar) {
    return _wmiCountryPrefixes[firstChar] ?? 'Unknown';
  }

  /// Best-effort manufacturer guess when the WMI is not in our lookup table.
  static String _guessManufacturer(String wmi) {
    // Extended lookup for some common non-Italian WMIs that a user might
    // encounter when cataloging a mixed collection.
    const extended = {
      'WBA': 'BMW',
      'WBS': 'BMW M',
      'WDB': 'Mercedes-Benz',
      'WDD': 'Mercedes-Benz',
      'WUA': 'Audi',
      'WAU': 'Audi',
      'WVW': 'Volkswagen',
      'WP0': 'Porsche',
      'SAJ': 'Jaguar',
      'SAL': 'Land Rover',
      'SCC': 'Lotus',
      'SCF': 'Aston Martin',
      'VF1': 'Renault',
      'VF3': 'Peugeot',
      'VF7': 'Citroen',
      'JHM': 'Honda',
      'JTD': 'Toyota',
      'JN1': 'Nissan',
      '1G1': 'Chevrolet',
      '1FA': 'Ford',
      '2HM': 'Hyundai',
    };

    return extended[wmi] ?? 'Unknown ($wmi)';
  }

  static VinResult _invalid(String vin) {
    return VinResult(
      manufacturer: 'Unknown',
      country: 'Unknown',
      modelIndicator: '',
      year: null,
      assemblyPlant: null,
      serialNumber: null,
      isPreStandard: false,
      isValid: false,
      rawVin: vin,
    );
  }
}
