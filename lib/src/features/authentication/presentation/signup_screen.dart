import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waverate/src/features/authentication/data/auth_repository.dart';
import 'package:waverate/src/features/authentication/data/user_repository.dart';
import 'package:waverate/src/features/authentication/domain/app_user.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController(); // Display Name
  final _usernameController = TextEditingController(); // Unique Username
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    if (username.isEmpty || username.length < 3) {
      _showError('Username must be at least 3 characters.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email.');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      _showError('Password must contain at least one uppercase letter.');
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      _showError('Password must contain at least one number.');
      return;
    }

    try {
      final userRepo = ref.read(userRepositoryProvider);

      // 1. Check Username Availability
      final isAvailable = await userRepo.checkUsernameAvailable(username);
      if (!mounted) return; // Fix async gap

      if (!isAvailable) {
        _showError('Username "$username" is already taken.');
        return;
      }

      final authRepo = ref.read(authRepositoryProvider);
      // 2. Create Auth User
      final credential =
          await authRepo.createUserWithEmailAndPassword(email, password);
      if (!mounted) return; // Fix async gap

      // 3. Create User Profile
      if (credential.user != null) {
        final newUser = AppUser(
          uid: credential.user!.uid,
          email: email,
          username: username,
          displayName: name,
          createdAt: DateTime.now(),
        );
        await userRepo.createUserProfile(newUser);
        if (!mounted) return; // Fix async gap
      }

      // Send verification email
      await authRepo.sendEmailVerification();
      if (!mounted) return; // Fix async gap

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Verify your email'),
          content: Text(
            'A verification email has been sent to $email.\nPlease verify your email before logging in.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.go('/'); // Go to Login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Clean up error message for display
      String message = e.toString();
      if (message.contains(']')) {
        message = message.split(']').last.trim();
      }
      if (mounted) _showError(message);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              const SizedBox(height: 48),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person_outline,
                delay: 200.ms,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
                delay: 300.ms,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                delay: 400.ms,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outlined,
                obscureText: true,
                delay: 600.ms,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _signup,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    required Duration delay,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay)
        .slideX(begin: 0.2, end: 0); // Slide from right for signup
  }
}
