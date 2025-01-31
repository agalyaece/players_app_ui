import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:players_app/backend_config/config.dart';
import 'dart:convert';

import 'package:players_app/models/player_details.dart';
import 'package:players_app/screens/home/teams.dart';

class AddTeam extends StatefulWidget {
  const AddTeam({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddTeamState();
  }
}

class _AddTeamState extends State<AddTeam> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  var _enteredCategory = "";
  var _isSending = false;
  List<String> _selectedPlayers = [];

  Future<List<PlayerDetails>> _fetchPlayers() async {
    final url = Uri.parse(getPlayersUrl);
    final response = await http.get(url);
    if (response.statusCode != 201) {
      throw Exception('Failed to load players');
    }
    final List<dynamic> extractedData = json.decode(response.body);
    final List<PlayerDetails> _loadedItems =
        extractedData.map((item) => PlayerDetails.fromJson(item)).toList();
    return _loadedItems;
  }

  void _addTeams() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.parse(addTeamUrl);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "category": _enteredCategory,
          "name": _enteredName,
          "players": _selectedPlayers,
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
                    Navigator.pop(context, const TeamsScreen());
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
                      "Failed to add player. Please try again.",
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
        title: Text("Add Team"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Team Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter valid characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredCategory = value!;
                  },
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Team Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter valid characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredName = value!;
                  },
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                const SizedBox(
                  height: 16,
                ),
                FutureBuilder<List<PlayerDetails>>(
                  future: _fetchPlayers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final players = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<PlayerDetails>(
                            decoration:
                                InputDecoration(labelText: 'Select Players'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                            items: players.map((player) {
                              return DropdownMenuItem<PlayerDetails>(
                                value: player,
                                child: Text(player.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                if (value != null &&
                                    !_selectedPlayers.contains(value)) {
                                  _selectedPlayers.add(value.name);
                                  players.remove(value);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            children: _selectedPlayers.map((player) {
                              return Chip(
                                label: Text(player),
                                onDeleted: () {
                                  setState(() {
                                    _selectedPlayers.remove(player);
                                    players.add(players
                                        .firstWhere((p) => p.name == player));
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
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
                                  _selectedPlayers.clear();
                                });
                              },
                        child: const Text("Reset")),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSending ? null : _addTeams,
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
            )),
      ),
    );
  }
}
