import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/screens/home/tournament.dart';

class AddTournament extends StatefulWidget {
  const AddTournament({super.key});
  @override
  State<AddTournament> createState() {
    return _AddTournamentState();
  }
}

class _AddTournamentState extends State<AddTournament> {
  final _formKey = GlobalKey<FormState>();

  var _enteredTournamentName = "";
  var _enteredHostingCountry = "";
  var _isSending = false;

  void _addTournament() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.parse(addTournamentUrl);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "tournament_name": _enteredTournamentName,
          "hosting_country": _enteredHostingCountry,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newItem = json.decode(response.body);

        if (!context.mounted) {
          return;
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text("Success", style: TextStyle(color: Colors.green)),
              content: Text(
                  json.decode(response.body)['message'] ??
                      "The addition was Successful",
                  style: TextStyle(color: Colors.white)),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, newItem);
                    Navigator.pop(context, const TournamentScreen());
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _isSending = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error", style: TextStyle(color: Colors.red)),
              content: Text(
                  json.decode(response.body)['message'] ??
                      "Failed to add Tournament. Please try again.",
                  style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Tournament"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tournament Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter valid characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredTournamentName = value!;
                },
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Hosting Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter valid characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredHostingCountry = value!;
                },
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text("Reset")),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSending ? null : _addTournament,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
