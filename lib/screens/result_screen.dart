import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/food_analysis_result.dart';

/// 칼로리 분석 결과 화면
class ResultScreen extends StatelessWidget {
  final FoodAnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '분석 결과',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 음식 이미지
            _buildFoodImage(),
            // 음식 이름 및 총 칼로리
            _buildHeader(),
            // 영양소 도넛 차트
            _buildNutritionChart(),
            // 개별 음식 리스트
            _buildFoodItemsList(),
            // 상세 영양 정보
            _buildDetailedNutrition(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: File(result.imagePath).existsSync()
            ? Image.file(
                File(result.imagePath),
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey.shade200,
                child:
                    const Icon(Icons.restaurant, size: 64, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            result.foodName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            result.description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D99)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${result.totalCalories} kcal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChart() {
    final protein = result.nutritionSummary.totalProtein;
    final carbs = result.nutritionSummary.totalCarbs;
    final fat = result.nutritionSummary.totalFat;
    final total = protein + carbs + fat;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '영양소 비율',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 도넛 차트
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 35,
                    sections: [
                      PieChartSectionData(
                        value: carbs,
                        color: const Color(0xFF4ECDC4),
                        title: '${(carbs / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 30,
                      ),
                      PieChartSectionData(
                        value: protein,
                        color: const Color(0xFF6C63FF),
                        title: '${(protein / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 30,
                      ),
                      PieChartSectionData(
                        value: fat,
                        color: const Color(0xFFFF6B6B),
                        title: '${(fat / total * 100).toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // 범례
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('탄수화물', '${carbs.toStringAsFixed(1)}g',
                        const Color(0xFF4ECDC4)),
                    const SizedBox(height: 12),
                    _buildLegendItem('단백질', '${protein.toStringAsFixed(1)}g',
                        const Color(0xFF6C63FF)),
                    const SizedBox(height: 12),
                    _buildLegendItem('지방', '${fat.toStringAsFixed(1)}g',
                        const Color(0xFFFF6B6B)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFoodItemsList() {
    if (result.foodItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '음식 구성',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...result.foodItems.map((item) => _buildFoodItemTile(item)),
        ],
      ),
    );
  }

  Widget _buildFoodItemTile(FoodItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${item.calories} kcal',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.portion,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildNutrientChip('단백질', '${item.protein.toStringAsFixed(1)}g',
                  const Color(0xFF6C63FF)),
              const SizedBox(width: 8),
              _buildNutrientChip('탄수화물', '${item.carbs.toStringAsFixed(1)}g',
                  const Color(0xFF4ECDC4)),
              const SizedBox(width: 8),
              _buildNutrientChip('지방', '${item.fat.toStringAsFixed(1)}g',
                  const Color(0xFFFF6B6B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailedNutrition() {
    final summary = result.nutritionSummary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상세 영양 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildNutritionRow(
              '단백질', '${summary.totalProtein.toStringAsFixed(1)}g'),
          _buildNutritionRow(
              '탄수화물', '${summary.totalCarbs.toStringAsFixed(1)}g'),
          _buildNutritionRow('지방', '${summary.totalFat.toStringAsFixed(1)}g'),
          const Divider(height: 24),
          _buildNutritionRow('식이섬유', '${summary.fiber.toStringAsFixed(1)}g'),
          _buildNutritionRow('당류', '${summary.sugar.toStringAsFixed(1)}g'),
          _buildNutritionRow('나트륨', '${summary.sodium.toStringAsFixed(0)}mg'),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
