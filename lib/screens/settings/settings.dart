import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMusicOn = true;
  bool isDarkModeOn = false;
  bool isNotificationsOn = true;
bool get musicStatus => isMusicOn;
  final List<String> menuItems = [
    'Language',
    'Terms of Service',
    'Privacy Policy',
    'Rate Us',
    'Connect Account',
    'Reset Game',
    'FAQ',
    'Report a Problem',
  ];

   
  late List<bool> expanded;

  @override
  void initState() {
    super.initState();
    expanded = List.generate(menuItems.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 🎵 Ayar Satırları: Music, Dark Mode ve Notifications ikonlarıyla
          _buildSwitchTile(
            title: 'Music',
            value: isMusicOn,
              iconColor: Colors.blueAccent,
             icon: Icons.music_note,
            onChanged: (val) => setState(() => isMusicOn = val),
          ),
          _buildSwitchTile(
            title: 'Dark Mode',
            value: isDarkModeOn,
            icon: Icons.dark_mode,
            iconColor: Colors.black45,
            onChanged: (val) => setState(() => isDarkModeOn = val),
          ),
        _buildSwitchTile(
            title: 'Notifications',
            value: isNotificationsOn,
            icon: Icons.notifications,
            iconColor: Colors.redAccent,
            onChanged: (val) => setState(() => isNotificationsOn = val),
          ),

          const SizedBox(height: 20),

          // 🗂️ Menü Liste Elemanları: Tıklanabilir, genişleyen alanlı
          Column(
            children: List.generate(menuItems.length, (index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        expanded[index] = !expanded[index];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            menuItems[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Ok simgesi tıklanma durumuna göre döner
                          Transform.rotate(
                            angle: expanded[index] ? pi : 0,
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Genişleyen detay alanı
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ConstrainedBox(
                      constraints: expanded[index]
                          ? const BoxConstraints()
                          : const BoxConstraints(maxHeight: 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          'Detaylar buraya gelecek...',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

Widget _buildSwitchTile({
  required String title,
  required bool value,
  required IconData icon,
  required Color iconColor,
  required ValueChanged<bool> onChanged,
}) {
  return Card(
    child: ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? Colors.blue
              : Colors.grey.withOpacity(0.5);
        }),
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? Colors.white
              : Colors.grey;
        }),
      ),
    ),
  );
}
}
