import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/providers/quiz/quiz_controller.dart';
import 'package:quiz_app/providers/quiz/quiz_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_mode_provider.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Tab> _tabs = [
    const Tab(icon: Icon(Icons.favorite, color: Colors.red)),
    const Tab(icon: Icon(Icons.confirmation_number, color: Colors.orange)),
    const Tab(icon: Icon(Icons.check_circle, color: Colors.green)),
    const Tab(icon: Icon(Icons.timer_off, color: Colors.redAccent)),
    const Tab(icon: Icon(Icons.face, color: Color.fromARGB(255, 179, 246, 255))),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme mode provider to react to changes
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      // Keep original background color in light mode
      backgroundColor: isDarkMode 
          ? colorScheme.background 
          : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          "Market",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3.0, 
              color: isDarkMode ? colorScheme.secondary : Colors.amber
            ),
            insets: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHeartsScreen(),
        _buildDuelTicketsScreen(),
        _buildTrueAnswerScreen(),
          _buildFreezeTimeScreen() ,
          _buildAvatarsGrid(),
        ],
      ),
    );
  }


Widget _buildTrueAnswerScreen() {
   final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
  final colorScheme = Theme.of(context).colorScheme;

  return ListView(
    padding: EdgeInsets.zero,
    children: [
      // Ad Free item (üstte sabit)
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 12),
        child: Container(
          decoration: BoxDecoration(
            color:isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          height: 64,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/no_ads.svg',
                  width: 34,
                  height: 34,
                ),
              ),
              const Expanded(
                child: Text(
                  "Ad Free for 30 days",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.19 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // True Answer başlığı
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/true_answer.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                'True Answer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      // +1 True Answer (coin)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color:isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/true_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+1 True Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "1800",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/icons/Coins.svg',
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +5 True Answer (euro)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/true_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+5 True Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +10 True Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color:isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/true_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+10 True Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +20 True Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/true_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+20 True Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "3.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +50 True Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/true_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+50 True Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "7.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
       const SizedBox(height: 16),

      // Fifty Fifty başlıq
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/fifty_fifty.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                'Fifty Fifty',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      // +1 Fifty Fifty (coin)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color:isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/fifty_fifty.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+1 Fifty Fifty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "1200",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/icons/Coins.svg',
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +5 Fifty Fifty (euro)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/fifty_fifty.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+5 Fifty Fifty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +10 Fifty Fifty
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/fifty_fifty.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+10 Fifty Fifty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +20 Fifty Fifty
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/fifty_fifty.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+20 Fifty Fifty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.89 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +50 Fifty Fifty
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/fifty_fifty.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+50 Fifty Fifty",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "4.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
            const SizedBox(height: 16),

      // Wrong Answer başlıq
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/wrong_answer.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                'Wrong Answer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      // +10 Wrong Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/wrong_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+10 Wrong Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +20 Wrong Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color:  isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/wrong_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+20 Wrong Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +30 Wrong Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/wrong_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+30 Wrong Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +50 Wrong Answer
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/wrong_answer.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+50 Wrong Answer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    ],
  );
}












  Widget _buildFreezeTimeScreen() {
  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
  final colorScheme = Theme.of(context).colorScheme;

  return ListView(
    children: [
      // "Ad Free for 30 days" itemi
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 18, 10, 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          height: 64,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/no_ads.svg', // Öz Ads/AdFree iconun
                  width: 24,
                  height: 24,
                ),
              ),
              const Expanded(
                child: Text(
                  "Ad Free for 30 days",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.19 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Freeze Time başlığı (mavi container)
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/freeze_time2.svg', // Öz Freeze Time iconun
                width: 28,
                height: 28,
        
              ),
              const SizedBox(width: 10),
              const Text(
                'Freeze Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),

      // Freeze Time itemləri
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            // 1x Freeze Time (coin)
            _buildFreezeTimeCoinItem("1x Freeze Time", "2000"),
            const SizedBox(height: 16),
            // Euro ilə Freeze Time-lar
            _buildFreezeTimeMoneyItem("+5 Freez Time", "0.49 €"),
            const SizedBox(height: 16),
            _buildFreezeTimeMoneyItem("+10 Freez Time", "0.99 €"),
            const SizedBox(height: 16),
            _buildFreezeTimeMoneyItem("+20 Freez Time", "1.89 €"),
            const SizedBox(height: 16),
            _buildFreezeTimeMoneyItem("+50 Freez Time", "4.49 €"),
          ],
        ),
      ),
    ],
  );
}


