import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/providers/event/event_service.dart';
 
import 'package:quiz_app/providers/event/event_controller.dart';

// 1. Provider artık doğrudan EventService'i çağırıyor
final eventQuestionsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  // API isteği burada atılıyor
  final questions = await EventService.fetchEventQuestions();
  return questions;
});

// 2. Controller Provider (API'den gelen veriyi bekler)
final eventControllerProvider = StateNotifierProvider.autoDispose<EventController, EventState>((ref) {
  final questionsAsync = ref.watch(eventQuestionsProvider);
  
  return questionsAsync.when(
    data: (questions) {
      // API'den sorular geldiğinde controller'a yükle
      return EventController(questions);
    },
    loading: () {
      // Yüklenirken boş liste ile başlat (Loading göstergesi için)
      return EventController([]); 
    },
    error: (error, stack) {
      print("Event API Hatası: $error");
      // Hata durumunda boş liste (Hata ekranı için)
      return EventController([]); 
    },
  );
});