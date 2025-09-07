import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/screens/search_view.dart';
import '../cubit/todo_cubit.dart';
import '../cubit/todo_state.dart';
import '../models/todo.dart';
import '../models/user.dart';
import 'login_view.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key, required this.user});
  final User user;
  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TextEditingController _controller = TextEditingController();

  void _addTodo(BuildContext context) {
    context.read<TodoCubit>().addTodo(title: _controller.text,email: widget.user.email);
    _controller.clear();
  }
  @override
  void initState() {
    context.read<TodoCubit>().loadTodos(email: widget.user.email);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            return Text(
              "${widget.user.name}'s todos (${state.todos.length})",
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchView(user: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.orangeAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(),
                      hintText: "Enter a todo...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTodo(context),
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<TodoCubit, TodoState>(
              listener: (context, state) {
                if (state.status == TodoStatus.error && state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error!,style: TextStyle(color: Colors.white)),duration: Duration(seconds: 2),), // Text(state.error,)),
                  );
                }
              },
              builder: (context, state) {
                if (state.todos.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Todos yet!",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) {
                          context.read<TodoCubit>().toggleTodo(id: todo.id,email: widget.user.email);
                        },
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<TodoCubit>().deleteTodo(id: todo.id,email: widget.user.email);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
