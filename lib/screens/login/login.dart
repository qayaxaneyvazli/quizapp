import 'package:flutter/material.dart';
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/core/services/firebase_auth.dart';
import 'package:quiz_app/screens/home/home_screen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
 
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showEmailLogin = false;

  // Gradient'i üstte sabit olarak tanımla
  static const tileBgGradient = LinearGradient(
    colors: [
      Color(0xFFF4ED0D), // sarı
      Color(0xFFF8AE02), // turuncumsu
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Google ilə giriş
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success']) {
        // Giriş uğurlu oldu
        _showSnackBar('Google login successful!', Colors.green);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
       
        _showSnackBar('Google login failed: ${result['error']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInAsGuest();

      if (result['success']) {
        _showSnackBar('Guest login successful!', Colors.green);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        _showSnackBar('Guest login failed: ${result['error']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // Email/Password ilə giriş
  Future<void> _signInWithEmailPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter email and password', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (result['success']) {
        // Giriş uğurlu oldu
        _showSnackBar('Email login successful!', Colors.green);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Giriş uğursuz oldu
        _showSnackBar('Email login failed: ${result['error']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // SnackBar göstər
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 120,
                      color: Color(0xFFF4ED0D),
                    ),
                  ),
                  // quizTastic yazısı
                  const Text(
                    'quizTastic',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 37,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _signInWithGoogle(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      icon: Image.asset(
                        'assets/images/google_logo.png', // Google logo əlavə edin
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.account_circle, size: 24),
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email/Password giriş toggle
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       _showEmailLogin = !_showEmailLogin;
                  //     });
                  //   },
                  //   child: Text(
                  //     _showEmailLogin ? 'Hide Email Login' : 'Sign in with Email',
                  //     style: const TextStyle(
                  //       color: Colors.white,
                  //       decoration: TextDecoration.underline,
                  //       fontSize: 16,
                  //     ),
                  //   ),
                  // ),
                  
                  // Email/Password giriş formu
                  // if (_showEmailLogin) ...[
                  //   const SizedBox(height: 20),
                  //   // Email TextField
                  //   TextField(
                  //     controller: _emailController,
                  //     style: const TextStyle(color: Colors.black87),
                  //     decoration: InputDecoration(
                  //       filled: true,
                  //       fillColor: Colors.white,
                  //       prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  //       hintText: "Email",
                  //       hintStyle: const TextStyle(color: Colors.black54),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //       contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  //     ),
                  //     keyboardType: TextInputType.emailAddress,
                  //   ),
                  //   const SizedBox(height: 16),
                  //   // Password TextField
                  //   TextField(
                  //     controller: _passwordController,
                  //     obscureText: true,
                  //     style: const TextStyle(color: Colors.black87),
                  //     decoration: InputDecoration(
                  //       filled: true,
                  //       fillColor: Colors.white,
                  //       prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                  //       hintText: "Password",
                  //       hintStyle: const TextStyle(color: Colors.black54),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(14),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //       contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  //     ),
                  //   ),
                  //   const SizedBox(height: 16),
                  //   // Email Login Button
                  //   SizedBox(
                  //     width: double.infinity,
                  //     height: 56,
                  //     child: ElevatedButton(
                  //       onPressed: _isLoading ? null : _signInWithEmailPassword,
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: const Color(0xFFF4ED0D),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(14),
                  //         ),
                  //       ),
                  //       child: _isLoading
                  //           ? const SizedBox(
                  //               height: 20,
                  //               width: 20,
                  //               child: CircularProgressIndicator(strokeWidth: 2),
                  //             )
                  //           : const Text(
                  //               'Sign In',
                  //               style: TextStyle(
                  //                 color: AppColors.primary,
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: 18,
                  //               ),
                  //             ),
                  //     ),
                  //   ),
                  // ],
                  
                  const SizedBox(height: 28),
                  
                  // Continue as Guest Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GestureDetector(
                     onTap: _isLoading ? null : _signInAsGuest,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: tileBgGradient,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
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
                  
                  const SizedBox(height: 40),
                  
                  // Loading indicator
                  if (_isLoading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}