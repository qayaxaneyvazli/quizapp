import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginRewardsScreen extends StatelessWidget {
  const LoginRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainPurple = Color(0xFF8A2CCB); // app-bar & borders
    const Color bgColor = Color(0xFFF4F1FA);    // screen background
    const Color claimedBg = Color(0xFFD9D9DD);  // greyed tiles

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: mainPurple,
        elevation: 0,
      leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              width: 24,
              height: 24,
         
            ),
          ),
        ),
        title: const Text(
          'Login Rewards',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              _tile(
                calendar: 'assets/icons/number1_calendar.svg',
                rewardSvg:  'assets/icons/coin_top_menu.svg' ,
                iconColor: const Color(0xFFFFC85D),
                label: '+500',
                border: mainPurple,
                bg: claimedBg,
                disabled: true,
              ),
              _tile(
                calendar: 'assets/icons/number2_calendar.svg',
                rewardSvg:  'assets/icons/coin_top_menu.svg' ,
                iconColor: const Color(0xFFEB5569),
                label: '+2',
                border: mainPurple,
                bg: claimedBg,
                disabled: true,
              ),
              _tile(
                calendar: 'assets/icons/number3_calendar.svg',
                rewardSvg:  'assets/icons/wrong_answer.svg' ,
                iconColor: const Color(0xFFFF6B6B),
                label: '+1',
                border: mainPurple,
              ),
              _tile(
                calendar: 'assets/icons/number4_calendar.svg',
                rewardSvg:  'assets/icons/fifty_fifty.svg' ,
                iconColor: const Color(0xFF12C57C),
                label: '+1',
                border: mainPurple,
              ),
              _tile(
                calendar: 'assets/icons/number5_calendar.svg',
                rewardSvg:  'assets/icons/coin_top_menu.svg' ,
                iconColor: const Color(0xFFE96898),
                label: '+1',
                border: mainPurple,
              ),
              _tile(
                calendar: 'assets/icons/number6_calendar.svg',
                rewardSvg:  'assets/icons/ticket.svg' ,
                iconColor: const Color(0xFFFFC85D),
                label: '1000',
                border: mainPurple,
              ),
              _tile(
                calendar: 'assets/icons/number7_calendar.svg',
                rewardSvg: 'assets/icons/true_answer.svg',
                iconColor: const Color(0xFFFF8C3A),
                label: '+1',
                border: mainPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required String calendar,
  required String rewardSvg,
    required Color iconColor,
    required String label,
    required Color border,
    Color? bg,
    bool disabled = false,
  }) {
    const double w = 90;
    const double h = 200;

    final container = Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            child: SvgPicture.asset(calendar, fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
          SvgPicture.asset(rewardSvg, height: 40, width: 40),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: border,
            ),
          ),
        ],
      ),
    );

    return disabled ? Opacity(opacity: 0.5, child: container) : container;
  }
}
