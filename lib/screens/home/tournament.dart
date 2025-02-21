import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/tournament_details.dart';
import 'package:players_app/services/fetch_tournaments.dart';
import 'package:players_app/widgets/home/add_tournament.dart';
import 'package:players_app/widgets/home/edit_tournament.dart';
import 'package:players_app/widgets/matches/add_matches.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});
  @override
  State<TournamentScreen> createState() {
    return _TournamentScreenState();
  }
}

class _TournamentScreenState extends State<TournamentScreen> {
  List<TournamentDetails> _tournament = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    try {
      final tournaments = await fetchTournament();
      setState(() {
        _tournament = tournaments;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading teams: $error');
    }
  }

  void _addTournament() async {
    final newTournament = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const AddTournament()));

    if (newTournament == null) {
      return;
    }
    _loadTournaments();
    setState(() {
      _tournament.add(newTournament);
    });
  }

  void _deleteTeam(String id) async {
    try {
      final url = Uri.parse(deleteTournamentUrl(id));
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete team');
      }

      setState(() {
        _tournament.removeWhere((tournament) => tournament.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tournament deleted successfully')),
      );
      _loadTournaments();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete tournament')),
      );
    }
  }

  void _editTeam(dataIndex) async {
    final updatedTournament = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditTournament(
          data: dataIndex,
        ),
      ),
    );

    if (updatedTournament == null) {
      return;
    }

    setState(() {
      _tournament.add(updatedTournament);
    });
    _loadTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tournaments"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tournament.isEmpty
              ? Center(
                  child: Text(
                    "No Tournaments found! Try adding new",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                )
              : ListView.builder(
                  itemCount: _tournament.length,
                  itemBuilder: (ctx, index) {
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text(_tournament[index].tournamentName),
                        subtitle: Text(_tournament[index].hostingCountry),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: Icon(Icons.add),
                                tooltip: 'Add Matches',
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => const AddMatches()));
                                }),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editTeam(_tournament[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteTeam(_tournament[index].id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _addTournament, label: Text("Add Tournament")),
    );
  }
}
