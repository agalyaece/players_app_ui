import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/tournament_details.dart';

Future<List<TournamentDetails>> fetchTournament() async {
  try {
    final url = Uri.parse(getTournamentUrl);
    final response = await http.get(url);
    if (response.statusCode != 201) {
      throw Exception('Failed to load tournament');
    }
    final List<dynamic> extractedData = json.decode(response.body);

    final List<TournamentDetails> _loadedItems =
        extractedData.map((item) => TournamentDetails.fromJson(item)).toList();
    return _loadedItems;
  } catch (error) {
    throw error;
  }
}
