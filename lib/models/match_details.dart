class MatchDetails {
  const MatchDetails({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.tournamentName,
    required this.matchDate,
    required this.matchOrder,
     this.matchStatus = 'Match Yet to begin',
    required this.matchTime,
  });

  final String id;
  final String tournamentName;
  final String teamA;
  final String teamB;
  final DateTime matchDate;
  final String matchOrder;
  final String matchStatus;
  final String matchTime;

  factory MatchDetails.fromJson(Map<String, dynamic> json) {
    return MatchDetails(
        id: json['_id'] ?? '',
        teamA: json['team_A'] ?? '',
        teamB: json['team_B'] ?? '',
        tournamentName: json['tournament_name'] ?? '',
        matchDate: DateTime.parse(json['match_date']) ,
        matchOrder: json['match_order'] ?? '',
        matchStatus: json['match_status'] ?? '',
        matchTime: json['match_time'] ?? DateTime.now());
  }
}
