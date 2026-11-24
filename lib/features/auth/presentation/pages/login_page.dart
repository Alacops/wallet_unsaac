import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/demo_credentials.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:wallet_unsaac/features/auth/presentation/pages/register_page.dart';
import 'package:wallet_unsaac/features/auth/presentation/utils/auth_validators.dart';
import 'package:wallet_unsaac/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:wallet_unsaac/features/auth/presentation/widgets/auth_scaffold.dart';

/// Pantalla de inicio de sesión.
///
/// La validación del formulario es local; la autenticación se delega al
/// [AuthBloc]. La pantalla no conoce Firebase ni el repositorio.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.showDemoHint});

  /// Muestra las credenciales de demostración cuando Firebase no está listo.
  final bool showDemoHint;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthLoginRequested(email: _email.text.trim(), password: _password.text),
        );
  }

  Future<void> _openRegister() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthScaffold(
      title: 'Inicia sesión',
      subtitle: 'Accede a tu billetera para continuar.',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '¿No tienes cuenta?',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          TextButton(
            key: const Key('login_register'),
            onPressed: _openRegister,
            child: const Text('Crear cuenta'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthFormField(
              fieldKey: const Key('login_email'),
              controller: _email,
              label: 'Correo electrónico',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 14),
            AuthFormField(
              fieldKey: const Key('login_password'),
              controller: _password,
              label: 'Contraseña',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: AuthValidators.password,
              onFieldSubmitted: (_) => _submit(),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            if (widget.showDemoHint) ...[
              const SizedBox(height: 16),
              _DemoHint(scheme: scheme),
            ],
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) =>
                  (previous is AuthLoading) != (current is AuthLoading),
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return FilledButton(
                  key: const Key('login_submit'),
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : const Text('Entrar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modo local',
            style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary),
          ),
          const SizedBox(height: 4),
          Text('${DemoCredentials.email} · ${DemoCredentials.password}'),
          const SizedBox(height: 4),
          Text(
            'Configura Firebase para usar autenticación real.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
