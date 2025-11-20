import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/providers/event/event_controller.dart'; 
import 'package:quiz_app/providers/event/event_provider.dart'; // Provider dosyasını import edin
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';

class EventScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controller'ı dinliyoruz (API verisi buraya akıyor)
    final eventState = ref.watch(eventControllerProvider);
    
    // Provider'ın yüklenme durumunu kontrol etmek için async değeri de alalım
    // Bu sayede ilk açılışta API isteği bitene kadar loading döner
    final questionsAsync = ref.watch(eventQuestionsProvider);

    return questionsAsync.when(
      // 1. YÜKLENİYORSA
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      
      // 2. HATA VARSA
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Hata: $err")),
      ),

      // 3. VERİ GELDİYSE (DATA)
      data: (_) {
        // Eğer API'den boş liste geldiyse veya servisten veri dönmediyse
        if (eventState.questions.isEmpty) {
           return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.primary, title: Text("Event")),
            body: Center(child: Text("Şu an aktif etkinlik sorusu bulunamadı.")),
           );
        }

        final currentQuestionIndex = eventState.currentQuestionIndex;

        // Quiz bitti ise sonuç ekranı
        if (currentQuestionIndex >= eventState.questions.length) {
          return _buildResultScreen(context, eventState, ref);
        }
        
        final question = eventState.questions[currentQuestionIndex];

        return Scaffold(
          backgroundColor: Colors.white, 
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/back_icon.svg',
                width: 40,
                height: 40,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              ref.tr('home.event'),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [

                // Cevap geçmişi (tik ve çarpı ikonları)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: eventState.answerResults.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final result = entry.value;
                        if (idx >= currentQuestionIndex) return SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: CircleAvatar(
                            backgroundColor: result == true
                                ? Colors.green
                                : (result == false ? Colors.red : Colors.grey),
                            child: Icon(
                              result == true
                                  ? Icons.check
                                  : (result == false ? Icons.close : null),
                              color: Colors.white,
                            ),
                            radius: 16,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Soruya ait görsel (Sadece API'den gelirse göster)
                if (question.imagePath != null && question.imagePath!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        question.imagePath!, // API'den gelen URL
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 160,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                             height: 160, 
                             color: Colors.grey[200],
                             child: Center(child: CircularProgressIndicator())
                          );
                        },
                        errorBuilder: (c, e, s) => Container(
                          width: double.infinity, 
                          height: 160, 
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else 
                  // Resim yoksa boşluk bırak veya placeholder ikon koy
                  SizedBox(height: 20),

                // Soru kutusu
                Container(
                   constraints: BoxConstraints(minHeight: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.purple,width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          question.question, // API'den gelen soru metni
                          style: TextStyle(
                            color: AppColors.primary ,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            '${currentQuestionIndex + 1}',
                            style: TextStyle(
                                color:AppColors.primary ,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          Icon(Icons.public, color: Colors.blue[400], size: 18),
                        ],
                      ),
                    ],
                  ),
                ),

                // Progress bar (kısa çizgi)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: eventState.timerValue,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Şıklar
                Expanded( // Şıkların sığması için expanded içine aldık
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: List.generate(question.options.length, (index) {
                          final isEliminated = eventState.eliminatedOptions != null &&
                              eventState.eliminatedOptions!.contains(index);
                          final isSelected = eventState.selectedAnswerIndex == index;
                          final isCorrect = index == question.correctAnswerIndex;
                          final showAsCorrect =
                              isCorrect && (eventState.isAnswerRevealed || eventState.showCorrectAnswer);

                          Color buttonColor = AppColors.primary;
                          Color textColor = Colors.white;
                          
                          if (isEliminated) {
                            buttonColor = Colors.grey.shade200;
                            textColor = Colors.grey;
                          } else if (eventState.isAnswerRevealed) {
                            if (isSelected) {
                              buttonColor = isCorrect ? Colors.green : Colors.red;
                              textColor = Colors.white;
                            } else if (isCorrect) {
                              buttonColor = Colors.green;
                              textColor = Colors.white;
                            }
                          } else if (showAsCorrect) {
                            buttonColor = Colors.green;
                            textColor = Colors.white;
                          } else if (isSelected) {
                            buttonColor = Colors.yellow.shade100;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: GestureDetector(
                              onTap: isEliminated || eventState.isAnswerRevealed
                                  ? null
                                  : () {
                                      ref.read(eventControllerProvider.notifier).selectAnswer(index);
                                    },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 180),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.transparent,
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    question.options[index], // API'den gelen şık metni
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: textColor),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                // Next butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: GestureDetector(
                    onTap: eventState.isAnswerRevealed
                        ? () {
                            ref.read(eventControllerProvider.notifier).goToNextQuestion();
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.yellow, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                           "Next",
                          style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 19),
                        ),
                      ),
                    ),
                  ),
                ),

                // Joker ve alt bar
               // Joker ve alt bar
            Container(
              margin: EdgeInsets.zero, 
              padding: EdgeInsets.zero,
              height: 50,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. YANLIŞ CEVABI ELEME (X JOKERİ)
                  _jokerButton(
                      svgPath: 'assets/icons/wrong_answer.svg',
                      // Düzeltme: Hem hak sayısına (>0) hem de şu an kullanılıp kullanılmadığına bakıyoruz
                      enabled: eventState.hintCount > 0 && 
                               !eventState.hasUsedHint && 
                               !eventState.isAnswerRevealed,
                      onTap: () {
                        ref.read(eventControllerProvider.notifier).useHint();
                      }),

                  // 2. YARI YARIYA (50/50)
                  _jokerButton(
                      svgPath:'assets/icons/fifty_fifty.svg',
                      // Düzeltme: Hak sayısı kontrolü eklendi
                      enabled: eventState.fiftyFiftyCount > 0 && 
                               !eventState.hasUsedFiftyFifty && 
                               !eventState.isAnswerRevealed,
                      onTap: () {
                        ref.read(eventControllerProvider.notifier).useFiftyFifty();
                      }),

                  // 3. DOĞRU CEVABI GÖSTERME (GÖZ)
                  _jokerButton(
                      svgPath: 'assets/icons/true_answer.svg',
                      // Düzeltme: Hak sayısı kontrolü eklendi
                      enabled: eventState.correctAnswerHintCount > 0 && 
                               !eventState.showCorrectAnswer && 
                               !eventState.isAnswerRevealed,
                      onTap: () {
                        ref.read(eventControllerProvider.notifier).showCorrectAnswerHint();
                      }),

                  // 4. SÜREYİ DONDURMA
                  _jokerButton(
                      svgPath: 'assets/icons/freeze_time.svg',
                      // Düzeltme: Hak sayısı kontrolü eklendi
                      enabled: eventState.timePauseCount > 0 && 
                               !eventState.hasUsedTimePause && 
                               !eventState.isAnswerRevealed,
                      onTap: () {
                        ref.read(eventControllerProvider.notifier).useTimePause();
                      }),

                  // 5. BİLGİ / LİNK BUTONU (Genelde sınırsızdır ama logic ekleyebilirsiniz)
                  _jokerButton(
                      svgPath: eventState.hasInfo ? 'assets/icons/info.svg' : 'assets/icons/link.svg',
                      enabled: true,
                      onTap: () {}),
                ],
              ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Joker butonu widget
  Widget _jokerButton({
    required String svgPath, 
    required bool enabled,
    required VoidCallback onTap, 
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 78,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            svgPath,
            color: enabled ? null : Colors.grey,
            width: 35, 
            height: 35, 
          ),
        ),
      ),
    );
  }

  // Quiz sonu ekranı
  Widget _buildResultScreen(BuildContext context, EventState state, WidgetRef ref) {
    int correctAnswers = state.answerResults.where((result) => result == true).length;
    int totalQuestions = state.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF8539A8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ref.tr('event.quiz_completed'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                '${ref.tr("event.your_score")}: $correctAnswers / $totalQuestions',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(ref.tr('event.restart')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}