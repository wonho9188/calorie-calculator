import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:uuid/uuid.dart';
import '../data/food_database.dart';
import '../models/food_analysis_result.dart';

/// Google ML Kit를 사용하는 온디바이스(오프라인) 음식 분석 서비스
/// API 키 없이 기기 내에서 직접 분석합니다.
class LocalFoodAnalysisService {
  ImageLabeler? _labeler;
  final Uuid _uuid = const Uuid();

  ImageLabeler _getLabeler() {
    _labeler ??= ImageLabeler(
      // confidenceThreshold: 낮추면 더 많은 라벨 감지 (정확도 ↓)
      options: ImageLabelerOptions(confidenceThreshold: 0.25),
    );
    return _labeler!;
  }

  Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _getLabeler().processImage(inputImage);

    // 신뢰도 내림차순 정렬
    labels.sort((a, b) => b.confidence.compareTo(a.confidence));

    // ML Kit 라벨 → 음식 데이터베이스 매핑
    FoodData? primary; // 가장 구체적인 매치
    final Set<String> seenNames = {};
    final List<FoodData> matches = [];

    for (final label in labels.take(15)) {
      final data = FoodDatabase.findByLabel(label.label);
      if (data != null && seenNames.add(data.name)) {
        primary ??= data;
        matches.add(data);
        if (matches.length >= 3) break;
      }
    }

    // 구체적인 매치가 없으면 generic 라벨('food', 'dish' 등)로 폴백
    if (primary == null) {
      for (final label in labels.take(20)) {
        final data = FoodDatabase.findByLabel(label.label);
        if (data != null) {
          primary = data;
          matches.add(data);
          break;
        }
      }
    }

    primary ??= FoodDatabase.getUnknown();

    // 구체적 매치가 여러 개면 FoodItem 목록에 포함
    final foodItems = matches.isNotEmpty
        ? matches
            .map((d) => FoodItem(
                  name: d.name,
                  portion: d.portion,
                  calories: d.calories,
                  protein: d.protein,
                  carbs: d.carbs,
                  fat: d.fat,
                ))
            .toList()
        : [
            FoodItem(
              name: primary.name,
              portion: primary.portion,
              calories: primary.calories,
              protein: primary.protein,
              carbs: primary.carbs,
              fat: primary.fat,
            )
          ];

    final totalCalories = foodItems.fold(0, (s, i) => s + i.calories);
    final totalProtein = foodItems.fold(0.0, (s, i) => s + i.protein);
    final totalCarbs = foodItems.fold(0.0, (s, i) => s + i.carbs);
    final totalFat = foodItems.fold(0.0, (s, i) => s + i.fat);

    return FoodAnalysisResult(
      id: _uuid.v4(),
      imagePath: imageFile.path,
      foodName: primary.name,
      description: '${primary.description}\n📍 온디바이스 분석 (참고용 수치)',
      totalCalories: totalCalories > 0 ? totalCalories : primary.calories,
      foodItems: foodItems,
      nutritionSummary: NutritionSummary(
        totalProtein: totalProtein > 0 ? totalProtein : primary.protein,
        totalCarbs: totalCarbs > 0 ? totalCarbs : primary.carbs,
        totalFat: totalFat > 0 ? totalFat : primary.fat,
        fiber: primary.fiber,
        sugar: primary.sugar,
        sodium: primary.sodium,
      ),
      analyzedAt: DateTime.now(),
    );
  }

  void dispose() {
    _labeler?.close();
    _labeler = null;
  }
}
