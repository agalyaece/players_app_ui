class TournamentDetails {
  const TournamentDetails({
    required this.id,
    required this.tournamentName,
    required this.hostingCountry,
  });
  final String id;
  final String tournamentName;
  final String hostingCountry;

  factory TournamentDetails.fromJson(Map<String,dynamic> json){
    return TournamentDetails(
      id: json['_id'] ?? '',
      tournamentName: json['tournament_name'] ?? '',
      hostingCountry: json['hosting_country'] ?? '',
    );
  }
}
