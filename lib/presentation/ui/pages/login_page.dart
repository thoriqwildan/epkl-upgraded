import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/ui/pages/main_page.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInSlideUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<FadeInSlideUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Mulai animasi setelah delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// --- HALAMAN LOGIN UTAMA ---
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        success: (user) {
          showAppSnackBar(context, message: 'Selamat datang, ${user.name}!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
          );
        },
        error: (message) {
          showAppSnackBar(context, message: message, isError: true);
        },
      );
    });

    return Scaffold(
      // Menggunakan Stack untuk menumpuk background dan konten
      body: Stack(
        children: [
          // --- 1. Latar Belakang Dinamis ---
          _buildBackgroundShapes(theme),

          // --- 2. Konten Utama ---
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header dengan Animasi
                    FadeInSlideUp(
                      delay: const Duration(milliseconds: 200),
                      child: _buildHeader(context),
                    ),
                    const SizedBox(height: 32),

                    // Kartu Kaca dengan Animasi
                    FadeInSlideUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildGlassmorphicCard(theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundShapes(ThemeData theme) {
    return Container(
      color: theme.colorScheme.background,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -150,
            child: Container(
              height: 400,
              width: 400,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -180,
            child: Container(
              height: 450,
              width: 450,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/smk2-logo.png',
          height: 140, // Logo lebih besar
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.school,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'E-PKL Login',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGlassmorphicCard(ThemeData theme) {
    // ClipRRect untuk memberikan sudut melengkung pada efek blur
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        // Efek blur utama
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(
              0.5,
            ), // Warna kaca semi-transparan
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.surface.withOpacity(0.7),
              width: 1.5,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Silakan Masuk',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildEmailField(theme),
                const SizedBox(height: 16),
                _buildPasswordField(theme),
                _buildForgotPasswordButton(), // Tambahan
                const SizedBox(height: 24),
                _buildLoginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // (Widget _buildEmailField, _buildPasswordField, _buildLoginButton tidak berubah banyak,
  // hanya penyesuaian kecil. Saya sertakan lagi untuk kelengkapan)

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: theme.colorScheme.background.withOpacity(
          0.7,
        ), // Lebih kontras
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Masukkan format email yang valid';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submitLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () =>
              setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: theme.colorScheme.background.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Buat halaman lupa password
        },
        child: const Text('Lupa Password?'),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        final isLoading = authState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return ElevatedButton(
          onPressed: isLoading ? null : _submitLogin,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : const Text('LOGIN'),
        );
      },
    );
  }
}
