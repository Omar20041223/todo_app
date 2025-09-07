import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(TodoState.initial);

  Future<void> addTodo({required String title,required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    if (title.trim().isEmpty) {
      emit(state.copyWith(
        error: 'You can not add empty Todo!',
        status: TodoStatus.error,
      ));
      return;
    }

    final newTodo = Todo(
      id: id,
      title: title.trim(),
      isCompleted: false,
    );

    final currentTodos = await _getCurrentTodos(email: email);
    final updatedTodos = [...currentTodos, newTodo];

    // save to prefs
    final stringList =
    updatedTodos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(email, stringList);

    emit(state.success(updatedTodos));
  }

  Future<void> deleteTodo({required String id,required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTodos = await _getCurrentTodos(email: email);

    final updatedTodos =
    currentTodos.where((todo) => todo.id != id).toList();

    // save updated list
    final stringList =
    updatedTodos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(email, stringList);

    emit(state.success(updatedTodos));
  }

  Future<void> toggleTodo({required String id,required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTodos = await _getCurrentTodos(email: email);
    final updatedTodos = currentTodos.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
    final stringList =
    updatedTodos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(email, stringList);

    emit(state.success(updatedTodos));
  }


  /// load all todos from shared prefs when app starts
  Future<void> loadTodos({required String email}) async {
    emit(state.loading());
    final currentTodos = await _getCurrentTodos(email: email);
    emit(state.success(currentTodos));
  }

  /// helper to get todos from SharedPreferences
  Future<List<Todo>> _getCurrentTodos({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(email) ?? [];

    return stringList.map((e) {
      final map = jsonDecode(e);
      return Todo.fromJson(map);
    }).toList();
  }
}
