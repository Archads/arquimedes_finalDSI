import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/user.dart';
import 'main.dart';
import 'package:intl/intl.dart';

// user_page.dart
class UserPage extends StatefulWidget {
  final String? userId;
  final String? userName;
  final int? userAge;
  final DateTime? userAppointmentDateTime;

  UserPage({
    this.userId,
    this.userName,
    this.userAge,
    this.userAppointmentDateTime,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDateTime = TextEditingController();

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
    if (widget.userAppointmentDateTime != null) {
      controllerDateTime.text = DateFormat('yyyy-MM-dd HH:mm')
          .format(widget.userAppointmentDateTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId != null
            ? 'Editar detalhes da consulta'
            : 'Cadastrar nova consulta'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: controllerName,
            decoration: decoration('Nome do paciente'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controllerAge,
            decoration: decoration('Código de consulta do paciente'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controllerDateTime,
            decoration: decoration('Data e Hora da consulta'),
            readOnly: true,
            onTap: () {
              _selectDateTime(context);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: Text(widget.userId != null ? 'Atualizar' : 'Criar'),
            onPressed: () {
              if (widget.userId != null) {
                final updatedUser = User(
                  id: widget.userId!,
                  name: controllerName.text,
                  age: int.tryParse(controllerAge.text) ?? 0,
                  appointmentDateTime:
                      DateTime.tryParse(controllerDateTime.text) ??
                          DateTime.now(),
                );
                updateUser(updatedUser);
              } else {
                final newUser = User(
                  name: controllerName.text,
                  age: int.tryParse(controllerAge.text) ?? 0,
                  appointmentDateTime:
                      DateTime.tryParse(controllerDateTime.text) ??
                          DateTime.now(),
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

  Future<void> _selectDateTime(BuildContext context) async {
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
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (timePicked != null) {
        final pickedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );

        setState(() {
          controllerDateTime.text =
              DateFormat('yyyy-MM-dd HH:mm').format(pickedDateTime);
        });
      }
    }
  }
}
