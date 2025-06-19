import 'package:flutter/material.dart';

class ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final String? actionText;
  final VoidCallback? onActionTap;

  const ProfileRow({
    Key? key,
    required this.label,
    required this.value,
    this.actionText,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 4, child: Text(value)),
          if (actionText != null && actionText!.isNotEmpty)
            TextButton(
              onPressed: onActionTap,
              child: Text(actionText!, style: const TextStyle(color: Colors.blueAccent)),
            ),
        ],
      ),
    );
  }
}
