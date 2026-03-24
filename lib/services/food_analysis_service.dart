import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/food_analysis_result.dart';

/// Google Gemini AI를 사용하여 음식 이미지를 분석하는 서비스
class FoodAnalysisService {
  late final GenerativeModel _model;
  final Uuid _uuid = const Uuid();

  FoodAnalysisService({required String apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// 이미지 파일에서 음식을 분석하고 칼로리 정보를 반환
  Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final mimeType = _getMimeType(imageFile.path);

    final prompt = TextPart('''
당신은 전문 영양사입니다. 이 음식 사진을 분석하고 아래 JSON 형식으로만 응답해주세요.
다른 텍스트 없이 순수 JSON만 반환하세요.

{
  "foodName": "전체 음식 이름 (한국어)",
  "description": "음식에 대한 간단한 설명 (한국어, 1-2문장)",
  "totalCalories": 총 칼로리(정수),
  "foodItems": [
    {
      "name": "개별 음식 항목 이름 (한국어)",
      "portion": "예상 양 (예: 1인분, 200g 등)",
      "calories": 칼로리(정수),
      "protein": 단백질(g, 소수점 1자리),
      "carbs": 탄수화물(g, 소수점 1자리),
      "fat": 지방(g, 소수점 1자리)
    }
  ],
  "nutritionSummary": {
    "totalProtein": 총 단백질(g),
    "totalCarbs": 총 탄수화물(g),
    "totalFat": 총 지방(g),
    "fiber": 식이섬유(g),
    "sugar": 당류(g),
    "sodium": 나트륨(mg)
  }
}

음식이 아닌 사진인 경우에도 위 형식을 유지하되, foodName을 "음식을 인식할 수 없습니다"로 설정하고 totalCalories를 0으로 설정해주세요.
''');

    final imagePart = DataPart(mimeType, imageBytes);

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('AI 응답이 비어있습니다.');
    }

    return _parseResponse(text, imageFile.path);
  }

  FoodAnalysisResult _parseResponse(String responseText, String imagePath) {
    // JSON 블록 추출 (```json ... ``` 형태 처리)
    String jsonStr = responseText.trim();
    if (jsonStr.startsWith('```')) {
      final startIdx = jsonStr.indexOf('{');
      final endIdx = jsonStr.lastIndexOf('}');
      if (startIdx != -1 && endIdx != -1) {
        jsonStr = jsonStr.substring(startIdx, endIdx + 1);
      }
    }

    final Map<String, dynamic> json = jsonDecode(jsonStr);

    return FoodAnalysisResult(
      id: _uuid.v4(),
      imagePath: imagePath,
      foodName: json['foodName'] as String,
      description: json['description'] as String,
      totalCalories: json['totalCalories'] as int,
      foodItems: (json['foodItems'] as List)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutritionSummary: NutritionSummary.fromJson(
          json['nutritionSummary'] as Map<String, dynamic>),
      analyzedAt: DateTime.now(),
    );
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
