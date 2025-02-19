import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/tournament_details.dart';

class EditTournament extends StatefulWidget {
  final TournamentDetails data;
  const EditTournament({
    super.key,
    required this.data,
  });

  @override
  State<EditTournament> createState() {
    return _EditTournamentState();
  }
}

class _EditTournamentState extends State<EditTournament> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredTournamentName;
  String? _enteredHostingCountry;
  var _isSending = false;

  @override
  void initState() {
    super.initState();
    _enteredTournamentName = widget.data.tournamentName;
    _enteredHostingCountry = widget.data.hostingCountry;
  }

  void _updateTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSending = true;
    });
    _formKey.currentState!.save();

    final url = Uri.parse(updateTournamentUrl(widget.data.id));
    final response = await http.patch(
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
      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament updated successfully')),
      );

      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update Tournament')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Tournament"),
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
                initialValue: _enteredTournamentName,
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
                initialValue: _enteredHostingCountry,
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
                              setState(() {
                                _enteredTournamentName =
                                    widget.data.tournamentName;
                                _enteredHostingCountry =
                                    widget.data.hostingCountry;
                              });
                            },
                      child: const Text("Reset")),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSending ? null : _updateTournament,
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
