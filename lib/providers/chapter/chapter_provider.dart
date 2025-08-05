import 'package:quiz_app/core/services/api_service.dart';
import 'package:quiz_app/core/services/chapter_service.dart';
import 'package:quiz_app/models/chapter/chapter.dart';
import 'package:quiz_app/providers/language/language_provider.dart';
import 'package:riverpod/riverpod.dart';
final chapterServiceProvider = Provider<ChapterService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ChapterService(apiService);
});

class ChapterNotifier extends AsyncNotifier<List<ChapterModel>> {
  @override
  Future<List<ChapterModel>> build() async {
    // Dil değişikliklerini dinle
    final currentLang = ref.watch(languageProvider);
    print('ChapterNotifier build çağrıldı, dil: $currentLang'); // Debug için
    
    final chapterService = ref.read(chapterServiceProvider);
    return await chapterService.getChapters();
  }

  Future<void> refreshChapters({String? language}) async {
    state = const AsyncLoading();
    try {
      final chapterService = ref.read(chapterServiceProvider);
      final chapters = await chapterService.getChapters(language: language);
      state = AsyncData(chapters);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final chapterProvider = AsyncNotifierProvider<ChapterNotifier, List<ChapterModel>>(() {
  return ChapterNotifier();
});