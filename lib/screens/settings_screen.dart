import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/current_user.dart';
import 'task_list_screen.dart';
import 'list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Usuário';
  String userEmail = 'E-mail não disponível';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carrega os dados do usuário logado
  void _loadUserData() {
    setState(() {
      userName = CurrentUser.name ?? 'Usuário';
      userEmail = CurrentUser.email ?? 'E-mail não disponível';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Dimensões da tela para responsividade
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Definir cores com base no tema atual
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Configurações',
          style: theme.appBarTheme.titleTextStyle,
        ),
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com avatar genérico
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.15,
                    backgroundColor: theme.cardColor,
                    child: Icon(
                      Icons.person,
                      size: screenWidth * 0.15,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Opções de configuração
            _buildSectionTitle('GERAL', textColor, screenWidth),
            _buildListTile(
              context,
              title: 'Minha conta',
              icon: Icons.person,
              textColor: textColor,
              onTap: () {
                // Ação para "Minha conta" (essa fica pra depois big mountain :v)
              },
              screenWidth: screenWidth,
            ),
            _buildListTile(
              context,
              title: 'Editar preferências',
              icon: Icons.edit,
              textColor: textColor,
              onTap: () {
                // Ação para "Editar preferências" (HOJE NÃO KKKKK!)
              },
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenHeight * 0.03),
            _buildSectionTitle('TEMA E NOTIFICAÇÕES', textColor, screenWidth),
            _buildSwitchTile(
              title: 'Notificações',
              value: themeProvider.notificationsEnabled,
              onChanged: (value) {
                themeProvider.toggleNotifications(value);
              },
              textColor: textColor,
              screenWidth: screenWidth,
            ),
            _buildSwitchTile(
              title: 'Modo escuro',
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleDarkMode(value);
              },
              textColor: textColor,
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenHeight * 0.03),
            _buildSectionTitle('SOBRE A APLICAÇÃO', textColor, screenWidth),
            _buildListTile(
              context,
              title: 'Política de Privacidade',
              icon: Icons.privacy_tip,
              textColor: textColor,
              onTap: () {
                // Ação para "Política de Privacidade" (NOT TODAY MY FRIEND)
              },
              screenWidth: screenWidth,
            ),
            _buildListTile(
              context,
              title: 'Termos de uso',
              icon: Icons.description,
              textColor: textColor,
              onTap: () {
                // Ação para "Termos de uso" (ngm lê isso, nem precisa)
              },
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenHeight * 0.04),
            Center(
              child: TextButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                  CurrentUser.clearUser();

                  if (mounted) {
                    Navigator.pushReplacementNamed(
                        context, LoginScreen.routeName);
                  }
                },
                child: Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: secondaryTextColor,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, ListScreen.routeName);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
          }
        },
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color textColor,
    required double screenWidth,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor, size: screenWidth * 0.07),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: screenWidth * 0.045),
      ),
      trailing: Icon(Icons.chevron_right, color: textColor),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required double screenWidth,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: screenWidth * 0.045),
      ),
      activeColor: Theme.of(context).primaryColor,
      value: value,
      onChanged: onChanged,
    );
  }
}
