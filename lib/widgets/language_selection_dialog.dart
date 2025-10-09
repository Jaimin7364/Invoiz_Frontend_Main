import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        localizations.selectLanguage,
        style: AppTextStyles.h5.copyWith(
          color: AppColors.primary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: languageService.supportedLanguages.map((language) {
          final isSelected = languageService.currentLocale.languageCode == language['code'];
          
          return ListTile(
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            title: Text(
              language['nativeName']!,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              language['name']!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () {
              languageService.changeLanguage(language['code']!);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}