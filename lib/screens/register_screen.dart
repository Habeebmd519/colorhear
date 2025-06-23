import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import 'detecting_from_camera_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  bool isLoading = false;

  void handleRegister() async {
    FocusScope.of(context).unfocus();
    if (passwordController.text != confmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);
    try {
      await AuthenticationService.register(
        emailController.text,
        passwordController.text,
      );
       Navigator.of(context).pushNamedAndRemoveUntil(
          '/colorDetect',
          (Route<dynamic> route) => false,
        );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration Failed: $e')));
      print(e);
    }
    setState(() => isLoading = false);
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
            colors: [Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFF9333EA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                    const SizedBox(height: 5),
                    Text(
                      "Join Colorhear",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Create your account to get started",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildGlassTextField(
                      context,
                      "Full name",
                      Icon(
                        Icons.person_2_outlined,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      fullNameController,
                    ),
                    const SizedBox(height: 20),
                    _buildGlassTextField(
                      context,
                      "Email address",
                      Icon(
                        Icons.email_outlined,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      emailController,
                    ),
                    const SizedBox(height: 20),
                    _buildGlassTextField(
                      context,
                      "Password",
                      Icon(
                        Icons.lock_outline,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      passwordController,
                    ),
                    const SizedBox(height: 20),
                    _buildGlassTextField(
                      context,
                      "Confirm password",
                      Icon(
                        Icons.lock_outline,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      confmPasswordController,
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(16),
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
                        onPressed: handleRegister,
                        child:
                            isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                  "Register",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: TextButton(
                        child: Text(
                          "Already have an account? Sign in",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
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
    );
  }
}
