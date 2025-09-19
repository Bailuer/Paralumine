class CameraSettings {
  final int iso;
  final String shutterSpeed;
  final double aperture;
  final String focusMode;
  final String whiteBalance;

  CameraSettings({
    required this.iso,
    required this.shutterSpeed,
    required this.aperture,
    required this.focusMode,
    required this.whiteBalance,
  });

  Map<String, dynamic> toJson() => {
    'iso': iso,
    'shutterSpeed': shutterSpeed,
    'aperture': aperture,
    'focusMode': focusMode,
    'whiteBalance': whiteBalance,
  };

  factory CameraSettings.fromJson(Map<String, dynamic> json) => CameraSettings(
    iso: json['iso'],
    shutterSpeed: json['shutterSpeed'],
    aperture: json['aperture'],
    focusMode: json['focusMode'],
    whiteBalance: json['whiteBalance'],
  );
}

class LightingSetup {
  final String mainLight;
  final String fillLight;
  final String backgroundLight;
  final String lightingPattern;
  final List<String> suggestions;

  LightingSetup({
    required this.mainLight,
    required this.fillLight,
    required this.backgroundLight,
    required this.lightingPattern,
    required this.suggestions,
  });

  Map<String, dynamic> toJson() => {
    'mainLight': mainLight,
    'fillLight': fillLight,
    'backgroundLight': backgroundLight,
    'lightingPattern': lightingPattern,
    'suggestions': suggestions,
  };

  factory LightingSetup.fromJson(Map<String, dynamic> json) => LightingSetup(
    mainLight: json['mainLight'],
    fillLight: json['fillLight'],
    backgroundLight: json['backgroundLight'],
    lightingPattern: json['lightingPattern'],
    suggestions: List<String>.from(json['suggestions']),
  );
}

class CameraPosition {
  final double height;
  final double distance;
  final double angle;
  final String description;

  CameraPosition({
    required this.height,
    required this.distance,
    required this.angle,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'height': height,
    'distance': distance,
    'angle': angle,
    'description': description,
  };

  factory CameraPosition.fromJson(Map<String, dynamic> json) => CameraPosition(
    height: json['height'],
    distance: json['distance'],
    angle: json['angle'],
    description: json['description'],
  );
}

class PhotoAnalysis {
  final String id;
  final String referenceImagePath;
  final DateTime createdAt;
  final List<CameraSettings> cameraSettingsOptions;
  final LightingSetup lightingSetup;
  final CameraPosition cameraPosition;
  final String beginnerTip;
  final Map<String, dynamic> proModeData;

  PhotoAnalysis({
    required this.id,
    required this.referenceImagePath,
    required this.createdAt,
    required this.cameraSettingsOptions,
    required this.lightingSetup,
    required this.cameraPosition,
    required this.beginnerTip,
    required this.proModeData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'referenceImagePath': referenceImagePath,
    'createdAt': createdAt.toIso8601String(),
    'cameraSettingsOptions': cameraSettingsOptions.map((e) => e.toJson()).toList(),
    'lightingSetup': lightingSetup.toJson(),
    'cameraPosition': cameraPosition.toJson(),
    'beginnerTip': beginnerTip,
    'proModeData': proModeData,
  };

  factory PhotoAnalysis.fromJson(Map<String, dynamic> json) => PhotoAnalysis(
    id: json['id'],
    referenceImagePath: json['referenceImagePath'],
    createdAt: DateTime.parse(json['createdAt']),
    cameraSettingsOptions: (json['cameraSettingsOptions'] as List)
        .map((e) => CameraSettings.fromJson(e))
        .toList(),
    lightingSetup: LightingSetup.fromJson(json['lightingSetup']),
    cameraPosition: CameraPosition.fromJson(json['cameraPosition']),
    beginnerTip: json['beginnerTip'],
    proModeData: json['proModeData'],
  );
}