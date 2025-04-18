// lib/views/auth/signup_page.dart
import 'package:flutter/material.dart';
import 'package:mema/views/shared/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _signUpWithEmail() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 120),
                const SizedBox(height: 32),
                Text("Inscription", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Créer un compte',
                  onPressed: _isLoading ? null : _signUpWithEmail,
                ),
                const SizedBox(height: 16),
                const Text("Ou"),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Inscription avec Google',
                  onPressed: _isLoading ? null : _signUpWithGoogle,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Déjà un compte ? Connexion"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
