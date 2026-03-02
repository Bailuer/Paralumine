import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/photo_analysis.dart';
import '../config/api_config.dart';

class GeminiAnalysisService {
  static final GeminiAnalysisService _instance = GeminiAnalysisService._internal();
  factory GeminiAnalysisService() => _instance;
  GeminiAnalysisService._internal();

  late final GenerativeModel _model;

  void initialize() {
    print('🚀 Initializing Gemini service...');
    print('🔑 API key configured: ${ApiConfig.isConfigured}');
    print('🔑 API key length: ${ApiConfig.geminiApiKey.length}');
    
    if (!ApiConfig.isConfigured) {
      print('❌ API key not configured');
      throw Exception('Gemini API key not configured. Please set your API key in lib/config/api_config.dart');
    }
    
    // Try different models in order of preference (2024 model names)
    List<String> modelsToTry = [
      'gemini-2.5-flash',       // Best price-performance model 2024
      'gemini-2.0-flash',       // Newest multimodal model 2024
      'gemini-1.5-flash',       // Legacy but might still work
      'gemini-pro-vision',      // Old vision support
    ];
    
    String? workingModel;
    for (String modelName in modelsToTry) {
      try {
        _model = GenerativeModel(
          model: modelName,
          apiKey: ApiConfig.geminiApiKey,
        );
        workingModel = modelName;
        print('✅ Successfully initialized with model: $modelName');
        break;
      } catch (e) {
        print('❌ Failed to initialize $modelName: ${e.toString().substring(0, 100)}...');
        continue;
      }
    }
    
    if (workingModel == null) {
      throw Exception('Failed to initialize any Gemini model');
    }
    print('✅ Gemini service initialized successfully');
  }

  void _tryFallbackModel() {
    // Try to switch to a different model when current one is overloaded
    List<String> fallbackModels = [
      'gemini-1.5-flash',       // Try legacy model
      'gemini-pro-vision',      // Try old stable model
      'gemini-2.0-flash',       // Try newer model
    ];
    
    for (String modelName in fallbackModels) {
      try {
        print('🔄 Trying fallback model: $modelName');
        _model = GenerativeModel(
          model: modelName,
          apiKey: ApiConfig.geminiApiKey,
        );
        print('✅ Successfully switched to fallback model: $modelName');
        break;
      } catch (e) {
        print('❌ Failed to switch to $modelName: ${e.toString().substring(0, 100)}...');
        continue;
      }
    }
  }

  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      print('🗜️ Starting image compression...');
      final originalBytes = await imageFile.readAsBytes();
      print('📸 Original image size: ${originalBytes.length} bytes');
      
