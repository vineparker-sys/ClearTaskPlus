import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_edit_task_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/list_screen.dart'; // Importando a nova tela
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'db/database_helper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'utils/notification_helper.dart'; // Importando NotificationHelper

// Instância global para notificações locais
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Solicita permissão para notificações no Android 13+ usando permission_handler
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    // Solicita permissão
    PermissionStatus status = await Permission.notification.request();
    if (status.isDenied) {
      // Permissão não concedida
      print('Permissão de notificações não concedida');
    } else if (status.isPermanentlyDenied) {
      // O usuário negou permanentemente a permissão
      print('Permissão de notificações permanentemente negada');
      // Pode-se direcionar o usuário para as configurações do aplicativo
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização das TimeZones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  // Configuração de notificações locais para Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse response) async {
      // Callback ao interagir com a notificação
      print('Notificação selecionada com payload: ${response.payload}');
    },
  );

  // Inicializa o NotificationHelper com a instância do plugin
  NotificationHelper.initialize(flutterLocalNotificationsPlugin);

  // Solicitar permissões de notificação (Android 13+)
  await requestNotificationPermission();

  // Execução do aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Configuração do TaskProvider com notificações e banco de dados
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(
            dbHelper: DatabaseHelper.instance,
            localNotificationsPlugin: flutterLocalNotificationsPlugin,
          ),
        ),
        // Configuração do ThemeProvider para gerenciar temas claro e escuro
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Clear Task',
            theme: themeProvider.lightTheme, // Acessa o tema claro
            darkTheme: themeProvider.darkTheme, // Acessa o tema escuro
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Modo de tema
            initialRoute: LoginScreen.routeName, // Tela inicial
            routes: {
              LoginScreen.routeName: (context) => const LoginScreen(),
              RegisterScreen.routeName: (context) => const RegisterScreen(),
              TaskListScreen.routeName: (context) => const TaskListScreen(),
              AddEditTaskScreen.routeName: (context) =>
                  const AddEditTaskScreen(),
              SettingsScreen.routeName: (context) =>
                  const SettingsScreen(),
              ListScreen.routeName: (context) => const ListScreen(), // Adicionando a nova rota
            },
          );
        },
      ),
    );
  }
}
