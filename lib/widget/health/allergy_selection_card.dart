import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import '../../l10n/app_localizations.dart';
import '../../common/app_styles.dart';
import '../../common/app_colors.dart';

class AllergySelectionCard extends StatefulWidget {
  final List<String> selectedAllergies;
  final ValueChanged<List<String>> onAllergiesChanged;

  const AllergySelectionCard({
    super.key,
    required this.selectedAllergies,
    required this.onAllergiesChanged,
  });

  @override
  State<AllergySelectionCard> createState() => _AllergySelectionCardState();
}

class _AllergySelectionCardState extends State<AllergySelectionCard> {
  final TextEditingController _allergyCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late Map<String, String> _allergyEmojis;
  late Map<String, String> _normalizedToDisplay;
  late List<String> _commonAllergies;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _allergyEmojis = {
      loc.allergySeafood: '🦞',
      loc.allergyMilk: '🥛',
      loc.allergyPeanuts: '🥜',
      loc.allergyEggs: '🥚',
      loc.allergyWheat: '🌾',
      loc.allergySoy: '🫘',
      loc.allergyFish: '🐟',
      loc.allergyNuts: '🌰',
      loc.allergyShrimp: '🦐',
      loc.allergyCrab: '🦀',
      loc.allergyBeef: '🥩',
      loc.allergyChicken: '🍗',
      loc.allergySesame: '🌱',
      loc.allergyScallops: '🐚',
      loc.allergySnails: '🐌',
      loc.allergyGluten: '🍞',
      loc.allergyLactose: '🥛',
      loc.allergyHoney: '🍯',
      loc.allergyStrawberry: '🍓',
      loc.allergyKiwi: '🥝',
      loc.allergyTomato: '🍅',
      loc.allergyMushroom: '🍄',
      loc.allergyAlcohol: '🍺',
      loc.allergyPreservatives: '🧪',
      loc.allergyFoodColoring: '🎨',
      loc.allergyMustard: '🌭',
      loc.allergyCelery: '🥬',
      loc.allergyAlmond: '🌰',
      loc.allergyCashew: '🥜',
      loc.allergyWalnut: '🌰',
      loc.allergyChestnut: '🌰',
      loc.allergyOats: '🥣',
      loc.allergyCorn: '🌽',
      loc.allergyBanana: '🍌',
      loc.allergyPineapple: '🍍',
      loc.allergyGarlic: '🧄',
      loc.allergyOnion: '🧅',
      loc.allergyChocolate: '🍫',
      loc.allergyCoffee: '☕',
    };
    _commonAllergies = _allergyEmojis.keys.toList();
    _normalizedToDisplay = {};
    for (final key in _commonAllergies) {
      _normalizedToDisplay[removeDiacritics(key).toLowerCase()] = key;
    }
  }

  String _getEmoji(String allergy) {
    // Try to find exact match
    if (_allergyEmojis.containsKey(allergy)) {
      return _allergyEmojis[allergy]!;
    }
    // Try to find case-insensitive match using cached map
    final normalized = removeDiacritics(allergy).toLowerCase();
    final displayKey = _normalizedToDisplay[normalized];
    if (displayKey != null) {
      return _allergyEmojis[displayKey]!;
    }
    return '🍽️'; // Default emoji
  }

  @override
  void dispose() {
    _allergyCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addAllergy(String text) {
    final normalizedText = removeDiacritics(text).toLowerCase();
    if (normalizedText.isEmpty) return;

    final exists = widget.selectedAllergies.any(
      (e) => removeDiacritics(e).toLowerCase() == normalizedText,
    );

    if (!exists) {
      final match = _normalizedToDisplay[normalizedText] ?? text.trim();

      final newList = List<String>.from(widget.selectedAllergies)..add(match);
      widget.onAllergiesChanged(newList);
    }
    _allergyCtrl.clear();
  }

  void _removeAllergy(String allergy) {
    final newList = List<String>.from(widget.selectedAllergies)
      ..remove(allergy);
    widget.onAllergiesChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "2",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.foodAllergiesTitle,
                  style: AppStyles.heading2.copyWith(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.foodAllergiesSubtitle,
            style: AppStyles.bodySmall,
          ),
          const SizedBox(height: 16),

          // Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return RawAutocomplete<String>(
                      textEditingController: _allergyCtrl,
                      focusNode: _focusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        final normalizedInput = removeDiacritics(
                          textEditingValue.text,
                        ).toLowerCase();
                        return _normalizedToDisplay.entries
                            .where((entry) => entry.key.contains(normalizedInput))
                            .map((entry) => entry.value);
                      },
                      onSelected: (String selection) {
                        _allergyCtrl.text = selection;
                        _allergyCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: _allergyCtrl.text.length),
                        );
                      },
                      optionsViewBuilder:
                          (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                child: Container(
                                  width: constraints.maxWidth,
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: RepaintBoundary(
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            height: 1,
                                            color: AppColors.grey200,
                                          ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            final String option = options
                                                .elementAt(index);
                                            return InkWell(
                                              onTap: () => onSelected(option),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 16,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      _getEmoji(option),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(option),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                      fieldViewBuilder:
                          (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .foodAllergiesHint,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.emoji_food_beverage_outlined,
                                    color: Colors.orange,
                                  ),
                                ),
                                onSubmitted: (value) => _addAllergy(value),
                              ),
                            );
                          },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _addAllergy(_allergyCtrl.text),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Text(
                        '+ ${AppLocalizations.of(context)!.add}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (widget.selectedAllergies.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.no_food_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.noAllergiesAdded,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedAllergies.map((allergy) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_getEmoji(allergy)} $allergy',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _removeAllergy(allergy),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
