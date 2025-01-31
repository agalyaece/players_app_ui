class PlayerDetails {
  const PlayerDetails({
    required this.id,
    required this.name,
    required this.age,
    required this.born,
    this.teams = const [],
  });

  final String id;
  final String name;
  final int age;
  final String born;
  final List<String> teams;

  factory PlayerDetails.fromJson(Map<String, dynamic> json) {
    return PlayerDetails(
      id: json["_id"] ?? '',
      name: json["name"] ?? '',
      age: json["age"] ?? 0,
      born: json["born"] ?? '',
    );
  }
}
