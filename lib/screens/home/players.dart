import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/player_details.dart';
import 'package:players_app/widgets/home/add_player.dart';
import 'package:players_app/widgets/home/edit_player.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  List<PlayerDetails> _player = [];
  List<PlayerDetails> _searchList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
    _searchController.addListener(_searchPlayers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchPlayers);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchPlayers() async {
    final url = Uri.parse(getPlayersUrl);
    final response = await http.get(url);
    if (response.statusCode != 201) {
      throw Exception('Failed to load players');
    }
    final List<dynamic> extractedData = json.decode(response.body);

    final List<PlayerDetails> _loadedItems =
        extractedData.map((item) => PlayerDetails.fromJson(item)).toList();
    print(extractedData);
    setState(() {
      _player = _loadedItems;
      _searchList = _loadedItems;
    });
  }

  void _addNewPlayers() async {
    final newItem = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const AddPlayer()));

    if (newItem == null) {
      return;
    }
    _fetchPlayers();
    setState(() {
      _player.add(newItem);
    });
  }

  void _editPlayer(dataIndex) async {
    final newItem = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => EditPlayer(data: dataIndex)));

    if (newItem == null) {
      return;
    }
    _fetchPlayers();
    setState(() {
      _player.add(newItem);
    });
  }

  void _deletePlayer(String id) async {
    final url = Uri.parse(deletePlayerUrl(id));
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete player');
    }

    setState(() {
      _player.removeWhere((player) => player.id == id);
      _searchList.removeWhere((player) => player.id == id);
    });
    _fetchPlayers();
  }

  void _searchPlayers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchList = _player.where((player) {
        return player.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PlayerDetails> _searchList = _player
        .where((element) => element.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Players"),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _searchList.isEmpty
                  ? Center(
                      child: Text(
                        'No player found',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchList.length,
                      itemBuilder: (ctx, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(_searchList[index].born),
                            ),
                            title: Text(_searchList[index].name),
                            subtitle: Text('Age: ${_searchList[index].age}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editPlayer(_searchList[index]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deletePlayer(_searchList[index].id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNewPlayers, label: Text("Add Players")),
    );
  }
}
