import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_analysis_result.dart';

/// 분석 기록을 로컬 저장소에 저장/조회하는 서비스
class StorageService {
  static const String _historyKey = 'analysis_history';
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _goalCaloriesKey = 'goal_calories';

  /// 분석 결과 저장
  Future<void> saveAnalysis(FoodAnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, result);
    final jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  /// 모든 분석 기록 조회
  Future<List<FoodAnalysisResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    return jsonList
        .map((e) => FoodAnalysisResult.fromJson(
            jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  /// 오늘 분석 기록만 조회
  Future<List<FoodAnalysisResult>> getTodayHistory() async {
    final history = await getHistory();
    final now = DateTime.now();
    return history
        .where((e) =>
            e.analyzedAt.year == now.year &&
            e.analyzedAt.month == now.month &&
            e.analyzedAt.day == now.day)
        .toList();
  }

  /// 특정 기록 삭제
  Future<void> deleteAnalysis(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((e) => e.id == id);
    final jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  /// 모든 기록 삭제
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// API 키 저장
  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  /// API 키 조회
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  /// 목표 칼로리 저장
  Future<void> saveGoalCalories(int calories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalCaloriesKey, calories);
  }

  /// 목표 칼로리 조회
  Future<int> getGoalCalories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalCaloriesKey) ?? 2000;
  }
}
