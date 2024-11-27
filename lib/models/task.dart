// lib/models/task.dart

class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime? date;
  final bool isCompleted;
  final bool isEvent;
  final String? categories;

  Task({
    this.id,
    required this.title,
    this.description,
    this.date,
    this.isCompleted = false,
    this.isEvent = false,
    this.categories,
  });

  /// Converte o objeto Task para um Map para inserção no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isEvent': isEvent ? 1 : 0,
      'categories': categories,
    };
  }

  /// Cria um objeto Task a partir de um Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      isCompleted: map['isCompleted'] == 1,
      isEvent: map['isEvent'] == 1,
      categories: map['categories'] as String?,
    );
  }

  /// Cria uma cópia do objeto Task com novos valores
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
    bool? isEvent,
    String? categories,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      isEvent: isEvent ?? this.isEvent,
      categories: categories ?? this.categories,
    );
  }
}
