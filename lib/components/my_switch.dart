import 'package:flutter/material.dart';

class MySwitch extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;

  const MySwitch({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final buttonTheme = Theme.of(context).buttonTheme.colorScheme!;

    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        width: 50,
        height: 25,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutExpo,
        decoration: BoxDecoration(
          color: value ? theme.primary : Colors.transparent,
          border: Border.all(color: theme.onBackground),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              top: 1,
              left: value ? 26 : 1,
              width: 21,
              height: 21,
              child: Container(
                decoration: BoxDecoration(
                  color: buttonTheme.background,
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? buttonTheme.background
                        : buttonTheme.onBackground,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutExpo,
            ),
          ],
        ),
      ),
    );
  }
}
