import 'dart:math';
import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'repository/database_creator.dart';
import 'repository/repository_service_todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SqfLiteCrud(title: 'Flutter Demo Home Page'),
    );
  }
}

    class SqfLiteCrud extends StatefulWidget {
  SqfLiteCrud({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SqfLiteCrudState createState() => _SqfLiteCrudState();
}

class _SqfLiteCrudState extends State<SqfLiteCrud> {
  final _formKey = GlobalKey<FormState>();
  Future<List<Todo>> future;
  String name;
  int id;

  @override
  initState() {
    super.initState();
    future = RepositoryServiceTodo.getAllTodos();
  }

  void readData() async {
    final todo = await RepositoryServiceTodo.getTodo(id);
    print(todo.name);
  }

  updateTodo(Todo todo) async {
    todo.name = 'nama berhasil diubah';
    await RepositoryServiceTodo.updateTodo(todo);
    setState(() {
      future = RepositoryServiceTodo.getAllTodos();
    });
  }

  deleteTodo(Todo todo) async {
    await RepositoryServiceTodo.deleteTodo(todo);
    setState(() {
      id = null;
      future = RepositoryServiceTodo.getAllTodos();
    });
  }

  Card buildItem(Todo todo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Id          : ${todo.id}',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'nama       : ${todo.name}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'pekerjaan: ${todo.info}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateTodo(todo),
                  child: Icon(Icons.edit),
                  //color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  onPressed: () => deleteTodo(todo),
                  child: Icon(Icons.delete),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'masukan nama karyawan baru',
        fillColor: Colors.grey[300],
        filled: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'masukan nama karyawan';
        }
      },
      onSaved: (value) => name = value,
    );
  }


  void createTodo() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      int count = await RepositoryServiceTodo.todosCount();
      final todo = Todo(count, name, randomTodo(), false);
      await RepositoryServiceTodo.addTodo(todo);
      setState(() {
        id = todo.id;
        future = RepositoryServiceTodo.getAllTodos();
      });
      print(todo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data karyawan'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Form(
            key: _formKey,
            child: buildTextFormField(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: createTodo,
                child: Text('tambah data', style: TextStyle(color: Colors.white)),
                color: Colors.red,
              ),
              RaisedButton(
                onPressed: id != null ? readData : null,
                child: Text('tampilkan', style: TextStyle(color: Colors.red)),
                color: Colors.white,
              ),
            ],
          ),
          FutureBuilder<List<Todo>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: snapshot.data.map((todo) => buildItem(todo)).toList());
              } else {
                return SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  String randomTodo() {
    final randomNumber = Random().nextInt(4);
    String todo;
    switch (randomNumber) {
      case 1:
        todo = 'menulis';
        break;
      case 2:
        todo = 'membaca';
        break;
      case 3:
        todo = 'berbicara';
        break;
      default:
        todo = 'mendengarkan';
        break;
    }
    return todo;
  }
}
