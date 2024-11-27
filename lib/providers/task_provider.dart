// lib/providers/task_provider.dart

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/database_helper.dart';
import '../utils/notification_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseHelper dbHelper;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider({
    required this.dbHelper,
    required this.localNotificationsPlugin,
  });

  /// Obtém todas as tarefas do banco de dados
  Future<void> getTasks() async {
    _tasks = await dbHelper.getAllTasks();
    notifyListeners();
  }

  /// Adiciona uma nova tarefa ao banco de dados e agenda notificações
  Future<int> addTask(Task task) async {
    int taskId = await dbHelper.insertTask(task);
    Task newTask = task.copyWith(id: taskId);
    _tasks.add(newTask);
    notifyListeners();

    // Agendar notificações para a nova tarefa
    await NotificationHelper.scheduleTaskNotifications(newTask);
    await NotificationHelper.scheduleImmediateNotification(newTask);

    return taskId;
  }

  /// Atualiza uma tarefa existente e reconfigura notificações
  Future<void> updateTask(Task task) async {
    await dbHelper.updateTask(task);

    // Cancelar notificações existentes
    await NotificationHelper.cancelTaskNotifications(task.id!);

    // Agendar novas notificações
    await NotificationHelper.scheduleTaskNotifications(task);
    await NotificationHelper.scheduleImmediateNotification(task);

    await getTasks();
  }

  /// Deleta uma tarefa pelo ID e cancela suas notificações
  Future<void> deleteTask(int id) async {
    await dbHelper.deleteTask(id);

    // Cancelar notificações associadas
    await NotificationHelper.cancelTaskNotifications(id);

    await getTasks();
  }

  /// Filtra tarefas concluídas
  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  /// Filtra tarefas pendentes
  List<Task> getPendingTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
  }
}
