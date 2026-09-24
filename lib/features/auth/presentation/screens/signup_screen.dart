import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/core/animations/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/gradient_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).signUpWithEmail(
            email: _email.text,
            password: _password.text,
            displayName: _name.text.trim(),
          );
      await AnalyticsService.instance.logSignUp('password');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Sign-up failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSizes.huge),
                Text('Create account', style: context.text.displayMedium)
                    .fxEnter(context, step: 0),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Start tracking smarter today',
                  style: context.text.bodyLarge?.copyWith(
                    color: context.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ).fxEnter(context, step: 2),
                const SizedBox(height: AppSizes.huge),
                CustomTextField(
                  hint: 'Full name',
                  controller: _name,
                  icon: Icons.person_outline_rounded,
                ).fxEnter(context, step: 3),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  hint: 'Email',
                  controller: _email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ).fxEnter(context, step: 4),
                const SizedBox(height: AppSizes.md),
                CustomTextField(
                  hint: 'Password (min. 6 chars)',
                  controller: _password,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                ).fxEnter(context, step: 5),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    _error!,
                    style: context.text.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.xl),
                GradientButton(
                  label: 'Create account',
                  loading: _loading,
                  onPressed: _loading ? null : _signUp,
                ).fxEnter(context, step: 6),
                const SizedBox(height: AppSizes.huge),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: <Widget>[
                    Text('Already have one?', style: context.text.bodyMedium),
                    TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
