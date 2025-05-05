import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/inventory.dart/inventory_item.dart';
import 'package:quiz_app/providers/inventory/inventory_provider.dart';

// Model for inventory items


// Provider for inventory items


class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryItems = ref.watch(inventoryProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // Use theme-aware colors for app bar
        backgroundColor: isDarkMode ? theme.colorScheme.surface : Color(0xFF6A1B9A),
        title: Text(
          'Inventory',
          style: TextStyle(
            color: isDarkMode ? theme.colorScheme.onSurface : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: isDarkMode ? theme.colorScheme.onSurface : Colors.white
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
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
                        item.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? theme.colorScheme.onSurface : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
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
    );
  }

  Widget _buildItemIcon(InventoryItem item, bool isDarkMode, ThemeData theme) {
    // Adjust icon colors based on dark mode
    final iconBgColor = (Color color) {
      return isDarkMode ? color.withOpacity(0.8) : color;
    };

    // Custom icons based on item name
    switch (item.name) {
      case 'Coins':
        return Icon(Icons.attach_money, color: Colors.amber, size: 40);
      case 'Heart':
        return Container(
          width: 48,
          height: 48,
          child: Icon(Icons.favorite, color: Colors.red, size: 40),
        );
      case 'Duel Ticket':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.orange),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.confirmation_number, color: Colors.white),
        );
      case 'Replay Ticket':
        return Container(
          width: 48,
          height: 48,
          child: Icon(Icons.replay_circle_filled, color: iconBgColor(Colors.amber[700] ?? Colors.amber), size: 40),
        );
      case 'True Answer':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.green),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 32),
        );
      case 'Wrong Answer':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.red[200] ?? Colors.red),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: Colors.white, size: 32),
        );
      case 'Fifty Fifty':
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
      case 'Freeze Time':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor(Colors.red[300] ?? Colors.red),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.timer_off, color: Colors.white, size: 32),
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