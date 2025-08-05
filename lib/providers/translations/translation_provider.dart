import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/core/services/api_service.dart';
import 'package:quiz_app/core/services/translation_service.dart';
import 'package:quiz_app/core/services/chapter_service.dart';
import 'package:quiz_app/providers/language/language_provider.dart';

// Translation Service Provider
final translationServiceProvider = Provider<TranslationService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TranslationService(apiService);
});

// Default translations as fallback
const Map<String, String> _defaultTranslations = {
  'menu.home': 'Home',
  'menu.account': 'Account',
  'menu.messages': 'Messages',
  'menu.rank': 'Rank',
  'menu.market': 'Market',
  'menu.settings': 'Settings',
  'menu.inventory': 'Inventory',
  'menu.progress': 'Progress',
  'menu.statistic': 'Statistic',
  // Settings screen translations
  'settings.music': 'Music',
  'settings.dark_mode': 'Dark Mode',
  'settings.notifications': 'Notifications',
  'settings.notifications_duel': 'Notifications for Duel',
  'settings.notifications_duel_subtitle': 'Get notifications for Duel only if you are online',
  'settings.language': 'Language',
  'settings.terms_of_service': 'Terms of Service',
  'settings.privacy_policy': 'Privacy Policy',
  'settings.rate_us': 'Rate Us',
  'settings.connect_account': 'Connect Account',
  'settings.disconnect_account': 'Disconnect Account',
  'settings.reset_game': 'Reset Game',
  'settings.FAQ': 'FAQ',
  'settings.report_problem': 'Report a Problem',
  'common.guest': 'Guest',
  // Home screen menu tiles
  'home.play_quiz': 'Play Quiz',
  'home.world': 'World',
  'home.duel': 'Duel',
  'home.event': 'Event',
  'home.daily_login': 'Daily Login\nRewards',
  // Progress screen
  'progress.your_answer': 'Your Answer',
  'progress.correct_answer': 'Correct Answer',
  // Statistic screen
  'statistic.results_by_category': 'Results by category',
  'statistic.questions_answered': 'Questions answered',
  // Category names
  'category.technology': 'Technology',
  'category.physic': 'Physic',
  'category.chemistry': 'Chemistry',
  'category.mixed': 'Mixed',
  'category.astrology': 'Astrology',
  'category.biology': 'Biology',
  'category.literature': 'Literature',
  'category.true_false': 'True/false',
  'category.countries': 'Countries',
  'category.movie_tv': 'Movie & Tv',
  'category.culture': 'Culture',
  'category.geography': 'Geography',
  'category.history': 'History',
  'category.sport': 'Sport',
  // Account screen
  'account.enter_username': 'Enter your username',
  'account.user_id_label': 'ID',
  'account.id_copied': 'ID copied to clipboard',
  // Event screen
  'event.next': 'Next',
  'event.quiz_completed': 'Quiz Completed!',
  'event.your_score': 'Your Score',
  'event.restart': 'Restart',
  // Inventory items
  'inventory.coins': 'Coins',
  'inventory.coins_description': 'You can use this coins to get items from Market',
  'inventory.heart': 'Heart',
  'inventory.heart_description': 'You can use this heart to play a level',
  'inventory.duel_ticket': 'Duel Ticket',
  'inventory.duel_ticket_description': 'With this ticket you can play a duel',
  'inventory.replay_ticket': 'Replay Ticket',
  'inventory.replay_ticket_description': 'With this ticket you can play a level again',
  'inventory.true_answer': 'True Answer',
  'inventory.true_answer_description': 'With this item you can get a true answer',
  'inventory.wrong_answer': 'Wrong Answer',
  'inventory.wrong_answer_description': 'With this item you can remove one wrong answers',
  'inventory.fifty_fifty': 'Fifty Fifty',
  'inventory.fifty_fifty_description': 'With this item you can remove two wrong answers',
  'inventory.freeze_time': 'Freeze Time',
  'inventory.freeze_time_description': 'With this item you can freeze time for 10 seconds',
  'inventory.event_ticket': 'Event Ticket',
  'inventory.event_ticket_description': 'With this ticket you can play an event',
};

class TranslationNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    // Watch language changes and reload translations
    final currentLang = ref.watch(languageProvider);
    print('TranslationNotifier build called, language: $currentLang');
    
    try {
      final translationService = ref.read(translationServiceProvider);
      final translations = await translationService.getTranslations(currentLang);
      return translations;
    } catch (e) {
      print('Failed to load translations, using defaults: $e');
      return _defaultTranslations;
    }
  }

  Future<void> refreshTranslations({String? language}) async {
    state = const AsyncLoading();
    try {
      final translationService = ref.read(translationServiceProvider);
      final String currentLang = language ?? ref.read(languageProvider);
      final translations = await translationService.getTranslations(currentLang);
      state = AsyncData(translations);
    } catch (e) {
      print('Failed to refresh translations: $e');
      state = const AsyncData(_defaultTranslations);
    }
  }
}

// Translation Provider
final translationProvider = AsyncNotifierProvider<TranslationNotifier, Map<String, String>>(() {
  return TranslationNotifier();
});

// Helper provider for easy access to translated strings
final translationHelperProvider = Provider<String Function(String)>((ref) {
  final translationsAsync = ref.watch(translationProvider);
  
  return (String key) {
    return translationsAsync.when(
      data: (translations) => translations[key] ?? key,
      loading: () => _defaultTranslations[key] ?? key,
      error: (_, __) => _defaultTranslations[key] ?? key,
    );
  };
}); 