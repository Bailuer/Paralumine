import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo_analysis.dart';
import '../services/ai_analysis_service.dart';

class AnalysisProvider with ChangeNotifier {
  final AIAnalysisService _analysisService = AIAnalysisService();
  
  final List<PhotoAnalysis> _analyses = [];
  PhotoAnalysis? _currentAnalysis;
  bool _isAnalyzing = false;
  String? _error;
  bool _isBeginnerMode = true;

  List<PhotoAnalysis> get analyses => _analyses;
  PhotoAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  bool get isBeginnerMode => _isBeginnerMode;

  void toggleMode() {
    _isBeginnerMode = !_isBeginnerMode;
    notifyListeners();
  }

  Future<void> analyzePhoto(File imageFile) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final analysis = await _analysisService.analyzePhoto(imageFile);
      _currentAnalysis = analysis;
      _analyses.insert(0, analysis);
      _isAnalyzing = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  void selectAnalysis(PhotoAnalysis analysis) {
    _currentAnalysis = analysis;
    notifyListeners();
  }

  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
  }

  void deleteAnalysis(String analysisId) {
    _analyses.removeWhere((analysis) => analysis.id == analysisId);
    if (_currentAnalysis?.id == analysisId) {
      _currentAnalysis = null;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}