import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/widgets/translation_helper.dart';
import 'package:quiz_app/models/inventory.dart/inventory_item.dart';
import 'package:quiz_app/providers/inventory/inventory_provider.dart';
import 'package:quiz_app/providers/user_stats/user_stats_provider.dart';

// Model for inventory items


// Provider for inventory items


class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryItems = ref.watch(inventoryProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Fetch user stats when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always try to fetch if we're in loading state or have no data
      if (userStatsAsync is AsyncLoading || 
          (userStatsAsync is AsyncData && userStatsAsync.value == null)) {
        print('🔄 Inventory screen triggering user stats fetch...');
        ref.read(userStatsProvider.notifier).fetchUserStats();
      }
    });

    return Scaffold(
      appBar: AppBar(
        // Use theme-aware colors for app bar
        backgroundColor: isDarkMode ? theme.colorScheme.surface : Color(0xFF6A1B9A),
        title: Text(
          ref.tr('menu.inventory'),
          style: TextStyle(
            color: isDarkMode ? theme.colorScheme.onSurface : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
  icon: SvgPicture.asset(
    'assets/icons/back_icon.svg',  
 
    width: 40,  
    height: 40,
  ),
  onPressed: () => Navigator.of(context).pop(),
),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userStatsProvider.notifier).refreshUserStats();
        },
        child: userStatsAsync.when(
          data: (userStats) => ListView.builder(
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              final item = inventoryItems[index];
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildItemIcon(item, isDarkMode, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr(item.name),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? theme.colorScheme.onSurface : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.tr(item.description),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode 
                              ? theme.colorScheme.onSurface.withOpacity(0.7) 
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.quantity.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? theme.colorScheme.onSurface : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load inventory',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(userStatsProvider.notifier).fetchUserStats();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemIcon(InventoryItem item, bool isDarkMode, ThemeData theme) {
    // Adjust icon colors based on dark mode
    final iconBgColor = (Color color) {
      return isDarkMode ? color.withOpacity(0.8) : color;
    };

    // Custom icons based on item name
    switch (item.name) {
      case 'inventory.coins':
        return Icon(Icons.attach_money, color: Colors.amber, size: 40);
      case 'inventory.heart':
        return Container(
          width: 48,
          height: 48,
          child: Icon(Icons.favorite, color: Colors.red, size: 40),
        );
      case 'inventory.duel_ticket':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.orange),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.confirmation_number, color: Colors.white),
        );
      case 'inventory.replay_ticket':
        return Container(
          width: 48,
          height: 48,
          child: Icon(Icons.replay_circle_filled, color: iconBgColor(Colors.amber[700] ?? Colors.amber), size: 40),
        );
      case 'inventory.true_answer':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.green),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 32),
        );
      case 'inventory.wrong_answer':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.red[200] ?? Colors.red),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: Colors.white, size: 32),
        );
      case 'inventory.fifty_fifty':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.pink),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              '50/50',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      case 'inventory.freeze_time':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.red[300] ?? Colors.red),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.timer_off, color: Colors.white, size: 32),
        );
      case 'inventory.event_ticket':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.purple),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.event, color: Colors.white, size: 32),
        );
      default:
        return Container(
          width: 48,
          height: 48,
          child: Center(child: Text(item.icon, style: TextStyle(fontSize: 24))),
        );
    }
  }
}