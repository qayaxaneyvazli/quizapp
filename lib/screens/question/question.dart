
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class Question extends StatelessWidget {
  const Question({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Örnek veriler
    final question = 'What is the capital of Azerbaijan?';
    final List<String> options = [
      'Option_1',
      'Option_2',
      'Option_3',
      'Option_4',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Üst kısımda cevap durumlarını gösteren ikonlar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Örnek amaçlı 6 tane kırmızı, 4 tane yeşil ikon
              ...List.generate(6, (index) => const Icon(
                Icons.close,
                color: Colors.red,
                size: 28,
              )),
              ...List.generate(4, (index) => const Icon(
                Icons.check,
                color: Colors.green,
                size: 28,
              )),
            ],
          ),
          const SizedBox(height: 16),

          // Soru metni alanı (örneğin bir TextField yerine düz Text ile gösteriyoruz)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Sağ üst köşedeki karakter sayısı gibi küçük bir gösterge
                const SizedBox(width: 8),
                const Text(
                  '12',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // İlerleme çubuğu
          LinearProgressIndicator(
            value: 0.5, // 0.0 - 1.0 arası
            minHeight: 6,
            color: Colors.green,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),

          // Seçenekler
          Column(
            children: options.map((option) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //primary: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Seçeneğe tıklanınca olacaklar
                  },
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Alt kısımdaki ek menü (50/50 vb.)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                '50 / 50',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.check, color: Colors.green),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}