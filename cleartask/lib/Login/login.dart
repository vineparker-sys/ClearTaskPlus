import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleartask/TaskDashboardScreen/taskDashboardScreen.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearTask',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if(context.mounted){
      if (isLoggedIn) {
        Navigator.push(
        context,
         MaterialPageRoute(builder: (context) => const TaskDashboardScreen()),
        );
    } else {
      // Show login screen if user is not remembered
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
    }    
  }

  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      // Set a flag to remember the user
      await prefs.setBool('isLoggedIn', true);
    }
    // Navigate to main screen after login
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TaskDashboardScreen()),
    );
  }

//APP
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004D40), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const CircleAvatar(
                radius: 100,
                backgroundColor: Colors.transparent,
                child: ImageIcon(
                  AssetImage("assets/logo.png"), // Icone substituto
                  size: 800
                ),
              ),
              const SizedBox(height: 16.0),

              // Texto Principal
              const Text(
                'Organize seu dia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Transforme sua rotina em produtividade',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32.0),

              // Campo de Email
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Campo de Senha
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Checkbox "Lembre-se de mim"
              Row(children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: Colors.teal,
                ),
                const Text(
                  'Lembre-se de mim',
                  style: TextStyle(color: Colors.white),
                ),
              ],
              ),
              const SizedBox(height: 16.0),

              // Botão Login
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 8.0),

              // Botão Continuar com Google
              ElevatedButton.icon(
                onPressed: 
                  // Lógica para login com Google
                 _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                icon: const Icon(Icons.login, color: Color(0xFF004D40)),
                label: const Text(
                  'Continuar com Google',
                  style: TextStyle(color: Color(0xFF004D40)),
                ),
              ),
              const SizedBox(height: 16.0),

              // Esqueceu a senha e Registro
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Lógica para esquecer senha
                    },
                    child: const Text(
                      'Esqueceu a senha',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'register');
                    },
                    child: const Text(
                      'Registre-se',
                      style: TextStyle(color: Colors.white),
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
  
}
