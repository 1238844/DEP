import 'package:flutter/material.dart';
import '../database.dart';
import 'task.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _loadTasks();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadTasks() async {
    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  void _navigateToTaskScreen([Map<String, dynamic>? task]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(task: task),
      ),
    );
    if (result == true) {
      setState(() {
        _showFab = false; // Hide FAB temporarily
      });
      _loadTasks(); // Refresh tasks
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          _showFab = true; // Show FAB after delay
        });
      });
    }
  }

  Future<void> _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'To-Do List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToTaskScreen(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return Dismissible(
              key: Key(task['id'].toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteTask(task['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${task['description'] ?? ''}\nDue: ${task['due_date'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _deleteTask(task['id']),
                    ),
                    onTap: () => _navigateToTaskScreen(task),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
        onPressed: () => _navigateToTaskScreen(),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      )
          : null,
    );
  }
}
