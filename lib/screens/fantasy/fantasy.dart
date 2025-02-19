import 'package:flutter/material.dart';
import 'package:players_app/models/match_details.dart';
import 'package:players_app/services/fetch_matches.dart';
import 'package:players_app/widgets/fantasy/fantasy.dart';

class FantasyScreen extends StatefulWidget {
  const FantasyScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _FantasyScreenState();
  }
}

class _FantasyScreenState extends State<FantasyScreen> {
  List<MatchDetails> _matches = [];
  var _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final matches = await fetchMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading teams: $error');
    }
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
                            ],
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => Fantasy(
                            teamA: _matches[index].teamA,
                            teamB: _matches[index].teamB,
                            tournamentName: _matches[index].tournamentName
                          )));
                        },
                      ),
                      
                    );
                  },
                ),
    );
  }
}
