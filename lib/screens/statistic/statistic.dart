import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';

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
    CategoryData(name: "category.technology", icon: "🧪", questionsAnswered: 3, percentage: 60),
    CategoryData(name: "category.physics", icon: "⚛️", questionsAnswered: 3, percentage: 80),
    CategoryData(name: "category.chemistry", icon: "🧪", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.mixed", icon: "🔭", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.astrology", icon: "🌠", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.biology", icon: "🧬", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.literature", icon: "📚", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.true_false", icon: "❓", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.countries", icon: "🌎", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.movie_tv", icon: "🎬", questionsAnswered: 3, percentage: 100),
    CategoryData(name: "category.culture", icon: "🎭", questionsAnswered: 5, percentage: 80),
    CategoryData(name: "category.geography", icon: "🌍", questionsAnswered: 4, percentage: 60),
    CategoryData(name: "category.history", icon: "🏛️", questionsAnswered: 3, percentage: 40),
    CategoryData(name: "category.sport", icon: "🏈", questionsAnswered: 3, percentage: 20),
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
    final appBarColor = Color(0xFF6A1B9A);
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[100];
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          ref.tr('menu.statistic'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
  icon: SvgPicture.asset(
    'assets/icons/back_icon.svg',  
 
    width: 40,  
    height: 40,
  ),
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
                ref.tr('statistic.result_by_category'),
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

class CategoryListItem extends ConsumerWidget {
  final CategoryData category;
  final bool isDarkMode;

  const CategoryListItem({
    Key? key,
    required this.category,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    ref.tr(category.name),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "${category.questionsAnswered} ${ref.tr('statistic.questions_answered')}",
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