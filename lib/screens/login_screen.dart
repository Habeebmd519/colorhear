import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import 'detecting_from_camera_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final user = await AuthenticationService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      } else {
        // ✅ Success: navigate
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/colorDetect',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
      print(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildGlassTextField(
    BuildContext context,
    String text,
    // VoidCallback onPressed,
    Icon icon,
    TextEditingController controller,
  ) {
    return Container(
      // padding: EdgeInsets.only(left: 10),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: text,
          hintStyle: TextStyle(color: Colors.white),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          prefixIcon: icon,
          prefixIconConstraints: BoxConstraints(minHeight: 24, minWidth: 48),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF9333EA), Color(0xFFEC4899)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.palette_outlined,
                        size: 64,
                        color: Colors.white,
                      ),

                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Sign in to continue detecting colors",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildGlassTextField(
                        context,
                        "Email address",
                        Icon(
                          Icons.person_2_outlined,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        emailController,
                      ),
                      const SizedBox(height: 20),
                      _buildGlassTextField(
                        context,
                        "Password",
                        Icon(Icons.lock, color: Colors.white.withOpacity(0.8)),
                        passwordController,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              // Color(0xFF2563EB),
                              Color(0xFF9333EA),
                              // Color(0xFFEC4899).withOpacity(0.1),
                              // Color(0xFFEC4899),
                              Color(0xFFEC4899),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: [
                                Color(0xFF9333EA),
                                Color(0xFFEC4899),
                              ].first.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: handleLogin,
                          child:
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                    "Sign In",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          child: Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
