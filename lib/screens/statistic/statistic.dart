import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';

class CategoryData {
  final String name;
  final String icon;
  final int questionsAnswered;
  final int percentage;

  CategoryData({
    required this.name,
    required this.icon,
    required this.questionsAnswered,
    required this.percentage,
  });
}

// Provider for storing category data
final categoriesProvider = StateProvider<List<CategoryData>>((ref) {
  return [
    CategoryData(name: "Technology", icon: "🧪", questionsAnswered: 3, percentage: 60),
    CategoryData(name: "Physic", icon: "⚛️", questionsAnswered: 3, percentage: 80),
    CategoryData(name: "Chemistry", icon: "🧪", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Mixed", icon: "🔭", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Astrology", icon: "🌠", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Biology", icon: "🧬", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Literature", icon: "📚", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "True/false", icon: "❓", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Countries", icon: "🌎", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Movie & Tv", icon: "🎬", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "Culture", icon: "🎭", questionsAnswered: 5, percentage: 80),
    CategoryData(name: "Geography", icon: "🌍", questionsAnswered: 4, percentage: 60),
    CategoryData(name: "History", icon: "🏛️", questionsAnswered: 3, percentage: 40),
    CategoryData(name: "Sport", icon: "🏈", questionsAnswered: 3, percentage: 20),
  ];
});

class StatisticScreen extends ConsumerWidget {
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // App bar color and background color will adapt based on theme
    final appBarColor = Color(0xFF5E77FF);
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[100];
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Statistic',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appBarColor.withOpacity(0.9),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: Text(
                'Results by category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryListItem(
                  category: category,
                  isDarkMode: isDarkMode,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final CategoryData category;
  final bool isDarkMode;

  const CategoryListItem({
    Key? key, 
    required this.category, 
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Adjust colors based on theme mode
    final itemBackgroundColor = isDarkMode ? colorScheme.surface : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    
    return Container(
      decoration: BoxDecoration(
        color: itemBackgroundColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Category Name and Questions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "${category.questionsAnswered} Questions answered",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Percentage
            Text(
              "${category.percentage}%",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: _getPercentageColor(category.percentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }
}