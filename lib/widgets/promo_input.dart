// lib/widgets/promo_input.dart
import 'package:flutter/material.dart';

class PromoInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;

  const PromoInput({
    required this.controller,
    required this.onApply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: onApply,
          child: Text('Apply'),
        ),
      ],
    );
  }
}
