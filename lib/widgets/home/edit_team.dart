import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/player_details.dart';
import 'package:players_app/models/team_details.dart';
import 'package:players_app/screens/home/teams.dart';

class EditTeam extends StatefulWidget {
  final TeamDetails data;
  final Function(TeamDetails) onUpdate;

  const EditTeam({super.key, required this.data, required this.onUpdate});

  @override
  State<StatefulWidget> createState() {
    return _EditTeamState();
  }
}

class _EditTeamState extends State<EditTeam> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredTeamName;
  String? _enteredCategory;
  var _isSending = false;
  List<PlayerDetails>? _selectedPlayers;
  List<PlayerDetails> _availablePlayers = [];

  @override
  void initState() {
    super.initState();
    _enteredTeamName = widget.data.teamName;
    _enteredCategory = widget.data.category;
    _selectedPlayers = widget.data.players.cast<PlayerDetails>();
    _fetchPlayers();
  }

Future<List<PlayerDetails>> _fetchPlayers() async {
    final url = Uri.parse(getPlayersUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> extractedData = json.decode(response.body);
        final List<PlayerDetails> loadedPlayers =
            extractedData.map((item) => PlayerDetails.fromJson(item)).toList();
        setState(() {
          _availablePlayers = loadedPlayers;
        });
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _availablePlayers = [];
      });
      throw Exception('Failed to load players: $error');
    }
    return _availablePlayers;
  }

  void _updateTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSending = true;
    });
    _formKey.currentState!.save();

    final url = Uri.parse(updateTeamUrl(widget.data.id));
    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "category": _enteredCategory,
        "name": _enteredTeamName,
        "players": _selectedPlayers!.map((player) => {
            "player_name": player.name,
            "player_team": _enteredTeamName,
          }).toList(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team updated successfully')),
      );
      widget.onUpdate(TeamDetails(
        id: widget.data.id,
        teamName: _enteredTeamName!,
        category: _enteredCategory!,
        players: _selectedPlayers!.map((player) => Player.fromDetails(player)).toList(),
      ));
      _fetchPlayers();
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update team')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Team'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Team Category'),
                    initialValue: _enteredCategory,
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
                    initialValue: _enteredTeamName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter valid characters';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredTeamName = value!;
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
                              items: _availablePlayers.map((player) {
                                return DropdownMenuItem<PlayerDetails>(
                                  value: player,
                                  child: Text(player.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null &&
                                      !_selectedPlayers!.contains(value.name)) {
                                    _selectedPlayers!.add(value);
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              children: _selectedPlayers!.map((player) {
                                return Chip(
                                  label: Text(player.name),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedPlayers!.remove(player);
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
                                    _selectedPlayers = widget.data.players.cast<PlayerDetails>();
                                    _enteredCategory = widget.data.category;
                                    _enteredTeamName = widget.data.teamName;
                                  });
                                },
                          child: const Text("Reset")),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isSending ? null : _updateTeam,
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
        ));
  }
}
