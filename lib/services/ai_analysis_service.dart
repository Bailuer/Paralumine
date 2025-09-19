import 'dart:io';
import 'package:image/image.dart' as img;
import '../models/photo_analysis.dart';

class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  Future<PhotoAnalysis> analyzePhoto(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final analysisId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final cameraSettings = await _extractCameraSettings(image);
      final lightingSetup = await _analyzeLightingSetup(image);
      final cameraPosition = await _determineCameraPosition(image);
      final beginnerTip = await _generateBeginnerTip(image);
      final proModeData = await _generateProModeData(image);

      return PhotoAnalysis(
        id: analysisId,
        referenceImagePath: imageFile.path,
        createdAt: DateTime.now(),
        cameraSettingsOptions: cameraSettings,
        lightingSetup: lightingSetup,
        cameraPosition: cameraPosition,
        beginnerTip: beginnerTip,
        proModeData: proModeData,
      );
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }

  Future<List<CameraSettings>> _extractCameraSettings(img.Image image) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final brightness = _calculateBrightness(image);
    
    List<CameraSettings> settings = [];

    if (brightness < 0.3) {
      settings.add(CameraSettings(
        iso: 1600,
        shutterSpeed: '1/60',
        aperture: 2.8,
        focusMode: 'Auto',
        whiteBalance: 'Tungsten',
      ));
      settings.add(CameraSettings(
        iso: 800,
        shutterSpeed: '1/30',
        aperture: 1.8,
        focusMode: 'Auto',
        whiteBalance: 'Tungsten',
      ));
    } else if (brightness > 0.7) {
      settings.add(CameraSettings(
        iso: 100,
        shutterSpeed: '1/250',
        aperture: 5.6,
        focusMode: 'Auto',
        whiteBalance: 'Daylight',
      ));
      settings.add(CameraSettings(
        iso: 200,
        shutterSpeed: '1/125',
        aperture: 4.0,
        focusMode: 'Auto',
        whiteBalance: 'Daylight',
      ));
    } else {
      settings.add(CameraSettings(
        iso: 400,
        shutterSpeed: '1/125',
        aperture: 3.5,
        focusMode: 'Auto',
        whiteBalance: 'Auto',
      ));
      settings.add(CameraSettings(
        iso: 800,
        shutterSpeed: '1/60',
        aperture: 2.8,
        focusMode: 'Auto',
        whiteBalance: 'Auto',
      ));
    }

    return settings;
  }

  Future<LightingSetup> _analyzeLightingSetup(img.Image image) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final brightness = _calculateBrightness(image);
    final shadowsInfo = _analyzeShadows(image);
    
    String lightingPattern;
    String mainLight;
    String fillLight;
    String backgroundLight;
    List<String> suggestions;

    if (shadowsInfo['strong'] == true) {
      lightingPattern = 'Rembrandt';
      mainLight = '45° above and to the side, strong directional light';
      fillLight = 'Soft fill from opposite side at 1/4 power';
      backgroundLight = 'Optional gradient light on background';
      suggestions = [
        'Use a large softbox as main light',
        'Position key light 45° above subject\'s eye level',
        'Look for triangular light patch on shadowed cheek',
        'Keep fill light subtle to maintain drama'
      ];
    } else if (brightness > 0.8) {
      lightingPattern = 'High Key';
      mainLight = 'Large diffused light source from front';
      fillLight = 'Additional fill lights to eliminate shadows';
      backgroundLight = 'Bright background lighting';
      suggestions = [
        'Use multiple soft light sources',
        'Minimize shadows with ample fill lighting',
        'Overexpose background by 1-2 stops',
        'Perfect for portrait and product photography'
      ];
    } else {
      lightingPattern = 'Loop';
      mainLight = '30° to the side, slightly above eye level';
      fillLight = 'Soft fill from camera position';
      backgroundLight = 'Subtle background separation light';
      suggestions = [
        'Most flattering for portraits',
        'Create small shadow loop under nose',
        'Keep shadow away from cheek line',
        'Balance main and fill for natural look'
      ];
    }

    return LightingSetup(
      mainLight: mainLight,
      fillLight: fillLight,
      backgroundLight: backgroundLight,
      lightingPattern: lightingPattern,
      suggestions: suggestions,
    );
  }

  Future<CameraPosition> _determineCameraPosition(img.Image image) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final aspectRatio = image.width / image.height;
    final perspective = _analyzePerspective(image);
    
    double height;
    double distance;
    double angle;
    String description;

    if (perspective['fromAbove']) {
      height = 1.8;
      distance = 1.5;
      angle = -30;
      description = 'Camera positioned above subject, looking down at 30° angle';
    } else if (perspective['fromBelow']) {
      height = 0.8;
      distance = 2.0;
      angle = 15;
      description = 'Camera positioned below eye level, looking up for dramatic effect';
    } else if (aspectRatio > 1.5) {
      height = 1.2;
      distance = 3.0;
      angle = 0;
      description = 'Camera at eye level, further back for wide composition';
    } else {
      height = 1.5;
      distance = 2.0;
      angle = 0;
      description = 'Camera at subject\'s eye level for natural perspective';
    }

    return CameraPosition(
      height: height,
      distance: distance,
      angle: angle,
      description: description,
    );
  }

  Future<String> _generateBeginnerTip(img.Image image) async {
    final brightness = _calculateBrightness(image);
    
    if (brightness < 0.3) {
      return 'This is a low-light photo. Use a tripod and increase your ISO to 800-1600.';
    } else if (brightness > 0.8) {
      return 'This bright photo needs fast shutter speed (1/250s) and low ISO (100-200).';
    } else {
      return 'This well-balanced photo works great with ISO 400, f/3.5, and 1/125s shutter speed.';
    }
  }

  Future<Map<String, dynamic>> _generateProModeData(img.Image image) async {
    return {
      'histogram': _generateHistogramData(image),
      'colorTemperature': _estimateColorTemperature(image),
      'sharpnessScore': _calculateSharpness(image),
      'dynamicRange': _calculateDynamicRange(image),
      'noiseLevel': _estimateNoiseLevel(image),
      'recommendedLenses': [
        '50mm f/1.8 (Portrait)',
        '85mm f/1.4 (Portrait)',
        '24-70mm f/2.8 (Versatile)'
      ],
      'postProcessingSuggestions': [
        'Slight contrast boost (+10)',
        'Shadow/highlight adjustment',
        'Color grading for mood'
      ]
    };
  }

  double _calculateBrightness(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.round();
        final g = pixel.g.round();
        final b = pixel.b.round();
        totalBrightness += (r + g + b) ~/ 3;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? (totalBrightness / pixelCount) / 255.0 : 0.5;
  }

  double _calculateContrast(img.Image image) {
    return 0.6;
  }

  double _calculateSharpness(img.Image image) {
    return 0.8;
  }

  Map<String, dynamic> _analyzeShadows(img.Image image) {
    final brightness = _calculateBrightness(image);
    return {
      'strong': brightness < 0.4,
      'moderate': brightness >= 0.4 && brightness <= 0.7,
      'minimal': brightness > 0.7
    };
  }

  Map<String, dynamic> _analyzePerspective(img.Image image) {
    return {
      'fromAbove': false,
      'fromBelow': false,
      'eyeLevel': true
    };
  }

  Map<String, dynamic> _generateHistogramData(img.Image image) {
    return {
      'red': List.generate(256, (i) => (i * 0.8).toInt()),
      'green': List.generate(256, (i) => (i * 0.9).toInt()),
      'blue': List.generate(256, (i) => (i * 0.7).toInt()),
    };
  }

  int _estimateColorTemperature(img.Image image) {
    return 5500;
  }

  double _calculateDynamicRange(img.Image image) {
    return 8.5;
  }

  double _estimateNoiseLevel(img.Image image) {
    return 0.2;
  }
}