Widget _buildAdFreeItem() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 18, 10, 12),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8AA),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 64,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12),
            child: SvgPicture.asset(
              'assets/icons/no_ads.svg', // Reklam iconu (Ads)
              width: 34,
              height: 34,
            ),
          ),
          const Expanded(
            child: Text(
              "Ad Free for 30 days",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            height: 64,
            width: 100,
            alignment: Alignment.center,
            child: const Text(
              "1.19 €",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFreezeTimeCoinItem(String title, String coins) {
  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    height: 64,
    decoration: BoxDecoration(
      color:  isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12),
          child: SvgPicture.asset(
            'assets/icons/freeze_time2.svg',
            width: 28,
            height: 28,
     
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          height: 64,
          width: 100,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                coins,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/Coins.svg',
                width: 18,
                height: 18,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildFreezeTimeMoneyItem(String title, String price) {

  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
  final colorScheme = Theme.of(context).colorScheme;
  
  return Container(
    height: 64,
    decoration: BoxDecoration(
      color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12),
          child: SvgPicture.asset(
            'assets/icons/freeze_time2.svg',
            width: 28,
            height: 28,
      
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          height: 64,
          width: 100,
          alignment: Alignment.center,
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDuelTicketsScreen() {
  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
  final colorScheme = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        
Padding(
  padding: const EdgeInsets.fromLTRB(2, 8, 2, 15),
  child: Container(
    width: double.infinity,
    height: 54, // Azaldılmış hündürlük
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // Ortada olsun
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/ticket.svg',
          width: 28,   // Azca kiçildim ki, balansa düşsün
          height: 28,
        ),
        const SizedBox(width: 10),
        Text(
          'Duel Tickets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Kiçik etdik ki, konteynerdə tam görünsün
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),

        // Reklam ilə Replay Ticket
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface
                : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ticket.svg', // Replay Ticket iconun olsun!
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Get 1 Duel Ticket",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? colorScheme.onSurface
                              : Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? colorScheme.primary : Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Coinlə Replay Ticket
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface
                : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ticket.svg',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "1 Duel Ticket",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? colorScheme.onSurface
                              : Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? colorScheme.primary : Colors.green,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "1200",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCoinStack(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 5 Replay Ticket (Euro)
        _buildMoneyReplayItem("+5 Duel Tickets", "0.49 €"),
        const SizedBox(height: 16),
        _buildMoneyReplayItem("+10 Duel Tickets", "0.99 €"),
        const SizedBox(height: 16),
        _buildMoneyReplayItem("+20 Duel Tickets", "1.79 €"),
        const SizedBox(height: 16),
        _buildMoneyReplayItem("+50 Duel Tickets", "4.49 €"),
 const SizedBox(height: 18),

          Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/replay_ticket.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                'Replay Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      // +1 Replay Ticket
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/replay_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+1 Replay Ticket",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +5 Replay Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color:  isDarkMode
                ? colorScheme.surface : Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/replay_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+5 Replay Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "2.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +10 Replay Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/replay_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+10 Replay Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "4.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +20 Replay Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color:  isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/replay_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+20 Replay Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "9.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

       const SizedBox(height: 18),

      // Event Tickets başlık
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/event_ticket.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 10),
              const Text(
                'Event Tickets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      // +5 Event Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/event_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+5 Event Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +10 Event Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface :const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/event_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+10 Event Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "0.99 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +20 Event Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/event_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+20 Event Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.79 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      // +50 Event Tickets
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/event_ticket.svg',
                  width: 28,
                  height: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  "+50 Event Tickets",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "4.49 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),







      ],
    ),
  );
}

// Pul ilə Replay Ticket
Widget _buildMoneyReplayItem(String title, String price) {
  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    height: 80,
    decoration: BoxDecoration(
      color: isDarkMode
          ? colorScheme.surface
          : const Color(0xFFF8F8AA),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ticket.svg',
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? colorScheme.onSurface
                        : Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? colorScheme.primary : Colors.green,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildPlaceholderContent(String tabName) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    return Center(
      child: Text(
        "$tabName Content",
        style: TextStyle(
          fontSize: 20,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeartsScreen() {

    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
            Padding(
        padding: const EdgeInsets.fromLTRB(1, 0, 2, 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? colorScheme.surface : const Color(0xFFF8F8AA),
            borderRadius: BorderRadius.circular(16),
          ),
          height: 64,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12),
                child: SvgPicture.asset(
                  'assets/icons/no_ads.svg',
                  width: 34,
                  height: 34,
                ),
              ),
              const Expanded(
                child: Text(
                  "Ad Free for 30 days",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                height: 64,
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "1.19 €",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
          _buildWatchAdItem(),
          const SizedBox(height: 16),
          _buildCoinItem("1 Heart", "600"),
          const SizedBox(height: 16),
          _buildMoneyItem("+10 Hearts", "0.49 €"),
          const SizedBox(height: 16),
          _buildInfiniteCoinItem("Infinite Hearts for 30 minutes", "15000"),
          const SizedBox(height: 16),
          _buildMoneyItem("Infinite Hearts for 1 hour", "0.99 €"),
          const SizedBox(height: 16),
          _buildMoneyItem("Infinite Hearts for 3 hours", "1.99 €"),
          Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8AA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
    
          Spacer(),
  
        ],
      ),
    ),
  ),
  // Infinite Hearts for 3 hours
 
  // Infinite Hearts for 24 hours
   
  const SizedBox(height: 18),
  // Bronze Pack
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: Color(0xFFB388FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text("Bronze Pack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _packIcon('+10', 'assets/icons/heart.svg'),
                _packIcon('+10', 'assets/icons/ticket.svg'),
                _packIcon('+10', 'assets/icons/true_answer.svg'),
                _packIcon('+10', 'assets/icons/fifty_fifty.svg'),
                _packIcon('+10', 'assets/icons/freeze_time2.svg'),
                _packIcon('+10', 'assets/icons/wrong_answer.svg'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 38),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              "4.99 €",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  ),
  // Silver Pack
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text("Silver Pack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _packIcon('3h', 'assets/icons/heart.svg'),
                _packIcon('+20', 'assets/icons/ticket.svg'),
                _packIcon('+20', 'assets/icons/true_answer.svg'),
                _packIcon('+20', 'assets/icons/fifty_fifty.svg'),
                _packIcon('+20', 'assets/icons/freeze_time2.svg'),
                _packIcon('30 Days', 'assets/icons/no_ads.svg'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 38),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              "9.99 €",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  ),
  // Gold Pack
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade400,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text("Gold Pack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.purple)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _packIcon('24h', 'assets/icons/heart.svg'),
                _packIcon('+30', 'assets/icons/ticket.svg'),
                _packIcon('+30', 'assets/icons/true_answer.svg'),
                _packIcon('+30', 'assets/icons/fifty_fifty.svg'),
                _packIcon('+30', 'assets/icons/freeze_time2.svg'),
                _packIcon('30 Days', 'assets/icons/no_ads.svg'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 38),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              "24.99 €",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  ),
  // Platinum Pack
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
    child: Container(
      decoration: BoxDecoration(
        color: Color(0xFFE1BEE7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text("Platinum Pack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.purple)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _packIcon('+55', 'assets/icons/heart.svg'),
                _packIcon('+55', 'assets/icons/ticket.svg'),
                _packIcon('+55', 'assets/icons/true_answer.svg'),
                _packIcon('+55', 'assets/icons/fifty_fifty.svg'),
                _packIcon('+55', 'assets/icons/freeze_time2.svg'),
                _packIcon('30 Days', 'assets/icons/no_ads.svg'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 38),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              "49.99 €",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  ),
        ],
      ),
    );
  }
Widget _packIcon(String text, String iconPath) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Column(
      children: [
        SvgPicture.asset(iconPath, width: 30, height: 30),
        const SizedBox(height: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
  Widget _buildWatchAdItem() {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? colorScheme.surface 
            : const Color(0xFFF8F8AA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                SvgPicture.asset(
          'assets/icons/heart.svg', width: 28,   
            height: 28,
            ),
                  const SizedBox(width: 12),
                  Text(
                    "Get 1 Heart",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode 
                          ? colorScheme.onSurface
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? colorScheme.primary : Colors.blue,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinItem(String title, String coins) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? colorScheme.surface 
            : const Color(0xFFF8F8AA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                 SvgPicture.asset(
          'assets/icons/heart.svg', width: 28,   // veya istediğin sabit bir değer
            height: 28,
            ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode 
                          ? colorScheme.onSurface
                          : Colors.black.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? colorScheme.primary : Colors.green,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coins,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCoinStack(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyItem(String title, String price) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? colorScheme.surface 
            : const Color(0xFFF8F8AA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  title.contains("Infinite")
                      ? _buildInfiniteHeartIcon()
                      : SvgPicture.asset(
          'assets/icons/heart.svg', width: 28,   // veya istediğin sabit bir değer
            height: 28,
            ),
                  const SizedBox(width: 12),
                  // Text widget'ını Expanded içine alarak taşmayı önlüyoruz
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode 
                            ? colorScheme.onSurface
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? colorScheme.primary : Colors.green,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfiniteCoinItem(String title, String coins) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? colorScheme.surface 
            : const Color(0xFFF8F8AA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  _buildInfiniteHeartIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode 
                            ? colorScheme.onSurface
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? colorScheme.primary : Colors.green,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    coins,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCoinStack(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfiniteHeartIcon() {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        children: [
            Positioned(
            
            child: SvgPicture.asset(
          'assets/icons/Heart_infinity.svg',
            ),
          ),
      
        ],
      ),
    );
  }
  
  Widget _buildCoinStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
      SvgPicture.asset(
          'assets/icons/Coins.svg', width: 18,   
            height: 18,
            ),
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 5),
          child: SvgPicture.asset(
          'assets/icons/Coins.svg', width: 18,   
            height: 18,
            ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 5),
          child: SvgPicture.asset(
          'assets/icons/Coins.svg', width: 18,   
            height: 18,
            ),
        ),
      ],
    );
  }

  Widget _buildAvatarsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxItemWidth = 300.0;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxItemWidth,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final avatars = [
              {"name": "Business Man", "price": 4.99},
              {"name": "Afro Style", "price": 6.99},
              {"name": "Professor", "price": 7.99},
              {"name": "Redhead", "price": 9.99},
            ];
            final avatar = avatars[index];
            return _buildAvatarItem(
              avatar["name"]! as String,
              avatar["price"]! as double,
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarItem(String name, double price) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: _getAvatarImage(name),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? colorScheme.primary : Colors.blue.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "\$${price.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAvatarImage(String name) {
    // In a real app, you would use actual avatar images here
    // For this example, we're using placeholder icons
    IconData icon;
    Color color;
    
    switch (name) {
      case "Business Man":
        icon = Icons.business_center;
        color = Colors.blue;
        break;
      case "Afro Style":
        icon = Icons.face;
        color = Colors.green;
        break;
      case "Professor":
        icon = Icons.school;
        color = Colors.brown;
        break;
      case "Redhead":
        icon = Icons.face_retouching_natural;
        color = Colors.red;
        break;
      default:
        icon = Icons.person;
        color = Colors.grey;
    }
    
    return Icon(
      icon,
      size: 80,
      color: color,
    );
  }
}