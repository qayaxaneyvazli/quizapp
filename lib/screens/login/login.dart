import 'package:flutter/material.dart';
import 'package:quiz_app/screens/home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const purpleColor = Color.fromARGB(255, 113, 32, 167);
    const yellowColor = Color(0xFFFFEB3B);
    const orangeColor = Color(0xFFFFC107);

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
                      color: yellowColor,
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
                  // Email TextField
                  TextField(
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.email, color: Colors.black54),
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  // Password TextField
                  TextField(
                    obscureText: true,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock, color: Colors.black54),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Gradient Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GestureDetector(
                      onTap: () {
                        // Login butonuna tıklanınca işlemler
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [yellowColor, orangeColor],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Log In',
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
                  TextButton(
                    onPressed: () {
                      // Şifreyi unuttum
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Continue as Guest
                  GestureDetector(
                    onTap: () {
                       
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  const HomeScreen(),
                        ));
                    },
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
