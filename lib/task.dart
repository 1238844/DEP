import 'package:flutter/material.dart';
import '../database.dart';

class TaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  TaskScreen({this.task});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!['title'];
      _descriptionController.text = widget.task!['description'] ?? '';
      _dueDateController.text = widget.task!['due_date'] ?? '';
      _categoryController.text = widget.task!['category'] ?? '';
    }
  }

  void _saveTask() async {
    final task = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'due_date': _dueDateController.text,
      'category': _categoryController.text,
    };

    if (widget.task != null) {
      task['id'] = widget.task!['id'];
      await _dbHelper.updateTask(task);
    } else {
      await _dbHelper.insertTask(task);
    }

    Navigator.pop(context, true); // Pass true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'New Task'),
        backgroundColor: Colors.green, // Change the AppBar color
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(_titleController, 'Title', Icons.title),
            _buildTextField(_descriptionController, 'Description', Icons.description),
            GestureDetector(
              onTap: _selectDueDate,
              child: AbsorbPointer(
                child: _buildTextField(_dueDateController, 'Due Date', Icons.calendar_today),
              ),
            ),
            _buildTextField(_categoryController, 'Category', Icons.category),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.task != null ? 'Update Task' : 'Add Task',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          labelStyle: TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format the date
      });
    }
  }
}
