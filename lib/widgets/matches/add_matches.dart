import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/team_details.dart';
import 'package:players_app/models/tournament_details.dart';
import 'package:players_app/screens/matches/matches.dart';
import 'package:players_app/services/fetch_teams.dart';
import 'package:players_app/services/fetch_tournaments.dart';

class AddMatches extends StatefulWidget {
  const AddMatches({super.key});
  @override
  State<AddMatches> createState() {
    return _AddMatchesState();
  }
}

class _AddMatchesState extends State<AddMatches> {
  final _formKey = GlobalKey<FormState>();
  List<TeamDetails> _team = [];

  List<TournamentDetails> _tournament = [];

  String? _selectedTeamA;
  String? _selectedTeamB;
  String? _selectedTournament;
  DateTime? _matchDate;
  TimeOfDay? _matchTime;
  String _matchOrder = '';
  String _matchStatus = '';

  bool _isSending = false;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await fetchTeams();
      setState(() {
        _team = teams.toSet().toList();
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading teams: $error');
    }
  }

  Future<void> _loadTournaments() async {
    try {
      final tournaments = await fetchTournament();
      setState(() {
        _tournament = tournaments.toSet().toList();
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading teams: $error');
    }
  }

  void _addMatches() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.parse(addMatchesUrl);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "team_A": _selectedTeamA,
          "team_B": _selectedTeamB,
          "tournament_name": _selectedTournament,
          "match_date": _matchDate?.toIso8601String(),
          "match_order": _matchOrder,
          "match_time": _matchTime?.format(context),
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
                    Navigator.pop(context);
                    Navigator.pop(context, newItem);
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
        title: Text("Add Matches data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Select Tournament'),
                value: _selectedTournament,
                items: _tournament.map((TournamentDetails tournament) {
                  return DropdownMenuItem<String>(
                    value: tournament.tournamentName,
                    child: Text(tournament.tournamentName),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTournament = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select tournament';
                  }
                  return null;
                },
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Team A'),
                      value: _selectedTeamA,
                      items: _team.map((TeamDetails team) {
                        return DropdownMenuItem<String>(
                          value: team.teamName,
                          child: Text(team.teamName),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTeamA = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select Team A';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Team B'),
                      value: _selectedTeamB,
                      items: _team.map((TeamDetails team) {
                        return DropdownMenuItem<String>(
                          value: team.teamName,
                          child: Text(team.teamName),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTeamB = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select Team B';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              ListTile(
                title: Text(
                    ' ${_matchDate != null ? _matchDate.toString().split(' ')[0] : 'Select Date'}'),
                leading: Text(
                  "Match Date:",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _matchDate) {
                    setState(() {
                      _matchDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(
                height: 16,
              ),
              ListTile(
                title: Text(
                    ' ${_matchTime != null ? _matchTime!.format(context) : 'Select Time'}'),
                leading: Text(
                  "Match Time:",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null && picked != _matchTime) {
                    setState(() {
                      _matchTime = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Match Order',
                  helperText: 'e.g., 1st, 3rd, final',
                ),
                onChanged: (value) {
                  setState(() {
                    _matchOrder = value;
                  });
                },
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter match order';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: _isSending
                      ? null
                      : () {
                          _formKey.currentState!.reset();
                          setState(() {
                            _selectedTournament = null;
                            _matchDate = null;
                            _selectedTeamA = null;
                            _selectedTeamB = null;
                            _matchOrder = '';
                            _matchTime = null;
                          });
                        },
                  child: Text("Reset"),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: _isSending ? null : _addMatches,
                  child: _isSending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(),
                        )
                      : Text('Submit'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
