import 'dart:io';
import 'package:flutter/material.dart';
import '../models/food_analysis_result.dart';
import '../services/food_analysis_service.dart';
import '../services/local_food_analysis_service.dart';
import '../services/image_picker_service.dart';
import '../services/storage_service.dart';

enum AnalysisMode { local, gemini }

/// 앱 전체 상태를 관리하는 Provider
class AppProvider extends ChangeNotifier {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final StorageService _storageService = StorageService();
  final LocalFoodAnalysisService _localService = LocalFoodAnalysisService();
  FoodAnalysisService? _foodAnalysisService;

  // 상태
  List<FoodAnalysisResult> _history = [];
  List<FoodAnalysisResult> _todayHistory = [];
  bool _isAnalyzing = false;
  String? _errorMessage;
  String? _apiKey;
  int _goalCalories = 2000;
  FoodAnalysisResult? _currentResult;
  File? _selectedImage;
  AnalysisMode _analysisMode = AnalysisMode.local;

  // Getters
  List<FoodAnalysisResult> get history => _history;
  List<FoodAnalysisResult> get todayHistory => _todayHistory;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  String? get apiKey => _apiKey;
  int get goalCalories => _goalCalories;
  FoodAnalysisResult? get currentResult => _currentResult;
  File? get selectedImage => _selectedImage;
  bool get isApiKeySet => _apiKey != null && _apiKey!.isNotEmpty;
  AnalysisMode get analysisMode => _analysisMode;

  int get todayTotalCalories =>
      _todayHistory.fold(0, (sum, e) => sum + e.totalCalories);

  double get todayProgress => _goalCalories > 0
      ? (todayTotalCalories / _goalCalories).clamp(0.0, 2.0)
      : 0.0;

  /// 초기화
  Future<void> initialize() async {
    _apiKey = await _storageService.getApiKey();
    _goalCalories = await _storageService.getGoalCalories();
    final modeStr = await _storageService.getAnalysisMode();
    _analysisMode =
        modeStr == 'gemini' ? AnalysisMode.gemini : AnalysisMode.local;
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _foodAnalysisService = FoodAnalysisService(apiKey: _apiKey!);
    }
    await refreshHistory();
    notifyListeners();
  }

  /// 기록 새로고침
  Future<void> refreshHistory() async {
    _history = await _storageService.getHistory();
    _todayHistory = await _storageService.getTodayHistory();
    notifyListeners();
  }

  /// API 키 설정
  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _storageService.saveApiKey(key);
    _foodAnalysisService = FoodAnalysisService(apiKey: key);
    notifyListeners();
  }

  /// 분석 모드 설정
  Future<void> setAnalysisMode(AnalysisMode mode) async {
    _analysisMode = mode;
    await _storageService
        .saveAnalysisMode(mode == AnalysisMode.gemini ? 'gemini' : 'local');
    notifyListeners();
  }

  /// 목표 칼로리 설정
  Future<void> setGoalCalories(int calories) async {
    _goalCalories = calories;
    await _storageService.saveGoalCalories(calories);
    notifyListeners();
  }

  /// 카메라로 사진 촬영
  Future<void> pickImageFromCamera() async {
    _selectedImage = await _imagePickerService.pickFromCamera();
    if (_selectedImage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 갤러리에서 사진 선택
  Future<void> pickImageFromGallery() async {
    _selectedImage = await _imagePickerService.pickFromGallery();
    if (_selectedImage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 선택된 이미지로 음식 분석
  Future<FoodAnalysisResult?> analyzeSelectedImage() async {
    if (_selectedImage == null) {
      _errorMessage = '이미지를 먼저 선택해주세요.';
      notifyListeners();
      return null;
    }

    // Gemini 모드인데 API 키가 없으면 안내
    if (_analysisMode == AnalysisMode.gemini && _foodAnalysisService == null) {
      _errorMessage =
          'Gemini API 키를 먼저 설정해주세요.\n설정에서 "로컬 분석"으로 변경하면 API 키 없이 사용할 수 있습니다.';
      notifyListeners();
      return null;
    }

    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final FoodAnalysisResult result;

      if (_analysisMode == AnalysisMode.local) {
        result = await _localService.analyzeFood(_selectedImage!);
      } else {
        result = await _foodAnalysisService!.analyzeFood(_selectedImage!);
      }

      _currentResult = result;
      await _storageService.saveAnalysis(result);
      await refreshHistory();
      _isAnalyzing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = '분석 중 오류가 발생했습니다: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// 기록 삭제
  Future<void> deleteAnalysis(String id) async {
    await _storageService.deleteAnalysis(id);
    await refreshHistory();
  }

  /// 전체 기록 삭제
  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    await refreshHistory();
  }

  /// 이미지 초기화
  void clearSelectedImage() {
    _selectedImage = null;
    _currentResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
