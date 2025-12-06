import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

/// Supported languages (extendable later)
enum Language { vi, en }

/// Pill selector that opens a modal to choose language (design like screenshot)
class LanguageSelector extends StatelessWidget {
  final Language selected;
  final ValueChanged<Language> onChanged;
  final EdgeInsetsGeometry padding;
  final List<Language> availableLanguages;

  const LanguageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.all(0),
    this.availableLanguages = const [Language.vi, Language.en],
  });

  @override
  Widget build(BuildContext context) {
    final _LangInfo info = _langInfo(selected);
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => _openLanguageSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD6F5E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(info.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  info.short,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLanguageSheet(BuildContext context) {
    Language tempSelection = selected;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // 0.1 * 255
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)?.chooseYourLanguage ??
                            'Chọn ngôn ngữ của bạn',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6EF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: availableLanguages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final Language lang = availableLanguages[index];
                          final _LangInfo info = _langInfo(lang);
                          final bool isSelected = tempSelection == lang;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                tempSelection = lang;
                                (context as Element).markNeedsBuild();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1E3A5F)
                                        : Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(12), // 0.05 * 255
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        info.flag,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          info.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF1E3A5F),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (tempSelection != selected) {
                              onChanged(tempSelection);
                              _showLanguageChangeSuccess(
                                context,
                                tempSelection,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.apply ?? 'Áp dụng',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageChangeSuccess(BuildContext context, Language newLanguage) {
    // Get the success message based on the new language
    String message;
    switch (newLanguage) {
      case Language.vi:
        message =
            AppLocalizations.of(context)?.languageChangedToVietnamese ??
            'Đã chuyển sang tiếng Việt';
        break;
      case Language.en:
        message =
            AppLocalizations.of(context)?.languageChangedToEnglish ??
            'Language changed to English';
        break;
    }

    // Show a snackbar with success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _LangInfo {
  final String short;
  final String name;
  final String flag;
  const _LangInfo({
    required this.short,
    required this.name,
    required this.flag,
  });
}

_LangInfo _langInfo(Language lang) {
  switch (lang) {
    case Language.vi:
      return const _LangInfo(short: 'VI', name: 'Tiếng Việt', flag: '🇻🇳');
    case Language.en:
      return const _LangInfo(short: 'EN', name: 'English', flag: '🇺🇸');
  }
}
