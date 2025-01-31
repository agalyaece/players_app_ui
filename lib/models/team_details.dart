class TeamDetails {
  const TeamDetails({
    required this.id,
    required this.name,
    required this.category,
    required this.players,
  });
  final String id;
  final String name;
  final String category;
  final List<String> players;

  factory TeamDetails.fromJson(Map<String, dynamic> json) {
    return TeamDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      players:
          json['players'] != null ? List<String>.from(json['players']) : [],
    );
  }
}
