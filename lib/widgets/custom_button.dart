import 'package:flutter/material.dart';

class CustomButton {
  Widget custButton({
    required BuildContext context, // Make context required
    required Widget labelWidget,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.15),
          onTap: isDisabled ? null : onTap,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity, // Use double.infinity for width
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              child: labelWidget,
            ),
          ),
        ),
      ),
    );
  }
}
