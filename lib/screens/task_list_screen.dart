// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import '../utils/current_user.dart';
import 'list_screen.dart';

class TaskListScreen extends StatefulWidget {
  static const routeName = '/tasks';

  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  // Variável para rastrear qual ExpansionTile está aberto
  String? _expandedTile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carrega as tarefas do banco de dados
  Future<void> _loadData() async {
    await Provider.of<TaskProvider>(context, listen: false).getTasks();
    setState(() {
      _isLoading = false;
      _expandedTile = 'Hoje'; // Expande a tile "Hoje" por padrão
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = CurrentUser.name ?? "Usuário";
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Dimensões da tela para responsividade
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Avatar do usuário
            CircleAvatar(
              radius: screenWidth * 0.05,
              backgroundColor: theme.cardColor,
              child: Icon(
                Icons.person,
                size: screenWidth * 0.05,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            // Saudação ao usuário
            Text(
              'Olá, $userName!',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Botão de notificações
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              // Exibir notificações (simulação)
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    title: Text(
                      "Notificações",
                      style: theme.textTheme.titleLarge,
                    ),
                    content: Text(
                      "Nenhuma notificação pendente.",
                      style: theme.textTheme.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "OK",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final tasks = provider.tasks;

                // Filtrar tarefas de Hoje e Próximas
                final todayTasks = tasks.where((task) {
                  final taskDate = task.date?.toLocal();
                  return taskDate != null &&
                      taskDate.day == _selectedDate.day &&
                      taskDate.month == _selectedDate.month &&
                      taskDate.year == _selectedDate.year;
                }).toList();

                final upcomingTasks = tasks.where((task) {
                  final taskDate = task.date;
                  return taskDate != null && taskDate.isAfter(_selectedDate);
                }).toList();

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Carrossel de datas ajustado para retângulo com bordas arredondadas
                      Container(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: isDarkMode ? theme.cardColor : const Color(0xFFEEF7F5),
                          borderRadius: BorderRadius.circular(16), // Bordas arredondadas
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            7,
                            (index) {
                              final date = _selectedDate.add(Duration(days: index - 3));
                              final isSelected = date.day == _selectedDate.day &&
                                  date.month == _selectedDate.month &&
                                  date.year == _selectedDate.year;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.005,
                                      horizontal: screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                                  ),
                                  child: Column(
                                    children: [
                                      // Dia da semana
                                      Text(
                                        ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                                            [date.weekday % 7],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : theme.textTheme.bodyMedium?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      // Dia do mês
                                      Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : theme.textTheme.bodyMedium?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // ExpansionTile para "Hoje" com bordas arredondadas e cores dinâmicas
                      _buildCustomExpansionTile(
                        context: context,
                        theme: theme,
                        title: 'Hoje',
                        isExpanded: _expandedTile == 'Hoje',
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _expandedTile = expanded ? 'Hoje' : null;
                          });
                        },
                        leadingIcon: Icons.calendar_today,
                        expandedBackgroundColor: theme.primaryColor,
                        collapsedBackgroundColor: Colors.transparent,
                        titleColor: _expandedTile == 'Hoje' ? Colors.white : theme.primaryColor,
                        iconColor: _expandedTile == 'Hoje' ? Colors.white : theme.primaryColor,
                        tasks: todayTasks,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        provider: provider,
                      ),
                      // ExpansionTile para "Próximas" com bordas arredondadas e cores dinâmicas
                      _buildCustomExpansionTile(
                           context: context,
                            theme: theme,
                            title: 'Próximas',
                            isExpanded: _expandedTile == 'Próximas',
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _expandedTile = expanded ? 'Próximas' : null;
                              });
                            },
                            leadingIcon: Icons.arrow_forward,
                            expandedBackgroundColor: theme.primaryColor, // Define o fundo verde ao expandir
                            collapsedBackgroundColor: Colors.transparent,
                            titleColor: _expandedTile == 'Próximas' ? Colors.white : theme.primaryColor, // Texto branco ao expandir
                            iconColor: _expandedTile == 'Próximas' ? Colors.white : theme.primaryColor,
                            tasks: upcomingTasks,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            provider: provider,
                            showDate: true, // Mostrar data nas tarefas
                          ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AddEditTaskScreen.routeName,
            arguments: null, // Passando null para criar uma nova tarefa
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Nova Tarefa ou Compromisso',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.unselectedWidgetColor,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, ListScreen.routeName);
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, TaskListScreen.routeName);
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, SettingsScreen.routeName);
          }
        },
        currentIndex: 1, // Index atual para destacar o ícone correto (Home)
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

  /// Método para construir ExpansionTiles personalizados com bordas arredondadas e cores dinâmicas
  Widget _buildCustomExpansionTile({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required IconData leadingIcon,
    required Color expandedBackgroundColor,
    required Color collapsedBackgroundColor,
    required Color titleColor,
    required Color iconColor,
    required List<Task> tasks,
    required double screenWidth,
    required double screenHeight,
    required TaskProvider provider,
    bool showDate = false, // Indica se deve mostrar a data nas tarefas
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.005),
      child: Container(
        decoration: BoxDecoration(
          color: isExpanded ? expandedBackgroundColor : collapsedBackgroundColor,
          borderRadius: BorderRadius.circular(12), // Bordas arredondadas
          border: Border.all(
            color: isExpanded ? theme.primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>(title),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          leading: Icon(
            leadingIcon,
            color: iconColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: iconColor,
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: isExpanded ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: tasks.map((task) {
                  return ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        color: isExpanded ? Colors.white : theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: showDate && task.date != null
                        ? Text(
                            "${task.date!.day}/${task.date!.month}/${task.date!.year}",
                            style: TextStyle(
                              color: isExpanded ? Colors.white70 : theme.primaryColor.withOpacity(0.7),
                              fontSize: screenWidth * 0.035,
                            ),
                          )
                        : task.description != null && task.description!.isNotEmpty
                            ? Text(
                                task.description!,
                                style: TextStyle(
                                  color: isExpanded ? Colors.white70 : theme.primaryColor.withOpacity(0.7),
                                ),
                              )
                            : null,
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        provider.updateTask(
                          Task(
                            id: task.id,
                            title: task.title,
                            description: task.description,
                            date: task.date,
                            isCompleted: value ?? false,
                            isEvent: task.isEvent,
                            categories: task.categories,
                          ),
                        );
                      },
                      activeColor: theme.primaryColor,
                      checkColor: Colors.white,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AddEditTaskScreen.routeName,
                        arguments: task, // Passando o objeto Task como argumento
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
