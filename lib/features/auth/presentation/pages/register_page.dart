import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_event.dart';
import 'package:wallet_unsaac/features/auth/presentation/blocs/auth/auth_state.dart';
import 'package:wallet_unsaac/features/auth/presentation/utils/auth_validators.dart';
import 'package:wallet_unsaac/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:wallet_unsaac/features/auth/presentation/widgets/auth_scaffold.dart';

/// Pantalla de registro de una cuenta nueva.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: _email.text.trim(),
            password: _password.text,
          ),
        );
  }

  void _close() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated && previous is! AuthAuthenticated,
      listener: (context, state) => _close(),
      child: AuthScaffold(
        title: 'Crea tu cuenta',
        subtitle: 'Registra un correo y una contraseña para empezar.',
        footer: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '¿Ya tienes cuenta?',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            TextButton(
              key: const Key('register_back'),
              onPressed: _close,
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthFormField(
                fieldKey: const Key('register_email'),
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
                fieldKey: const Key('register_password'),
                controller: _password,
                label: 'Contraseña',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.password,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
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
              const SizedBox(height: 14),
              AuthFormField(
                fieldKey: const Key('register_confirm'),
                controller: _confirmation,
                label: 'Confirma la contraseña',
                icon: Icons.lock_reset_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) =>
                    AuthValidators.confirmPassword(value, _password.text),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) =>
                    (previous is AuthLoading) != (current is AuthLoading),
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return FilledButton(
                    key: const Key('register_submit'),
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
                        : const Text('Crear cuenta'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
