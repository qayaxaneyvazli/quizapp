import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';

class TranslatedText extends ConsumerWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.translationKey, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationHelperProvider);
    
    return Text(
      translate(translationKey),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

extension TranslationExtension on WidgetRef {
  String tr(String key) {
    return watch(translationHelperProvider)(key);
  }
} 