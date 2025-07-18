import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const BabyFoodNutritionApp());
}

class BabyFoodNutritionApp extends StatelessWidget {
  const BabyFoodNutritionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Food Nutrition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
