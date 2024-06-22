import 'package:flutter/material.dart';
import 'database.dart';
import 'package:uuid/uuid.dart';

// Définition du widget ListPage
class ListPage extends StatefulWidget {
  @override
  ListPageState createState() => ListPageState();
}

// Définition de la classe ListPageState, création d'une liste de tâches instanciée chacune avec un
// identifiant, un titre et une couleur
class ListPageState extends State<ListPage> {
  final List<TodoItem> allTodos = [
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.grey),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.green),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.red),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.red),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.grey),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.grey),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.grey),
    TodoItem(id: Uuid().v4(), title: 'Task 1', indicatorColor: Colors.blue),
  ];

  // Définition des variables
  late List<TodoItem> filteredTodos;
  final List<String> filters = ['Todo', 'In progress', 'Done', 'Bug'];
  List<String> selectedFilters = [];

  @override
  void initState() {
    super.initState();
    filteredTodos = allTodos;
  }

  // Création de la méthode _showFilterDialog qui permet de sélectionner les différents statuts des tâches.
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape:RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: Text('Filter par'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: filters.map((filter) {
                  return CheckboxListTile(
                    title: Text(filter),
                    value: selectedFilters.contains(filter),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedFilters.add(filter);
                        } else {
                          selectedFilters.remove(filter);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                Center( // Center widget added here
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Appliquer'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _applyFilters();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Cette méthode permet de filtrer les tâches en fonction du statut sélectionné
  void _applyFilters() {
    setState(() {
      if (selectedFilters.isEmpty) {
        filteredTodos = allTodos;
      } else {
        filteredTodos = allTodos.where((todo) {
          return selectedFilters.contains(getStatus(todo.indicatorColor));
        }).toList();
      }
    });
  }

  String getStatus(Color color) {
    switch (color) {
      case Colors.grey:
        return 'Todo';
      case Colors.green:
        return 'In progress';
      case Colors.red:
        return 'Bug';
      case Colors.blue:
        return 'Done';
      default:
        return 'Unknown';
    }
  }

  void filterTasks() {
    setState(() {
      filteredTodos = allTodos.where((todo) => todo.indicatorColor == Colors.grey).toList();
    });
  }

  // C'est la méthode qui permet de modifier une tâche sélectionnée
  void _editTask(TodoItem todo) async {
    final updatedTask = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          todo: todo,
        ),
      ),
    );

    if (updatedTask != null) {
      _updateTask(updatedTask);
    }
  }

  void _updateTask(TodoItem updatedTask) {
    setState(() {
      int index = allTodos.indexWhere((todo) => todo.id == updatedTask.id);
      if (index != -1) {
        allTodos[index] = updatedTask;
        _applyFilters();
      }
    });
  }

  // Cette méthode addTask permet d'ajouter une nouvelle tâche à la liste des tâches présentes
  void addTask(TodoItem newTask) {
    setState(() {
      allTodos.add(newTask);
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: filterTasks,
          child: Text('Todo App'),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _editTask(filteredTodos[index]),
            child: TodoTile(todo: filteredTodos[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NewTaskPage(addTask: addTask)),
          );
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}

// Définition de la classe TodoItem et du widget TodoTile
class TodoItem {
  final String id;
  final String title;
  final Color indicatorColor;

  TodoItem({required this.id, required this.title, required this.indicatorColor});
}

class TodoTile extends StatelessWidget {
  final TodoItem todo;

  TodoTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: todo.indicatorColor,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: todo.indicatorColor,
            radius: 10.0,
          ),
          title: Text(todo.title),
        ),
      ),
    );
  }
}

// Définition du widget NewTaskPage qui prend la fonction addTask en paramètre et permet d'ajouter une nouvelle tâche
class NewTaskPage extends StatefulWidget {
  final Function(TodoItem) addTask;

  NewTaskPage({required this.addTask});

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStatus;
  String title = '';
  String _taskDescription = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Ajouter',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Expanded(
                    child: StatusSelector(
                      onStatusSelected: (status) {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nouvelle tâche',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer une nouvelle tâche' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _taskDescription = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Color statusColor;
                      switch (_selectedStatus) {
                        case 'Todo':
                          statusColor = Colors.grey;
                          break;
                        case 'In progress':
                          statusColor = Colors.green;
                          break;
                        case 'Done':
                          statusColor = Colors.blue;
                          break;
                        case 'Bug':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      TodoItem newTask =
                          TodoItem(id: Uuid().v4(), title: title, indicatorColor: statusColor);
                      widget.addTask(newTask);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 80),
                  ),
                  child: Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget qui permet de modifier une tâche existante dans la liste des tâches
class EditTaskPage extends StatefulWidget {
  final TodoItem todo;

  EditTaskPage({required this.todo});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late Color color;

  @override
  void initState() {
    super.initState();
    title = widget.todo.title;
    color = widget.todo.indicatorColor;
  }

  void _updateStatus(String status) {
    setState(() {
      switch (status) {
        case 'Todo':
          color = Colors.grey;
          break;
        case 'In progress':
          color = Colors.green;
          break;
        case 'Done':
          color = Colors.blue;
          break;
        case 'Bug':
          color = Colors.red;
          break;
        default:
          color = Colors.grey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Modifier',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Expanded(
                    child: StatusSelector(
                      onStatusSelected: (status) {
                        _updateStatus(status);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(
                  labelText: '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Entrer une nouvelle tâche' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 5,
                initialValue:
                    'Lorem ipsum dolor sit amet consectetur. Nisi nunc accumsan nisl lorem laoreet tempus faucibus pretium.',
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // handle description change if needed
                },
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      TodoItem updatedTask =
                          TodoItem(id: widget.todo.id, title: title, indicatorColor: color);
                      Navigator.of(context).pop(updatedTask);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                  ),
                  child: Text('Modifier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget qui permet d'afficher le sélecteur de statut et qui va permettre
// de choisir le statut qu'on veut associé à la tâche
class StatusSelector extends StatefulWidget {
  final Function(String) onStatusSelected;

  StatusSelector({required this.onStatusSelected});

  @override
  _StatusSelectorState createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  String _selectedStatus = 'Status';
  final Map<String, Color> _statusColors = {
    'Todo': Colors.grey,
    'In progress': Colors.green,
    'Done': Colors.blue,
    'Bug': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showStatusDropdown(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _statusColors[_selectedStatus],
                  radius: 10,
                ),
                SizedBox(width: 8),
                Text(_selectedStatus),
                Spacer(),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showStatusDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: _statusColors.keys.map((status) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedStatus = status;
                });
                widget.onStatusSelected(status);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _statusColors[status],
                    radius: 10,
                  ),
                  SizedBox(width: 8),
                  Text(status),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
