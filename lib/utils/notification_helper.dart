// lib/utils/notification_helper.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  // Instância do plugin de notificações locais
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  /// Inicializa o NotificationHelper com a instância do FlutterLocalNotificationsPlugin
  static void initialize(FlutterLocalNotificationsPlugin notificationsPlugin) {
    _notificationsPlugin = notificationsPlugin;
  }

  /// Solicita permissão de notificação ao usuário
  static Future<void> requestNotificationPermission() async {
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
      } else {
        print('Permissão de notificações concedida');
      }
    }
  }

  /// Agendar notificações múltiplas para uma tarefa
  static Future<void> scheduleTaskNotifications(Task task) async {
    if (_notificationsPlugin == null) {
      print('Erro: NotificationHelper não foi inicializado.');
      return;
    }

    if (task.date == null || task.title == false) {
      print('Erro: A tarefa não possui data ou título válido.');
      return;
    }

    final tzDateTime = tz.TZDateTime.from(task.date!, tz.local);

    // Horários de notificação: 30, 15 e 10 minutos antes
    final List<Duration> reminders = [
      const Duration(minutes: 30),
      const Duration(minutes: 15),
      const Duration(minutes: 10),
    ];

    for (var reminder in reminders) {
      final notificationTime = tzDateTime.subtract(reminder);

      // Se o horário da notificação já passou, agendar imediatamente
      if (notificationTime.isBefore(DateTime.now())) {
        await _scheduleNotification(
          id: task.id! * 10 + reminder.inMinutes,
          title: 'Lembrete de Tarefa',
          body:
              'Tarefa "${task.title}" está agendada para ${_formatTime(task.date!)}.',
          scheduledTime: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        );
      } else {
        await _scheduleNotification(
          id: task.id! * 10 + reminder.inMinutes,
          title: 'Lembrete de Tarefa',
          body:
              'Tarefa "${task.title}" está agendada para ${_formatTime(task.date!)}.',
          scheduledTime: notificationTime,
        );
      }
    }
  }

  /// Agendar notificação imediata ao criar a tarefa
  static Future<void> scheduleImmediateNotification(Task task) async {
    if (_notificationsPlugin == null) {
      print('Erro: NotificationHelper não foi inicializado.');
      return;
    }

    await _scheduleNotification(
      id: task.id!,
      title: 'Tarefa Criada',
      body:
          'Sua tarefa "${task.title}" foi criada para o dia ${task.date!.day}/${task.date!.month} às ${_formatTime(task.date!)}.',
      scheduledTime: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
    );
  }

  /// Formatar a hora para exibição
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Agendar uma notificação genérica
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_notifications', // ID do canal
      'Task Notifications', // Nome do canal
      channelDescription: 'Notificações para lembrar de tarefas', // Descrição
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Ícone da notificação
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin!.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notificação agendada: $title para $scheduledTime');
    } catch (e) {
      print('Erro ao agendar notificação: $e');
    }
  }

  /// Cancela todas as notificações relacionadas a uma tarefa
  static Future<void> cancelTaskNotifications(int taskId) async {
    if (_notificationsPlugin == null) {
      print('Erro: NotificationHelper não foi inicializado.');
      return;
    }

    final List<int> notificationIds = [
      taskId,
      taskId * 10 + 30,
      taskId * 10 + 15,
      taskId * 10 + 10
    ];

    for (var id in notificationIds) {
      try {
        await _notificationsPlugin!.cancel(id);
        print('Notificação cancelada para ID: $id');
      } catch (e) {
        print('Erro ao cancelar notificação: $e');
      }
    }
  }
}
