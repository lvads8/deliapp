import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const MyElevatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    final theme = Theme.of(context);
    final buttonTheme = theme.buttonTheme.colorScheme!;

    return AnimatedContainer(
      constraints: const BoxConstraints(
        minHeight: 40,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: onPressed == null ? theme.disabledColor : buttonTheme.primary,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Material(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                label,
                style: TextStyle(
                  color: buttonTheme.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
