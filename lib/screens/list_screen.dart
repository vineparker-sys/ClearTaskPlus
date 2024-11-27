import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import '../utils/current_user.dart';
import 'task_list_screen.dart';
class ListScreen extends StatefulWidget {
  static const routeName = '/list';

  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  bool _isLoading = true;

  // Variáveis para rastrear qual ExpansionTile está aberto dentro de cada categoria
  String? _expandedPendentesTile;
  String? _expandedConcluidosTile;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dimensões da tela para responsividade
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final userName = CurrentUser.name ?? "Usuário";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
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

                // Separar tarefas em Concluídas e Pendentes
                final completedTasks = tasks.where((task) => task.isCompleted).toList();
                final pendingTasks = tasks.where((task) => !task.isCompleted).toList();

                // Ordenar tarefas por data
                pendingTasks.sort((a, b) => a.date?.compareTo(b.date ?? DateTime.now()) ?? 0);
                completedTasks.sort((a, b) => a.date?.compareTo(b.date ?? DateTime.now()) ?? 0);

                // Agrupar tarefas por data
                final Map<String, List<Task>> pendingGroupedByDate = {};
                for (var task in pendingTasks) {
                  final dateKey = "${task.date!.day}/${task.date!.month}/${task.date!.year}";
                  if (!pendingGroupedByDate.containsKey(dateKey)) {
                    pendingGroupedByDate[dateKey] = [];
                  }
                  pendingGroupedByDate[dateKey]!.add(task);
                }

                final Map<String, List<Task>> completedGroupedByDate = {};
                for (var task in completedTasks) {
                  final dateKey = "${task.date!.day}/${task.date!.month}/${task.date!.year}";
                  if (!completedGroupedByDate.containsKey(dateKey)) {
                    completedGroupedByDate[dateKey] = [];
                  }
                  completedGroupedByDate[dateKey]!.add(task);
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção de Pendentes
                      if (pendingGroupedByDate.isNotEmpty)
                        _buildTaskCategorySection(
                          title: "Pendentes",
                          groupedTasks: pendingGroupedByDate,
                          isCompleted: false,
                          expandedTile: _expandedPendentesTile,
                          onExpansionChanged: (key, expanded) {
                            setState(() {
                              if (expanded) {
                                _expandedPendentesTile = key;
                              } else if (_expandedPendentesTile == key) {
                                _expandedPendentesTile = null;
                              }
                            });
                          },
                          provider: provider,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                      // Seção de Concluídas
                      if (completedGroupedByDate.isNotEmpty)
                        _buildTaskCategorySection(
                          title: "Concluídas",
                          groupedTasks: completedGroupedByDate,
                          isCompleted: true,
                          expandedTile: _expandedConcluidosTile,
                          onExpansionChanged: (key, expanded) {
                            setState(() {
                              if (expanded) {
                                _expandedConcluidosTile = key;
                              } else if (_expandedConcluidosTile == key) {
                                _expandedConcluidosTile = null;
                              }
                            });
                          },
                          provider: provider,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                      // Caso não haja tarefas
                      if (pendingGroupedByDate.isEmpty && completedGroupedByDate.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.3),
                          child: Center(
                            child: Text(
                              'Nenhuma tarefa encontrada.',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
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
        backgroundColor: theme.primaryColor,
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
        currentIndex: 0, // Index atual para destacar o ícone correto (List)
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

  /// Método para construir seções de categorias com ExpansionTile
  Widget _buildTaskCategorySection({
    required String title,
    required Map<String, List<Task>> groupedTasks,
    required bool isCompleted,
    required String? expandedTile,
    required Function(String, bool) onExpansionChanged,
    required TaskProvider provider,
    required double screenHeight,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da categoria
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Lista de ExpansionTiles por data
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          itemCount: groupedTasks.keys.length,
          itemBuilder: (context, index) {
            final dateKey = groupedTasks.keys.elementAt(index);
            final tasks = groupedTasks[dateKey]!;

            return _buildCustomExpansionTile(
              title: dateKey,
              isExpanded: (isCompleted ? _expandedConcluidosTile : _expandedPendentesTile) == dateKey,
              onExpansionChanged: (expanded) {
                onExpansionChanged(dateKey, expanded);
              },
              leadingIcon: Icons.calendar_today,
              expandedBackgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              titleColor: theme.primaryColor,
              iconColor: theme.primaryColor,
              tasks: tasks,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              provider: provider,
              showDate: false, // Não mostrar a data nas tarefas
            );
          },
        ),
      ],
    );
  }

  /// Método para construir ExpansionTiles personalizados com bordas arredondadas e cores dinâmicas
  Widget _buildCustomExpansionTile({
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
    final theme = Theme.of(context);

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
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: showDate && task.date != null
                        ? Text(
                            "${task.date!.day}/${task.date!.month}/${task.date!.year}",
                            style: TextStyle(
                              color: theme.primaryColor.withOpacity(0.7),
                              fontSize: screenWidth * 0.035,
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
