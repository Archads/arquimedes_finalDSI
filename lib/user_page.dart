import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/user.dart';
import 'main.dart';
import 'package:intl/intl.dart';

// user_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/user.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  final String? userId;
  final String? userName;
  final int? userAge;
  final DateTime? userBirthday;

  UserPage({
    this.userId,
    this.userName,
    this.userAge,
    this.userBirthday,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDate = TextEditingController();

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      );

  @override
  void initState() {
    super.initState();

    if (widget.userName != null) {
      controllerName.text = widget.userName!;
    }
    if (widget.userAge != null) {
      controllerAge.text = widget.userAge!.toString();
    }
    if (widget.userBirthday != null) {
      controllerDate.text =
          DateFormat('yyyy-MM-dd').format(widget.userBirthday!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId != null ? 'Edit User' : 'Create User'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: controllerName,
            decoration: decoration('Name'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controllerAge,
            decoration: decoration('Age'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controllerDate,
            decoration: decoration('Birthday'),
            readOnly: true,
            onTap: () {
              _selectDate(context);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: Text(widget.userId != null ? 'Update' : 'Create'),
            onPressed: () {
              if (widget.userId != null) {
                final updatedUser = User(
                  id: widget.userId!,
                  name: controllerName.text,
                  age: int.tryParse(controllerAge.text) ?? 0,
                  birthday:
                      DateTime.tryParse(controllerDate.text) ?? DateTime.now(),
                );
                updateUser(updatedUser);
              } else {
                final newUser = User(
                  name: controllerName.text,
                  age: int.tryParse(controllerAge.text) ?? 0,
                  birthday:
                      DateTime.tryParse(controllerDate.text) ?? DateTime.now(),
                );
                createUser(newUser);
              }
            },
          ),
        ],
      ),
    );
  }

  Future updateUser(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('consultas').doc(user.id);

    final json = user.toJson();
    await userRef.set(json);
  }

  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('consultas').doc();

    user.id = docUser.id;
    final json = user.toJson();
    await docUser.set(json);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(primary: Colors.blue)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controllerDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}
