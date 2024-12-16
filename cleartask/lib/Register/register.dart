import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _receivePromotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background image
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Registre-se',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Welcome text
            const Text(
              'Bem-Vindo',
              style: TextStyle(
                fontSize: 24,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle text
            const Text(
              'Crie uma conta e receba acesso antecipado aos nossos lançamentos.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // Email TextField
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.check, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 20),

            // Password TextField
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.visibility, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 20),

            // Receive Promotions Checkbox
            Row(
              children: [
                Checkbox(
                  value: _receivePromotions,
                  onChanged: (bool? value) {
                    setState(() {
                      _receivePromotions = value ?? false;
                    });
                  },
                  activeColor: Colors.teal,
                ),
                const Text(
                  'Receba e-mails de promoção e atualizações.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Terms and Privacy Text
            Text.rich(
              TextSpan(
                text: 'Criando a conta você estará concordando com nossos ',
                style: const TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: 'Termos de Uso',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle Terms of Use tap
                      },
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle Privacy Policy tap
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Registrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
