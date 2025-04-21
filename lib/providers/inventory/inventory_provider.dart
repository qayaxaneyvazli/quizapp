import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory.dart/inventory_item.dart';

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