import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:players_app/backend_config/config.dart';

class Fantasy extends StatefulWidget {
  final String teamA;
  final String teamB;
  final String tournamentName;
  final String matchDate;

  const Fantasy({
    super.key,
    required this.tournamentName,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
  });

  @override
  State<Fantasy> createState() {
    return _FantasyState();
  }
}

class _FantasyState extends State<Fantasy> {
  bool _isLoading = false;
  String? _error;
  List<dynamic> _teamAPlayers = [];
  List<dynamic> _teamBPlayers = [];
  List<dynamic> _selectedPlayers = [];
  final int _maxPlayersPerTeam = 7;
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
      final response = await http.get(Uri.parse(addFantasyUrl(widget.teamA,
          widget.teamB, widget.tournamentName, widget.matchDate)));
      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        // print('Response Body: $responseBody');
        final List<dynamic> players = responseBody;
        setState(() {
          _teamAPlayers = players
              .where((team) => team['team_A'] == widget.teamA)
              .expand((team) => team['players_team_A'])
              .toList();

          _teamBPlayers = players
              .where((team) => team['team_B'] == widget.teamB)
              .expand((team) => team['players_team_B'])
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
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else {
        if (_selectedPlayers.length < _maxTotalPlayers) {
          int teamASelected = _selectedPlayers
              .where((p) => p['player_team'] == widget.teamA)
              .length;
          int teamBSelected = _selectedPlayers
              .where((p) => p['player_team'] == widget.teamB)
              .length;
          if ((player['player_team'] == widget.teamA &&
                  teamASelected < _maxPlayersPerTeam) ||
              (player['player_team'] == widget.teamB &&
                  teamBSelected < _maxPlayersPerTeam)) {
            _selectedPlayers.add(player);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.teamA.toUpperCase()} vs ${widget.teamB.toUpperCase()}"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.0),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              'Selected Players: ${_selectedPlayers.length}/$_maxTotalPlayers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
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
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _teamAPlayers.isEmpty
                                ? Center(
                                    child: Text(
                                      "No Players found! Try adding new",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _teamAPlayers.length,
                                    itemBuilder: (ctx, index) {
                                      return _isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : Card(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 9),
                                              child: ListTile(
                                                leading: Checkbox(
                                                  value:
                                                      _selectedPlayers.contains(
                                                          _teamAPlayers[index]),
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
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _teamBPlayers.isEmpty
                                ? Center(
                                    child: Text(
                                      "No Players found! Try adding new",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _teamBPlayers.length,
                                    itemBuilder: (ctx, index) {
                                      return _isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : Card(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 9),
                                              child: ListTile(
                                                leading: Checkbox(
                                                  value:
                                                      _selectedPlayers.contains(
                                                          _teamBPlayers[index]),
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
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'Selected Players',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _selectedPlayers.isEmpty
                      ? [
                          Text("No players selected please select",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))
                        ]
                      : _selectedPlayers
                          .map((player) => Text(
                                '${player['player_name']} - ${player['player_team']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ))
                          .toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
          icon: Icon(Icons.check),
          label: Text("Selected Players")),
    );
  }
}

// Widget _buildTeamColumn(String teamName, List<PlayerDetails> players) {
//   return Column(
//     children: [
//       Container(
//         padding: const EdgeInsets.all(8.0),
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(9.0),
//           color: Theme.of(context).colorScheme.primaryContainer,
//         ),
//         child: Text(
//           'Playing XI - $teamName',
//           style: const TextStyle(
//               fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//       ),
//       Expanded(
//         child: ListView.builder(
//           itemCount: players.length,
//           itemBuilder: (ctx, index) {
//             final player = players[index];
//             return Card(
//               color: Colors.blueGrey,
//               margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
//               child: ListTile(
//                 leading: Checkbox(
//                   value: _selectedPlayers.any((p) => p.id == player.id),
//                   onChanged: (bool? value) {
//                     _togglePlayerSelection(player);
//                   },
//                 ),
//                 title: Text(player.name),
//                 onTap: () {
//                   _togglePlayerSelection(player);
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }
