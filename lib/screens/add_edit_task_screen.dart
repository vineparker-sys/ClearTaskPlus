// lib/screens/add_edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/notification_helper.dart';

class AddEditTaskScreen extends StatefulWidget {
  static const routeName = '/add_edit_task';

  const AddEditTaskScreen({Key? key}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _selectedDate;
  bool _isEvent = false;
  List<String> _selectedCategories = [];

  Task? _editedTask;

  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Task && _editedTask == null) {
      _editedTask = args;
      _title = _editedTask!.title;
      _description = _editedTask!.description;
      _selectedDate = _editedTask!.date;
      _isEvent = _editedTask!.isEvent;
      _selectedCategories = _editedTask!.categories != null && _editedTask!.categories!.isNotEmpty
          ? _editedTask!.categories!.split(',').map((e) => e.trim()).toList()
          : [];
    } else if (_editedTask == null) {
      _title = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          _editedTask == null ? 'Nova Tarefa' : 'Editar Tarefa',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_editedTask != null)
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir Tarefa'),
                    content: const Text('Tem certeza de que deseja excluir esta tarefa?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                  await taskProvider.deleteTask(_editedTask!.id!);
                  if (!mounted) return;
                  Navigator.pop(context); // Volta para a lista de tarefas
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    _buildTextField(
                      context: context,
                      labelText: 'Título',
                      hintText: 'Digite o título da tarefa',
                      icon: Icons.title,
                      initialValue: _editedTask?.title ?? '',
                      onSaved: (value) => _title = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um título.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Descrição
                    _buildTextField(
                      context: context,
                      labelText: 'Descrição',
                      hintText: 'Adicione uma breve descrição',
                      icon: Icons.description,
                      initialValue: _editedTask?.description,
                      onSaved: (value) => _description = value,
                      isMultiline: true,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Data e Hora
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.primaryColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Selecione a data e hora'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} às ${_selectedDate!.hour}:${_selectedDate!.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Icon(Icons.calendar_today, color: theme.primaryColor),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Categorias
                    _buildSectionTitle('Categorias', theme),
                    Wrap(
                      spacing: 8,
                      children: ['Trabalho', 'Pessoal', 'Outros'].map((category) {
                        final isSelected = _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                          backgroundColor: theme.cardColor,
                          selectedColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Evento
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Marcar como evento?',
                          style: theme.textTheme.bodyLarge,
                        ),
                        Switch(
                          value: _isEvent,
                          onChanged: (value) {
                            setState(() {
                              _isEvent = value;
                            });
                          },
                          activeColor: theme.primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(
                          context: context,
                          text: 'Voltar',
                          color: theme.colorScheme.secondary, // Usando cor secundária verde claro
                          onPressed: () => Navigator.pop(context),
                        ),
                        _buildActionButton(
                          context: context,
                          text: _editedTask == null ? 'Criar' : 'Salvar',
                          color: theme.primaryColor,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              if (_selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Por favor, selecione uma data.'),
                                  ),
                                );
                                return;
                              }

                              final categoriesString = _selectedCategories.join(',');

                              final newTask = Task(
                                id: _editedTask?.id,
                                title: _title,
                                description: _description,
                                date: _selectedDate,
                                isCompleted: _editedTask?.isCompleted ?? false,
                                isEvent: _isEvent,
                                categories: categoriesString.isNotEmpty ? categoriesString : null,
                              );

                              setState(() {
                                _isLoading = true;
                              });

                              if (_editedTask == null) {
                                // Adicionando uma nova tarefa
                                int newTaskId = await taskProvider.addTask(newTask.copyWith(id: null));

                                // Agendar notificações com o novo ID
                                await NotificationHelper.scheduleTaskNotifications(newTask.copyWith(id: newTaskId));
                              } else {
                                // Atualizando uma tarefa existente
                                await taskProvider.updateTask(newTask);
                              }

                              if (!mounted) return;

                              setState(() {
                                _isLoading = false;
                              });

                              Navigator.pop(context);
                            }
                          },
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
  Widget _buildTextField({
    required BuildContext context,
    required String labelText,
    required String hintText,
    required IconData icon,
    required Function(String?) onSaved,
    String? initialValue,
    String? Function(String?)? validator,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initialValue,
      maxLines: isMultiline ? 5 : 1,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: theme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  /// Método para construir títulos de seções
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Método para construir botões de ação
  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// Método para selecionar a data e hora da tarefa
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }
}
