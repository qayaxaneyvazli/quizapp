import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';

class LanguageModal extends ConsumerWidget {
  final VoidCallback? onClose;
  final Function(String) onLanguageSelected;

  const LanguageModal({
    Key? key,
    this.onClose,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, String>> languages = [
      {'label': 'English', 'value': 'en'},
      {'label': 'Deutsch', 'value': 'de'},
      {'label': 'Français', 'value': 'fr'},
      {'label': 'Español', 'value': 'es'},
      {'label': '日本語', 'value': 'ja'},
      {'label': '中国人', 'value': 'zh'},
    ];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFFF3E9FF),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      ref.tr('settings.language'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Choose your language',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: languages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.7,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        return GestureDetector(
                          onTap: () => onLanguageSelected(lang['value']!),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFF4ED0D), Color(0xFFF8AE02)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lang['label']!,
                              style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
              if (onClose != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Color(0xFF7C3AED)),
                    onPressed: onClose,
                    splashRadius: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
