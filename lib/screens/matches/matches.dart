import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:players_app/backend_config/config.dart';
import 'dart:convert';
import 'package:players_app/models/match_details.dart';
import 'package:players_app/services/fetch_matches.dart';
import 'package:players_app/widgets/matches/add_matches.dart';
import 'package:players_app/widgets/matches/edit_matches.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() {
    return _MatchesScreenState();
  }
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<MatchDetails> _matches = [];

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
    setState(() {
      _matches.sort((a, b) => a.matchDate
          .toIso8601String()
          .compareTo(b.matchDate.toIso8601String()));
    });
  }

  Future<void> _loadMatches() async {
    try {
      final matches = await fetchMatches();
      setState(() {
        _matches = matches;
        _matches.sort((a, b) => a.matchDate
          .toIso8601String()
          .compareTo(b.matchDate.toIso8601String()));
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading teams: $error');
    }
  }

  void _addMatches() async {
    final newMatch = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const AddMatches()));

    if (newMatch == null) {
      return;
    }
    _loadMatches();
    setState(() {
      _matches.add(newMatch);
      _matches.sort((a, b) => a.matchDate
          .toIso8601String()
          .compareTo(b.matchDate.toIso8601String()));
    });
  }

  void _deleteMatch(String id) async {
    try {
      final url = Uri.parse(deleteMatchUrl(id));
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete team');
      }

      setState(() {
        _matches.removeWhere((matches) => matches.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match deleted successfully')),
      );
      _loadMatches();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete match')),
      );
    }
  }

  void _editMatches(dataIndex) async {
    final updatedMatch = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditMatches(
          data: dataIndex,
        ),
      ),
    );

    if (updatedMatch == null) {
      return;
    }

    setState(() {
      _matches.add(updatedMatch);
    });
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? Center(
                  child: Text(
                    "No Matches found! Try adding new",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                )
              : ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (ctx, index) {
                    final match = _matches[index];
                    final now = DateTime.now();
                    final matchDate = match.matchDate;
                    final isMatchYetToBegin = matchDate.isAfter(now);
                    final isMatchToday = matchDate.year == now.year &&
                        matchDate.month == now.month &&
                        matchDate.day == now.day;
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        leading: Text(
                            _matches[index].matchDate.toString().split(" ")[0]),
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_matches[index].matchOrder} Match, ${_matches[index].tournamentName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _matches[index].teamA.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        _matches[index].teamB.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(_matches[index].matchTime),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isMatchYetToBegin)
                                          Text(
                                            'Match Yet to begin',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondaryContainer),
                                          )
                                        else if (isMatchToday ||
                                            matchDate.isBefore(now))
                                          Text(
                                            'Result Declared',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondaryContainer),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Expanded(
                                        //   child: IconButton(
                                        //     icon: Icon(Icons.edit),
                                        //     onPressed: () {
                                        //       _editMatches(_matches[index]);
                                        //     },
                                        //   ),
                                        // ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              _deleteMatch(_matches[index].id);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMatches,
        label: Text("Matches"),
        icon: Icon(Icons.add),
      ),
    );
  }
}
