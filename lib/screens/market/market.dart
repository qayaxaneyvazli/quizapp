import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        backgroundColor: isDarkMode 
            ? colorScheme.primary 
            : Colors.blue.shade500,
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
          _buildPlaceholderContent("Check Marks"),
          _buildPlaceholderContent("Fire Power-ups"),
          _buildPlaceholderContent("Time Power-ups"),
          _buildAvatarsGrid(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
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
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
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
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
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
                      : const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 30,
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
      width: 30,
      height: 30,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
              size: 24,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 12,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "∞",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
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
  
  Widget _buildCoinStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.monetization_on,
          color: Colors.amber.shade800,
          size: 26,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 5),
          child: Icon(
            Icons.monetization_on,
            color: Colors.amber.shade700,
            size: 26,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 5),
          child: Icon(
            Icons.monetization_on,
            color: Colors.amber.shade600,
            size: 26,
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