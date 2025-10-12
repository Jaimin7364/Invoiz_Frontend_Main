import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(localizations.language),
          subtitle: Text(
            languageService.currentLocale.languageCode == 'gu' 
                ? localizations.gujarati 
                : localizations.english
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showLanguageSelector(context, languageService, localizations),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, LanguageService languageService, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              languageService,
              'en',
              localizations.english,
              Icons.language,
            ),
            const SizedBox(height: AppSizes.sm),
            _buildLanguageOption(
              context,
              languageService,
              'gu',
              localizations.gujarati,
              Icons.language,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageService languageService,
    String languageCode,
    String languageName,
    IconData icon,
  ) {
    final isSelected = languageService.currentLocale.languageCode == languageCode;
    
    return InkWell(
      onTap: () async {
        await languageService.changeLanguage(languageCode);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language changed to $languageName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                languageName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}