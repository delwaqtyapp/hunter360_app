import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hunter360_app/core/network/api_client.dart';
import 'package:hunter360_app/core/constants/app_constants.dart';
import 'package:hunter360_app/core/l10n/app_localizations.dart';
import 'package:hunter360_app/core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverUrlController = TextEditingController();
  bool _obscurePassword = true;
  bool _showServerConfig = false;
  String? _licenseStatus;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _serverUrlController.text = ref.read(serverUrlProvider);
    _checkLicense();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> _checkLicense() async {
    final prefs = await SharedPreferences.getInstance();
    var license = prefs.getString('LicenseData');
    if (license == null || license.isEmpty) {
      try {
        final bd = await rootBundle.load('assets/lic_out.lic');
        license = String.fromCharCodes(bd.buffer.asUint8List());
        await prefs.setString('LicenseData', license);
      } catch (_) {}
    }
    if (!mounted) return;
    if (license != null && license.isNotEmpty) {
      try {
        final data = jsonDecode(license);
        setState(() {
          _licenseStatus = data['company']?.toString() ?? 'Licensed';
        });
      } catch (_) {
        setState(() => _licenseStatus = 'Licensed');
      }
    }
  }

  Future<void> _uploadLicense() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final ext = file.extension?.toLowerCase() ?? '';
      if (!['json', 'lic', 'txt'].contains(ext)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only .json, .lic, .txt files are supported'), backgroundColor: Colors.orange),
          );
        }
        return;
      }
      String content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('LicenseData', content);
      String companyName = 'Licensed';
      try {
        final data = jsonDecode(content);
        companyName = data['company']?.toString() ?? 'Licensed';
      } catch (_) {
        companyName = 'Licensed ($ext)';
      }
      setState(() => _licenseStatus = companyName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('License loaded: $companyName'), backgroundColor: AppTheme.successColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid license file: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _serverUrlController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }
    ref.read(serverUrlProvider.notifier).state = _serverUrlController.text.trim();
    ref.read(authProvider.notifier).login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        if (next.token != null && next.token!.isNotEmpty) {
          ref.read(authTokenProvider.notifier).state = next.token!;
        }
        context.go('/');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? 'Login failed'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Details', textColor: Colors.white, onPressed: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Error Details'),
                content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Server: ${_serverUrlController.text}'),
                  const SizedBox(height: 8),
                  Text('Error: ${next.error}'),
                ]),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
              ));
            }),
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.loginGradient,
            ),
          ),

          // ── Animated Particles ──
          ...List.generate(12, (i) => _AnimatedParticle(index: i, animController: _animController)),

          // ── Content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // ── Logo ──
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final offset = sin(_animController.value * pi) * 6;
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondaryColor.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo_hunter.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.water_drop,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── App Name ──
                    Text(
                      'ABQARINO',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                      ),
                    ),
                    Text(
                      'SCADA',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppTheme.secondaryColor.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.poweredBy,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Glassmorphism Login Card ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.login,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.loginToContinue,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Username ──
                              _GlassInput(
                                controller: _usernameController,
                                hint: l10n.username,
                                icon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),

                              // ── Password ──
                              _GlassInput(
                                controller: _passwordController,
                                hint: l10n.password,
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                  child: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 20,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ── Server Config Toggle ──
                              GestureDetector(
                                onTap: () => setState(() => _showServerConfig = !_showServerConfig),
                                child: Row(
                                  children: [
                                    Icon(Icons.dns_outlined, size: 16, color: Colors.white.withOpacity(0.5)),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.serverConfig,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Icon(
                                      _showServerConfig ? Icons.expand_less : Icons.expand_more,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),

                              if (_showServerConfig) ...[
                                const SizedBox(height: 14),
                                _GlassInput(
                                  controller: _serverUrlController,
                                  hint: 'http://10.10.8.60:49110',
                                  icon: Icons.dns_outlined,
                                ),
                              ],

                              const SizedBox(height: 20),

                              // ── Sign In Button ──
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: authState.status == AuthStatus.loading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                  ),
                                  child: authState.status == AuthStatus.loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                        )
                                      : Text(
                                          l10n.signIn,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── License ──
                    GestureDetector(
                      onTap: _uploadLicense,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _licenseStatus != null
                                ? AppTheme.successColor.withOpacity(0.4)
                                : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _licenseStatus != null ? Icons.verified_outlined : Icons.upload_file_outlined,
                              size: 16,
                              color: _licenseStatus != null ? AppTheme.successColor : Colors.white54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _licenseStatus != null ? _licenseStatus! : l10n.uploadLicense,
                              style: TextStyle(
                                fontSize: 12,
                                color: _licenseStatus != null ? AppTheme.successColor : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Version ──
                    Text(
                      '${l10n.version} ${AppConstants.version}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Glassmorphism Input Field
// ═══════════════════════════════════════════════════════════════════
class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  const _GlassInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6), size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Animated Background Particles
// ═══════════════════════════════════════════════════════════════════
class _AnimatedParticle extends StatelessWidget {
  final int index;
  final AnimationController animController;

  const _AnimatedParticle({required this.index, required this.animController});

  @override
  Widget build(BuildContext context) {
    final rng = Random(index);
    final size = MediaQuery.of(context).size;
    final dx = rng.nextDouble() * size.width;
    final baseY = rng.nextDouble() * size.height;
    final radius = rng.nextDouble() * 4 + 2;
    final speed = rng.nextDouble() * 0.6 + 0.2;

    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        final yOffset = sin((animController.value + rng.nextDouble()) * pi * speed) * 30;
        return Positioned(
          left: dx,
          top: baseY + yOffset,
          child: Opacity(
            opacity: 0.08 + rng.nextDouble() * 0.07,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: radius * 3,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