      // Decode the image
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }
      
      print('📐 Original image dimensions: ${originalImage.width}x${originalImage.height}');
      
      // Resize image to maximum 800x600 while maintaining aspect ratio
      final maxWidth = 800;
      final maxHeight = 600;
      late img.Image resizedImage;
      
      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        if (originalImage.width > originalImage.height) {
          resizedImage = img.copyResize(originalImage, width: maxWidth);
        } else {
          resizedImage = img.copyResize(originalImage, height: maxHeight);
        }
        print('📏 Resized to: ${resizedImage.width}x${resizedImage.height}');
      } else {
        resizedImage = originalImage;
        print('📏 No resize needed');
      }
      
      // Compress to JPEG with quality 60
      final compressedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 60));
      print('🗜️ Compressed image size: ${compressedBytes.length} bytes');
      print('📊 Compression ratio: ${((originalBytes.length - compressedBytes.length) / originalBytes.length * 100).toStringAsFixed(1)}%');
      
      return compressedBytes;
    } catch (e) {
      print('❌ Image compression failed: $e');
      // Fallback to original image if compression fails
      return await imageFile.readAsBytes();
    }
  }

  Future<PhotoAnalysis> analyzePhoto(File imageFile) async {
    try {
      print('🔍 Starting Gemini analysis for image: ${imageFile.path}');
      
      final imageBytes = await _compressImage(imageFile);
      print('📸 Image processed and ready for upload');
      
      final analysisId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create comprehensive prompt for photography analysis
      final prompt = _buildAnalysisPrompt();
      print('📝 Prompt created, length: ${prompt.length} characters');
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      print('🚀 Sending request to Gemini API...');
      
      // Add retry logic with model fallback for server overload
      GenerateContentResponse? response;
      int retries = 3;
      
      for (int i = 0; i < retries; i++) {
        try {
          response = await _model.generateContent(content).timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('Request timeout after 60 seconds');
            },
          );
          print('✅ Received response from Gemini API (attempt ${i + 1})');
          break;
        } catch (e) {
          String errorStr = e.toString();
          bool is503Error = errorStr.contains('503') || errorStr.contains('overloaded');
          bool shouldRetry = is503Error || 
                            errorStr.contains('Connection closed') ||
                            errorStr.contains('ClientException') ||
                            errorStr.contains('SocketException') ||
                            errorStr.contains('timeout') ||
                            errorStr.contains('TimeoutException');
          
          if (shouldRetry) {
            print('⚠️ Network/Server error, retrying in ${2 * (i + 1)} seconds... (attempt ${i + 1}/$retries)');
            print('🔍 Error type: $errorStr');
            
            // If it's a 503 error, try switching to a different model
            if (is503Error && i == 1) {
              print('🔄 Switching to fallback model due to server overload...');
              _tryFallbackModel();
            }
            
            if (i < retries - 1) {
              await Future.delayed(Duration(seconds: 2 * (i + 1)));
              continue;
            }
          }
          rethrow;
        }
      }
      
      if (response == null) {
        throw Exception('Failed to get response after $retries attempts');
      }
      
      final analysisText = response.text ?? '';
      print('📄 Response text length: ${analysisText.length} characters');
      print('📄 FULL Response from Gemini START:');
      print(analysisText);
      print('📄 FULL Response from Gemini END');
      print('📄 Response preview: ${analysisText.length > 200 ? analysisText.substring(0, 200) + "..." : analysisText}');

      // Parse the response into structured data
      final analysis = _parseGeminiResponse(analysisText, analysisId, imageFile.path);
      print('✨ Analysis parsing completed successfully');
      
      return analysis;
    } catch (e) {
      print('❌ Gemini analysis failed: $e');
      print('📍 Error details: ${e.toString()}');
      throw Exception('Gemini analysis failed: $e');
    }
  }

  Future<PhotoAnalysis> comparePhotos(File currentEnvironment, File targetEffect) async {
    try {
      print('🔍 Starting Gemini photo comparison...');
      print('📸 Environment photo: ${currentEnvironment.path}');
      print('🎯 Target photo: ${targetEffect.path}');
      
      final environmentBytes = await _compressImage(currentEnvironment);
      final targetBytes = await _compressImage(targetEffect);
      print('📸 Images compressed and ready for upload');
      
      final analysisId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create comparison prompt for photography analysis
      final prompt = _buildComparisonPrompt();
      print('📝 Comparison prompt created, length: ${prompt.length} characters');
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', environmentBytes),
          DataPart('image/jpeg', targetBytes),
        ])
      ];

      print('🚀 Sending comparison request to Gemini API...');
      
      // Add retry logic for server overload
      GenerateContentResponse? response;
      int retries = 3;
      
      for (int i = 0; i < retries; i++) {
        try {
          response = await _model.generateContent(content).timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('Request timeout after 60 seconds');
            },
          );
          print('✅ Received comparison response from Gemini API (attempt ${i + 1})');
          break;
        } catch (e) {
          String errorStr = e.toString();
          bool is503Error = errorStr.contains('503') || errorStr.contains('overloaded');
          bool shouldRetry = is503Error || 
                            errorStr.contains('Connection closed') ||
                            errorStr.contains('ClientException') ||
                            errorStr.contains('SocketException') ||
                            errorStr.contains('timeout') ||
                            errorStr.contains('TimeoutException');
          
          if (shouldRetry) {
            print('⚠️ Network/Server error, retrying in ${2 * (i + 1)} seconds... (attempt ${i + 1}/$retries)');
            print('🔍 Error type: $errorStr');
            
            // If it's a 503 error, try switching to a different model
            if (is503Error && i == 1) {
              print('🔄 Switching to fallback model due to server overload...');
              _tryFallbackModel();
            }
            
            if (i < retries - 1) {
              await Future.delayed(Duration(seconds: 2 * (i + 1)));
              continue;
            }
          }
          rethrow;
        }
      }
      
      if (response == null) {
        throw Exception('Failed to get comparison response after $retries attempts');
      }
      
      final analysisText = response.text ?? '';
      print('📄 Comparison response text length: ${analysisText.length} characters');
      print('📄 FULL Comparison Response from Gemini START:');
      print(analysisText);
      print('📄 FULL Comparison Response from Gemini END');
      print('📄 Comparison response preview: ${analysisText.length > 200 ? '${analysisText.substring(0, 200)}...' : analysisText}');

      // Parse the response into structured comparison data
      final analysis = _parseComparisonResponse(analysisText, analysisId, currentEnvironment.path, targetEffect.path);
      print('✨ Comparison analysis parsing completed successfully');
      
      return analysis;
    } catch (e) {
      print('❌ Gemini comparison failed: $e');
      print('📍 Error details: ${e.toString()}');
      throw Exception('Gemini comparison failed: $e');
    }
  }

  String _buildAnalysisPrompt() {
    return '''
Analyze this photo and give me practical photography advice:

Tell me:
- Camera settings to recreate this (ISO, aperture, shutter speed)
- Lighting setup 
- Camera position and angle
- Quick beginner tip

Keep it brief and actionable! Maximum 150 words.
''';
  }

  String _buildComparisonPrompt() {
    return '''
Compare these two photos and give me short practical advice:

PHOTO 1: Current environment 
PHOTO 2: Target effect I want

Format your response using these **bold headings**:

**What's Different:** [key differences between the photos]

**Camera Settings:** [specific ISO, aperture, shutter speed recommendations]

**Lighting Tips:** [lighting adjustments needed]

**Camera Position:** [position and angle changes]

**Quick Tip:** [one simple tip for beginners]

Keep it simple and practical! Maximum 200 words total.

Focus on:
1. Practical differences between current vs target
2. Actionable steps to bridge the gap
3. Equipment/lighting changes needed
4. Camera settings adjustments
5. Positioning modifications
6. Post-processing differences

Be specific about what needs to change and how to implement each change step by step.
''';
  }

  PhotoAnalysis _parseGeminiResponse(String response, String analysisId, String imagePath) {
    try {
      print('🔧 Parsing Gemini response...');
      
      // Try to extract JSON from the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      print('📊 JSON detection: start=$jsonStart, end=$jsonEnd');
      
      if (jsonStart == -1 || jsonEnd == 0) {
        print('⚠️ No JSON found in response, using fallback analysis');
        return _createFallbackAnalysis(analysisId, imagePath, response);
      }

      print('🎯 Creating analysis from text parsing...');
      // For now, create a structured analysis based on text parsing
      // In a production app, you'd want to parse the JSON properly
      return _createAnalysisFromText(analysisId, imagePath, response);
      
    } catch (e) {
      print('❌ Error parsing response: $e');
      return _createFallbackAnalysis(analysisId, imagePath, response);
    }
  }

  PhotoAnalysis _createAnalysisFromText(String analysisId, String imagePath, String response) {
    // Extract camera settings suggestions
    final cameraSettings = _extractCameraSettings(response);
    final lightingSetup = _extractLightingSetup(response);
    final cameraPosition = _extractCameraPosition(response);
    final beginnerTip = _extractBeginnerTip(response);
    final proModeData = _extractProModeData(response);

    return PhotoAnalysis(
      id: analysisId,
      referenceImagePath: imagePath,
      createdAt: DateTime.now(),
      cameraSettingsOptions: cameraSettings,
      lightingSetup: lightingSetup,
      cameraPosition: cameraPosition,
      beginnerTip: beginnerTip,
      proModeData: proModeData,
    );
  }

  List<CameraSettings> _extractCameraSettings(String response) {
    final settings = <CameraSettings>[];
    
    // Extract aperture suggestions from the response (e.g., "f/1.8 - f/2.8")
    double aperture = 2.8; // default
    if (response.contains('f/1.8')) {
      aperture = 1.8;
    } else if (response.contains('f/2.8')) {
      aperture = 2.8;
    } else if (response.contains('f/3.5')) {
      aperture = 3.5;
    }
    
    // Extract ISO suggestions (e.g., "100-400")
    int iso = 200; // default
    if (response.contains('100-400') || response.contains('ISO low')) {
      iso = 200;
    } else if (response.contains('800')) {
      iso = 800;
    }
    
    // Primary settings based on actual response
    settings.add(CameraSettings(
      iso: iso,
      shutterSpeed: '1/125',
      aperture: aperture,
      focusMode: 'Auto',
      whiteBalance: 'Auto',
    ));

    // Alternative settings for different conditions
    settings.add(CameraSettings(
      iso: iso * 2, // slightly higher ISO
      shutterSpeed: '1/60',
      aperture: aperture + 0.7, // slightly smaller aperture
      focusMode: 'Auto',
      whiteBalance: 'Auto',
    ));

    return settings;
  }

  LightingSetup _extractLightingSetup(String response) {
    return LightingSetup(
      mainLight: _extractString(response, 'main light', 'Soft key light from 45° angle'),
      fillLight: _extractString(response, 'fill light', 'Subtle fill from opposite side'),
      backgroundLight: _extractString(response, 'background', 'Minimal background separation'),
      lightingPattern: _extractString(response, 'pattern', 'Natural'),
      suggestions: _extractSuggestions(response, 'lighting'),
    );
  }

  CameraPosition _extractCameraPosition(String response) {
    return CameraPosition(
      height: _extractDouble(response, 'height', 1.5),
      distance: _extractDouble(response, 'distance', 2.0),
      angle: _extractDouble(response, 'angle', 0.0),
      description: _extractString(response, 'position', 'Camera at eye level for natural perspective'),
    );
  }

  String _extractBeginnerTip(String response) {
    // Look for beginner advice in the response
    final tip = _extractString(response, 'beginner', 
      'Focus on getting the lighting right first, then adjust camera settings for the mood you want to create.');
    return tip;
  }

  Map<String, dynamic> _extractProModeData(String response) {
    return {
      'colorTemperature': _extractNumber(response, 'temperature', 5500),
      'sharpnessScore': _extractDouble(response, 'sharpness', 0.8),
      'dynamicRange': _extractDouble(response, 'dynamic', 8.5),
      'noiseLevel': _extractDouble(response, 'noise', 0.2),
      'recommendedLenses': _extractSuggestions(response, 'lens'),
      'postProcessingSuggestions': _extractSuggestions(response, 'edit'),
    };
  }

  // Helper methods for text extraction
  int _extractNumber(String text, String keyword, int defaultValue) {
    final regex = RegExp('$keyword.*?(\\d+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? int.tryParse(match.group(1)!) ?? defaultValue : defaultValue;
  }

  double _extractDouble(String text, String keyword, double defaultValue) {
    final regex = RegExp('$keyword.*?(\\d+\\.?\\d*)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1)!) ?? defaultValue : defaultValue;
  }

  String _extractString(String text, String keyword, String defaultValue) {
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().contains(keyword.toLowerCase())) {
        return line.trim();
      }
    }
    return defaultValue;
  }

  List<String> _extractSuggestions(String text, String category) {
    final suggestions = <String>[];
    final lines = text.split('\n');
    
    bool inRelevantSection = false;
    for (final line in lines) {
      if (line.toLowerCase().contains(category.toLowerCase())) {
        inRelevantSection = true;
        continue;
      }
      
      if (inRelevantSection && line.trim().startsWith('-')) {
        suggestions.add(line.replaceFirst('-', '').trim());
      } else if (inRelevantSection && line.trim().isEmpty) {
        break;
      }
    }
    
    if (suggestions.isEmpty) {
      suggestions.addAll(_getDefaultSuggestions(category));
    }
    
    return suggestions;
  }

  List<String> _getDefaultSuggestions(String category) {
    switch (category) {
      case 'lighting':
        return [
          'Use soft, diffused light for flattering results',
          'Position main light at 45° angle',
          'Add fill light to reduce harsh shadows',
          'Consider background separation'
        ];
      case 'lens':
        return [
          '50mm f/1.8 (Portrait)',
          '85mm f/1.4 (Portrait)',
          '24-70mm f/2.8 (Versatile)'
        ];
      case 'edit':
        return [
          'Adjust highlights and shadows',
          'Fine-tune white balance',
          'Apply subtle color grading',
          'Sharpen for web/print as needed'
        ];
      default:
        return ['General photography advice'];
    }
  }

  PhotoAnalysis _parseComparisonResponse(String response, String analysisId, String environmentPath, String targetPath) {
    try {
      print('🔧 Parsing comparison response...');
      
      // Extract comparison data from response
      final comparison = _extractComparisonData(response);
      final cameraSettings = _extractCameraSettings(response);
      final lightingSetup = _extractLightingSetup(response);
      final cameraPosition = _extractCameraPosition(response);
      final beginnerTip = _extractBeginnerTip(response);
      final proModeData = _extractProModeData(response);

      return PhotoAnalysis(
        id: analysisId,
        referenceImagePath: environmentPath,
        targetImagePath: targetPath,
        createdAt: DateTime.now(),
        cameraSettingsOptions: cameraSettings,
        lightingSetup: lightingSetup,
        cameraPosition: cameraPosition,
        beginnerTip: beginnerTip,
        proModeData: proModeData,
        comparison: comparison,
      );
    } catch (e) {
      print('❌ Error parsing comparison response: $e');
      return _createFallbackComparisonAnalysis(analysisId, environmentPath, targetPath, response);
    }
  }

  ComparisonAnalysis _extractComparisonData(String response) {
    // Extract sections from the bold headings format
    String keyDifferences = _extractSection(response, "**What's Different:**", "**Camera Settings:**");
    String cameraSettingsText = _extractSection(response, "**Camera Settings:**", "**Lighting Tips:**");
    String lightingTips = _extractSection(response, "**Lighting Tips:**", "**Camera Position:**");
    String positionInfo = _extractSection(response, "**Camera Position:**", "**Quick Tip:**");
    String quickTip = _extractSection(response, "**Quick Tip:**", "");
    
    return ComparisonAnalysis(
      environmentDescription: 'Current environment photo',
      targetDescription: 'Target effect photo',
      keyDifferences: [keyDifferences.trim()],
      stepByStepGuide: [
        'Camera: ${cameraSettingsText.trim()}',
        'Lighting: ${lightingTips.trim()}',
        'Position: ${positionInfo.trim()}'
      ],
      lightingChanges: lightingTips.trim(),
      positionAdjustments: positionInfo.trim().isNotEmpty ? positionInfo.trim() : 'Adjust camera position and angle',
      equipmentNeeded: _extractEquipmentFromText(response),
    );
  }
  
  String _extractSection(String text, String startMarker, String endMarker) {
    int startIndex = text.indexOf(startMarker);
    if (startIndex == -1) return '';
    
    startIndex += startMarker.length;
    int endIndex;
    if (endMarker.isEmpty) {
      endIndex = text.length;
    } else {
      endIndex = text.indexOf(endMarker, startIndex);
      if (endIndex == -1) endIndex = text.length;
    }
    
    return text.substring(startIndex, endIndex).trim();
  }
  
  String _extractEquipmentFromText(String text) {
    // Look for equipment mentions in the text
    if (text.contains('reflector')) return 'White reflector or reflector board';
    if (text.contains('diffuser')) return 'Light diffuser or softbox';
    if (text.contains('tripod')) return 'Tripod for stable shots';
    return 'Basic photography equipment';
  }

  PhotoAnalysis _createFallbackComparisonAnalysis(String analysisId, String environmentPath, String targetPath, String response) {
    return PhotoAnalysis(
      id: analysisId,
      referenceImagePath: environmentPath,
      targetImagePath: targetPath,
      createdAt: DateTime.now(),
      cameraSettingsOptions: [
        CameraSettings(
          iso: 400,
          shutterSpeed: '1/125',
          aperture: 3.5,
          focusMode: 'Auto',
          whiteBalance: 'Auto',
        ),
      ],
      lightingSetup: LightingSetup(
        mainLight: 'Adjust main light position',
        fillLight: 'Add fill light if needed',
        backgroundLight: 'Consider background lighting',
        lightingPattern: 'Natural',
        suggestions: ['Compare lighting between photos', 'Adjust setup gradually'],
      ),
      cameraPosition: CameraPosition(
        height: 1.5,
        distance: 2.0,
        angle: 0,
        description: 'Compare camera positions between photos',
      ),
      beginnerTip: response.length > 100 ? '${response.substring(0, 100)}...' : response,
      proModeData: {
        'colorTemperature': 5500,
        'sharpnessScore': 0.8,
        'dynamicRange': 8.0,
        'noiseLevel': 0.3,
        'recommendedLenses': ['50mm f/1.8', '85mm f/1.4'],
        'postProcessingSuggestions': ['Compare color grading', 'Adjust exposure'],
      },
      comparison: ComparisonAnalysis(
        environmentDescription: 'Current environment setup',
        targetDescription: 'Target effect to achieve',
        keyDifferences: ['Lighting differences', 'Camera angle differences', 'Post-processing differences'],
        stepByStepGuide: ['Analyze current setup', 'Identify target elements', 'Make gradual adjustments'],
        lightingChanges: 'Adjust lighting to match target',
        positionAdjustments: 'Reposition camera to match target angle',
        equipmentNeeded: 'Additional lighting equipment may be needed',
      ),
    );
  }

  PhotoAnalysis _createFallbackAnalysis(String analysisId, String imagePath, String response) {
    return PhotoAnalysis(
      id: analysisId,
      referenceImagePath: imagePath,
      createdAt: DateTime.now(),
      cameraSettingsOptions: [
        CameraSettings(
          iso: 400,
          shutterSpeed: '1/125',
          aperture: 3.5,
          focusMode: 'Auto',
          whiteBalance: 'Auto',
        ),
      ],
      lightingSetup: LightingSetup(
        mainLight: 'Natural lighting setup',
        fillLight: 'Soft fill recommended',
        backgroundLight: 'Background separation suggested',
        lightingPattern: 'Natural',
        suggestions: ['Use available light effectively', 'Consider reflectors for fill'],
      ),
      cameraPosition: CameraPosition(
        height: 1.5,
        distance: 2.0,
        angle: 0,
        description: 'Eye level camera position',
      ),
      beginnerTip: response.length > 100 ? '${response.substring(0, 100)}...' : response,
      proModeData: {
        'colorTemperature': 5500,
        'sharpnessScore': 0.8,
        'dynamicRange': 8.0,
        'noiseLevel': 0.3,
        'recommendedLenses': ['50mm f/1.8', '85mm f/1.4'],
        'postProcessingSuggestions': ['Basic color correction', 'Contrast adjustment'],
      },
    );
  }
}