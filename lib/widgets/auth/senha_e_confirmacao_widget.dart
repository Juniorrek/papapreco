import 'package:flutter/material.dart';

class SenhaEConfirmacaoWidget extends StatefulWidget {
  final ValueChanged<String> onPasswordChanged;
  final String labelSenha;

  const SenhaEConfirmacaoWidget({
    super.key,
    required this.onPasswordChanged, required this.labelSenha,
  });

  @override
  State<SenhaEConfirmacaoWidget> createState() =>
      _SenhaEConfirmacaoWidgetState();
}

class _SenhaEConfirmacaoWidgetState extends State<SenhaEConfirmacaoWidget> {
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmacaoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _senhaController.addListener(() {
      widget.onPasswordChanged(_senhaController.text);
    });
  }

  double _passwordStrength = 0.0;
  String _passwordFeedback = '';

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(password);
      _passwordFeedback = _getPasswordFeedback(password);
    });
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0.0;
    if (password.isNotEmpty) strength += 0.1;
    if (password.length >= 8) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.2;

    return strength;
  }

  String _getPasswordFeedback(String password) {
    if (password.isEmpty) return 'A senha é obrigatória';
    if (password.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Adicione uma letra maiúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Adicione um número';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      return 'Adicione um caractere especial';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _senhaController,
          decoration: InputDecoration(
            labelText: widget.labelSenha,
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: _updatePasswordStrength,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Senha é obrigatória';
            }
            if (_passwordStrength < 0.8) {
              return 'Senha fraca';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _passwordStrength,
          color: _passwordStrength < 0.4
              ? Colors.red
              : _passwordStrength < 0.6
                  ? Colors.orange
                  : _passwordStrength < 0.8
                      ? Colors.yellow
                      : Colors.green,
          backgroundColor: Colors.grey[300],
        ),
        _passwordStrength == 0.0 || _passwordStrength >= 0.8
            ? const SizedBox.shrink()
            : Text(
                _passwordFeedback,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmacaoController,
          decoration: const InputDecoration(
            labelText: 'Confirmação de Senha',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirmação de senha é obrigatória';
            }
            if (value != _senhaController.text) {
              return 'Senhas não coincidem';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }
}
