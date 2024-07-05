import 'package:flutter/material.dart';
import 'package:front/notifier/theme_notifier.dart';
import 'package:front/theme/theme_colors.dart';
import 'package:provider/provider.dart';

extension ThemeExtension on BuildContext {
  ThemeNotifier get themeNotifier => read<ThemeNotifier>();

  ThemeColors get themeColors {
    return ThemeColors(
        backgroundColor: themeNotifier.themeColors.backgroundColor,
        backgroundAccentColor: themeNotifier.themeColors.backgroundAccentColor,
        invertedBackgroundColor:
            themeNotifier.themeColors.invertedBackgroundColor,
        secondaryBackgroundAccentColor:
            themeNotifier.themeColors.secondaryBackgroundAccentColor,
        secondaryBackgroundAccentActiveColor:
            themeNotifier.themeColors.secondaryBackgroundAccentActiveColor,
        accentColor: themeNotifier.themeColors.accentColor,
        fontColor: themeNotifier.themeColors.fontColor);
  }
}
