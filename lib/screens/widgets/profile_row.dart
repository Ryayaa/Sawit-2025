import 'package:flutter/material.dart';
import 'email_verification_dialog.dart';

class ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final String actionText;
  final VoidCallback? onActionTap; // ini ditambahkan

  const ProfileRow({
    Key? key,
    required this.label,
    required this.value,
    required this.actionText,
    this.onActionTap, // ini ditambahkan
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                softWrap: true,
              ),
            ),
          ),
          if (actionText.isNotEmpty)
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    if (actionText == 'CHANGE') {
                      showEmailVerificationDialog(context);
                    } else {
                      // jalankan custom action jika bukan 'CHANGE'
                      if (onActionTap != null) onActionTap!();
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
