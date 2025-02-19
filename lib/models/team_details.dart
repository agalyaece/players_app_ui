import 'package:players_app/models/player_details.dart';

class Player {
  final String name;
  final String team;

  Player({required this.name, required this.team});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['player_name'],
      team: json['player_team'],
    );
  }

  factory Player.fromDetails(PlayerDetails details) {
    return Player(
      name: details.name,
      team: details.teams.isNotEmpty ? details.teams[0] : '',
    );
  }
}

class TeamDetails {
  const TeamDetails({
    required this.id,
    required this.teamName,
    required this.category,
    required this.players,
  });

  final String id;
  final String teamName;
  final String category;
  final List<Player> players;

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      id: json['_id'] ?? '',
      teamName: json['team_name'] ?? '',
      category: json['category'] ?? '',
      players: json['players'] != null
          ? List<Player>.from(json['players'].map((player) => Player.fromJson(player)))
          : [],
    );
  }

  
}