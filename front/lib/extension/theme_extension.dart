import 'package:flutter/material.dart';
import 'package:front/main.dart';
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
        accentColor: themeNotifier.themeColors.accentColor,
        fontColor: themeNotifier.themeColors.fontColor);
  }
}
