import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:players_app/backend_config/config.dart';

class AddPlayers extends StatefulWidget {
  final String teamA;
  final String teamB;
  final String tournamentName;
  final String matchDate;
  const AddPlayers({
    super.key,
    required this.tournamentName,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
  });

  @override
  State<StatefulWidget> createState() {
    return _AddPlayersState();
  }
}

class _AddPlayersState extends State<AddPlayers> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _teamAPlayers = [];
  List<dynamic> _teamBPlayers = [];
  List<dynamic> _selectedPlayersTeamA = [];
  List<dynamic> _selectedPlayersTeamB = [];

  final int _maxTotalPlayers = 11;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse(addPlayerToMatchUrl(widget.teamA, widget.teamB)));
      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        // print('Response Body: $responseBody');
        final List<dynamic> players = responseBody;
        setState(() {
          _teamAPlayers = players
              .where((team) => team['team_name'] == widget.teamA)
              .expand((team) => team['players'])
              .toList();

          _teamBPlayers = players
              .where((team) => team['team_name'] == widget.teamB)
              .expand((team) => team['players'])
              .toList();
          _isLoading = false;
        });
        // print('team a: $_teamAPlayers');
        // print('team b: $_teamBPlayers');
      } else {
        throw Exception('Failed to load teams');
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _togglePlayerSelection(dynamic player) {
    setState(() {
      if (player['player_team'] == widget.teamA) {
        if (_selectedPlayersTeamA.contains(player)) {
          _selectedPlayersTeamA.remove(player);
        } else if (_selectedPlayersTeamA.length < _maxTotalPlayers) {
          _selectedPlayersTeamA.add(player);
        }
      } else if (player['player_team'] == widget.teamB) {
        if (_selectedPlayersTeamB.contains(player)) {
          _selectedPlayersTeamB.remove(player);
        } else if (_selectedPlayersTeamB.length < _maxTotalPlayers) {
          _selectedPlayersTeamB.add(player);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.teamA.toUpperCase()}  vs  ${widget.teamB.toUpperCase()}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.0),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Text(
                          'Selected Players Team A: ${_selectedPlayersTeamA.length}/$_maxTotalPlayers',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.0),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text(
                          'Playing XI - ${widget.teamA.toUpperCase()}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _teamAPlayers.length,
                          itemBuilder: (ctx, index) {
                            return _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Card(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 9),
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: _selectedPlayersTeamA
                                            .contains(_teamAPlayers[index]),
                                        onChanged: (bool? value) {
                                          _togglePlayerSelection(
                                              _teamAPlayers[index]);
                                        },
                                      ),
                                      title: Text(
                                          '${_teamAPlayers[index]['player_name']}  '),
                                      onTap: () {
                                        _togglePlayerSelection(
                                            _teamAPlayers[index]);
                                      },
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.0),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Text(
                          'Selected Players Team B: ${_selectedPlayersTeamB.length}/$_maxTotalPlayers',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.0),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text(
                          'Playing XI - ${widget.teamB.toUpperCase()}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _teamBPlayers.length,
                          itemBuilder: (ctx, index) {
                            return _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Card(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 9),
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: _selectedPlayersTeamB
                                            .contains(_teamBPlayers[index]),
                                        onChanged: (bool? value) {
                                          _togglePlayerSelection(
                                              _teamBPlayers[index]);
                                        },
                                      ),
                                      title: Text(
                                          '${_teamBPlayers[index]['player_name']} '),
                                      onTap: () {
                                        _togglePlayerSelection(
                                            _teamBPlayers[index]);
                                      },
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
