/// 음식 분석 결과 데이터 모델
class FoodAnalysisResult {
  final String id;
  final String imagePath;
  final String foodName;
  final String description;
  final int totalCalories;
  final List<FoodItem> foodItems;
  final NutritionSummary nutritionSummary;
  final DateTime analyzedAt;

  FoodAnalysisResult({
    required this.id,
    required this.imagePath,
    required this.foodName,
    required this.description,
    required this.totalCalories,
    required this.foodItems,
    required this.nutritionSummary,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'foodName': foodName,
        'description': description,
        'totalCalories': totalCalories,
        'foodItems': foodItems.map((e) => e.toJson()).toList(),
        'nutritionSummary': nutritionSummary.toJson(),
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      foodName: json['foodName'] as String,
      description: json['description'] as String,
      totalCalories: json['totalCalories'] as int,
      foodItems: (json['foodItems'] as List)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutritionSummary: NutritionSummary.fromJson(
          json['nutritionSummary'] as Map<String, dynamic>),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );
  }
}

/// 개별 음식 항목
class FoodItem {
  final String name;
  final String portion;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion': portion,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String,
      portion: json['portion'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}

/// 영양 요약 정보
class NutritionSummary {
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double fiber;
  final double sugar;
  final double sodium;

  NutritionSummary({
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  Map<String, dynamic> toJson() => {
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
      };

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
    );
  }
}
