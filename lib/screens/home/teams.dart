import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/team_details.dart';
import 'package:players_app/widgets/home/add_team.dart';
import 'package:players_app/widgets/home/edit_team.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  List<TeamDetails> _team = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  void _addNewTeam() async {
    final newTeam = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const AddTeam()));

    if (newTeam == null) {
      return;
    }
    _fetchTeams();
    setState(() {
      _team.add(newTeam);
    });
  }

  Future<void> _fetchTeams() async {
    try {
      final url = Uri.parse(getTeamsUrl);
      final response = await http.get(url);

      if (response.statusCode != 201) {
        throw Exception('Failed to load teams');
      }
      final List<dynamic> extractedData = json.decode(response.body);

      final List<TeamDetails> _loadedItems =
          extractedData.map((item) => TeamDetails.fromJson(item)).toList();
      setState(() {
        _team = _loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteTeam(String id) async {
    try {
      final url = Uri.parse(deleteTeamUrl(id));
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete team');
      }

      setState(() {
        _team.removeWhere((team) => team.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team deleted successfully')),
      );
      _fetchTeams();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete team')),
      );
    }
  }

void _editTeam(TeamDetails team) async {
    final updatedTeam = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditTeam(
          data: team,
          onUpdate: (updatedTeam) {
            setState(() {
              final index = _team.indexWhere((t) => t.id == updatedTeam.id);
              if (index != -1) {
                _team[index] = updatedTeam;
              }
            });
          },
        ),
      ),
    );

    if (updatedTeam == null) {
      return;
    }

    setState(() {
      final index = _team.indexWhere((t) => t.id == updatedTeam.id);
      if (index != -1) {
        _team[index] = updatedTeam;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teams"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _team.isEmpty
              ? Center(child: Text('No teams available'))
              : ListView.builder(
                  itemCount: _team.map((team) => team.category).toSet().length,
                  itemBuilder: (ctx, index) {
                    final category = _team
                        .map((team) => team.category)
                        .toSet()
                        .elementAt(index);
                    final teamsInCategory = _team
                        .where((team) => team.category == category)
                        .toList();
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer),
                            ),
                          ),
                          Divider(),
                          ...teamsInCategory.map((team) {
                            return ExpansionTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(team.name),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _editTeam(team);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteTeam(team.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              children: team.players.map((player) {
                                return ListTile(
                                  title: Text(player),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewTeam, label: Text("Add Team")),
    );
  }
}
