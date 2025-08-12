import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory.dart/inventory_item.dart';
import '../user_stats/user_stats_provider.dart';

// Provider that creates inventory items from user stats
final inventoryProvider = Provider<List<InventoryItem>>((ref) {
  final userStatsAsync = ref.watch(userStatsProvider);
  
  return userStatsAsync.when(
    data: (userStats) {
      if (userStats == null) {
        // Return default items if no user stats available
        return _getDefaultInventoryItems();
      }
      
      // Create inventory items from user stats
      return [
        InventoryItem(
          name: 'inventory.coins',
          description: 'inventory.coins_description',
          icon: '💰',
          quantity: userStats.coins,
        ),
        InventoryItem(
          name: 'inventory.heart',
          description: 'inventory.heart_description',
          icon: '❤️',
          quantity: userStats.heartsDisplayValue,
        ),
        InventoryItem(
          name: 'inventory.duel_ticket',
          description: 'inventory.duel_ticket_description',
          icon: '🎫',
          quantity: userStats.ticketDuel,
        ),
        InventoryItem(
          name: 'inventory.replay_ticket',
          description: 'inventory.replay_ticket_description',
          icon: '🎟️',
          quantity: userStats.ticketReplay,
        ),
        InventoryItem(
          name: 'inventory.true_answer',
          description: 'inventory.true_answer_description',
          icon: '✅',
          quantity: userStats.jokerTrueAnswer,
        ),
        InventoryItem(
          name: 'inventory.wrong_answer',
          description: 'inventory.wrong_answer_description',
          icon: '❌',
          quantity: userStats.jokerWrongAnswer,
        ),
        InventoryItem(
          name: 'inventory.fifty_fifty',
          description: 'inventory.fifty_fifty_description',
          icon: '5️⃣',
          quantity: userStats.jokerFiftyFifty,
        ),
        InventoryItem(
          name: 'inventory.freeze_time',
          description: 'inventory.freeze_time_description',
          icon: '⏱️',
          quantity: userStats.jokerFreezeTime,
        ),
        InventoryItem(
          name: 'inventory.event_ticket',
          description: 'inventory.event_ticket_description',
          icon: '🎪',
          quantity: userStats.ticketEvent,
        ),
      ];
    },
    loading: () => _getDefaultInventoryItems(),
    error: (error, stack) => _getDefaultInventoryItems(),
  );
});

// Default inventory items for fallback
List<InventoryItem> _getDefaultInventoryItems() {
  return [
    InventoryItem(
      name: 'inventory.coins',
      description: 'inventory.coins_description',
      icon: '💰',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.heart',
      description: 'inventory.heart_description',
      icon: '❤️',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.duel_ticket',
      description: 'inventory.duel_ticket_description',
      icon: '🎫',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.replay_ticket',
      description: 'inventory.replay_ticket_description',
      icon: '🎟️',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.true_answer',
      description: 'inventory.true_answer_description',
      icon: '✅',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.wrong_answer',
      description: 'inventory.wrong_answer_description',
      icon: '❌',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.fifty_fifty',
      description: 'inventory.fifty_fifty_description',
      icon: '5️⃣',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.freeze_time',
      description: 'inventory.freeze_time_description',
      icon: '⏱️',
      quantity: 0,
    ),
    InventoryItem(
      name: 'inventory.event_ticket',
      description: 'inventory.event_ticket_description',
      icon: '🎪',
      quantity: 0,
    ),
  ];
}