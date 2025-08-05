import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory.dart/inventory_item.dart';

final inventoryProvider = StateProvider<List<InventoryItem>>((ref) {
  return [
    InventoryItem(
      name: 'inventory.coins',
      description: 'inventory.coins_description',
      icon: '💰',
      quantity: 7000,
    ),
    InventoryItem(
      name: 'inventory.heart',
      description: 'inventory.heart_description',
      icon: '❤️',
      quantity: 21,
    ),
    InventoryItem(
      name: 'inventory.duel_ticket',
      description: 'inventory.duel_ticket_description',
      icon: '🎫',
      quantity: 12,
    ),
    InventoryItem(
      name: 'inventory.replay_ticket',
      description: 'inventory.replay_ticket_description',
      icon: '🎟️',
      quantity: 7,
    ),
    InventoryItem(
      name: 'inventory.true_answer',
      description: 'inventory.true_answer_description',
      icon: '✅',
      quantity: 3,
    ),
    InventoryItem(
      name: 'inventory.wrong_answer',
      description: 'inventory.wrong_answer_description',
      icon: '❌',
      quantity: 33,
    ),
    InventoryItem(
      name: 'inventory.fifty_fifty',
      description: 'inventory.fifty_fifty_description',
      icon: '5️⃣',
      quantity: 48,
    ),
    InventoryItem(
      name: 'inventory.freeze_time',
      description: 'inventory.freeze_time_description',
      icon: '⏱️',
      quantity: 18,
    ),
  ];
});