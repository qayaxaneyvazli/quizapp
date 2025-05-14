import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

Future<void> showNoTicketDialog(BuildContext ctx) {
  return showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Not Enough Tickets',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_activity, size: 64, color: Color.fromARGB(255, 109, 190, 180)),
          SizedBox(height: 20),
          Text(
            "You don't have enough Event Tickets to start a new Event.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
