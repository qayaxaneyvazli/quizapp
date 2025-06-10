import 'package:flutter/material.dart';
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/screens/home/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  // Gradient’i üstte sabit olarak tanımla
  static const tileBgGradient = LinearGradient(
    colors: [
      Color(0xFFF4ED0D), // sarı
      Color(0xFFF8AE02), // turuncumsu
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    const purpleColor = AppColors.primary;

    return Scaffold(
      backgroundColor: purpleColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ampul ikonu
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Icon(
                      Icons.lightbulb_outline,
                      size: 120,
                      color: Color(0xFFF4ED0D),
                    ),
                  ),
                  // quizTastic yazısı
                  Text(
                    'quizTastic',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 37,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SignInButton(
  Buttons.Google,
  text: "Sign in with Google",
  onPressed: () async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final account = await googleSignIn.signIn();
      if (account != null) {
        // Giriş başarılı, burada backend'e token gönder veya yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Hata yönetimi
      print(e);
    }
  },
),
                  // Email TextField
                  // TextField(
                  //   style: TextStyle(color: Colors.black87),
                  //   decoration: InputDecoration(
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     prefixIcon: Icon(Icons.email, color: Colors.black54),
                  //     hintText: "Email",
                  //     hintStyle: TextStyle(color: Colors.black54),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     contentPadding: EdgeInsets.symmetric(vertical: 20),
                  //   ),
                  //   keyboardType: TextInputType.emailAddress,
                  // ),
                  const SizedBox(height: 18),
                  // Password TextField
                  // TextField(
                  //   obscureText: true,
                  //   style: TextStyle(color: Colors.black87),
                  //   decoration: InputDecoration(
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     prefixIcon: Icon(Icons.lock, color: Colors.black54),
                  //     hintText: "Password",
                  //     hintStyle: TextStyle(color: Colors.black54),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //     contentPadding: EdgeInsets.symmetric(vertical: 20),
                  //   ),
                  // ),
                  
                  const SizedBox(height: 28),
                  // Gradient Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GestureDetector(
                      onTap: () {
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: tileBgGradient, // <-- Burada değişiklik!
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue as Guest',
                          style: TextStyle(
                            color: purpleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Forgot password
                
                   
                  // Continue as Guest
               
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

