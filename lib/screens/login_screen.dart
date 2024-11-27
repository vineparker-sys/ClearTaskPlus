import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart'; // Import para validação de email
import '../db/database_helper.dart';
import '../utils/current_user.dart';
import 'task_list_screen.dart';
import '../utils/notification_helper.dart'; // Importando NotificationHelper

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers para os campos de texto
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  /// Verifica se o usuário já está logado usando SharedPreferences
  Future<void> _checkLoggedIn() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final user = prefs.getStringList('User');

    setState(() {
      _rememberMe = isLoggedIn;
      _isLoading = false;
    });

    if (context.mounted && isLoggedIn && user != null) {
      CurrentUser.setUser(user[0], user[1]);
      Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
    }
  }

  /// Realiza o login do usuário
  Future<void> _login(Map<String, dynamic> user) async {
    CurrentUser.setUser(user['name'], user['email']);
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setStringList('User', [user['name'], user['email']]);
    }
    // Solicita permissão de notificação após o login
    await NotificationHelper.requestNotificationPermission();
    Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    // Obtém dimensões da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      // Tela de carregamento inicial
      return Scaffold(
        backgroundColor: const Color(0xFF24736E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF24736E),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.1),
              // Logo do aplicativo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: screenHeight * 0.3,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Título do aplicativo
              const Text(
                'ClearTask+',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF85DDBE),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Subtítulo do aplicativo
              const Text(
                'Organize seu dia, realize suas metas!\nTransforme tarefas em conquistas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              // Campo de texto para E-mail
              _buildTextField(
                context,
                controller: emailController,
                hintText: 'E-mail',
                isPassword: false,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Campo de texto para Senha
              _buildTextField(
                context,
                controller: passwordController,
                hintText: 'Senha',
                isPassword: true,
              ),
              Row(
                children: [
                  // Checkbox "Lembre-se de mim"
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() {
                      _rememberMe = value ?? false;
                    }),
                    activeColor: Colors.teal,
                  ),
                  const Text(
                    'Lembre-se de mim',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              // Botão de Login
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Color(0xFF24736E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Botões de Registro e Esqueci minha senha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão "Registre-se"
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Registre-se',
                      style: TextStyle(
                        color: Color(0xFF85DDBE),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Espaço entre os botões
                  SizedBox(width: screenWidth * 0.05),
                  // Botão "Esqueci minha senha"
                  TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: Color(0xFF85DDBE),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método para construir campos de texto reutilizáveis
  Widget _buildTextField(BuildContext context,
      {required TextEditingController controller,
      required String hintText,
      required bool isPassword}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF24736E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Ícone para mostrar/ocultar senha
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF24736E),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  /// Método para lidar com o botão de login
  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validação básica dos campos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
      return;
    }

    final dbHelper = DatabaseHelper.instance;
    final user = await dbHelper.getUserByEmailAndPassword(email, password);

    if (user != null) {
      // Usuário encontrado, realiza login
      _login(user);
    } else {
      // Credenciais inválidas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais inválidas!')),
      );
    }
  }

  /// Método para lidar com o botão "Esqueci minha senha"
  void _handleForgotPassword() {
    final email = emailController.text.trim();

    if (EmailValidator.validate(email)) {
      // Simular o envio de email de recuperação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Um link de recuperação foi enviado para $email.'),
        ),
      );
    } else {
      // Email inválido ou não preenchido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um email válido para recuperação.'),
        ),
      );
    }
  }
}
