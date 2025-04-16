import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model for inventory items
class InventoryItem {
  final String name;
  final String description;
  final String icon;
  final int quantity;

  InventoryItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.quantity,
  });
}

// Provider for inventory items
final inventoryProvider = StateProvider<List<InventoryItem>>((ref) {
  return [
    InventoryItem(
      name: 'Coins',
      description: 'You can use this coins to get items from Market',
      icon: '💰',
      quantity: 7000,
    ),
    InventoryItem(
      name: 'Heart',
      description: 'You can use this heart to play a level',
      icon: '❤️',
      quantity: 21,
    ),
    InventoryItem(
      name: 'Duel Ticket',
      description: 'With this ticket you can play a duel',
      icon: '🎫',
      quantity: 12,
    ),
    InventoryItem(
      name: 'Replay Ticket',
      description: 'With this ticket you can play a level again',
      icon: '🎟️',
      quantity: 7,
    ),
    InventoryItem(
      name: 'True Answer',
      description: 'With this item you can get a true answer',
      icon: '✅',
      quantity: 3,
    ),
    InventoryItem(
      name: 'Wrong Answer',
      description: 'With this item you can remove one wrong answers',
      icon: '❌',
      quantity: 33,
    ),
    InventoryItem(
      name: 'Fifty Fifty',
      description: 'With this item you can remove two wrong answers',
      icon: '5️⃣',
      quantity: 48,
    ),
    InventoryItem(
      name: 'Freeze Time',
      description: 'With this item you can freeze time for 10 seconds',
      icon: '⏱️',
      quantity: 18,
    ),
  ];
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryItems = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4e6af5),
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: inventoryItems.length,
        itemBuilder: (context, index) {
          final item = inventoryItems[index];
          
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _buildItemIcon(item),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.quantity.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
  
    );
  }

  Widget _buildItemIcon(InventoryItem item) {
    // Custom icons based on item name
    switch (item.name) {
      case 'Coins':
        return Icon(Icons.attach_money                                      , color: Colors.red, size: 40);
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
            color: Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.confirmation_number, color: Colors.white),
        );
      case 'Replay Ticket':
        return Container(
          width: 48,
          height: 48,
          child: Icon(Icons.replay_circle_filled, color: Colors.amber[700], size: 40),
        );
      case 'True Answer':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 32),
        );
      case 'Wrong Answer':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.red[200],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: Colors.white, size: 32),
        );
      case 'Fifty Fifty':
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.pink,
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
            color: Colors.red[300],
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