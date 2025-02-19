import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/models/team_details.dart';
import 'package:players_app/backend_config/config.dart';

Future<List<TeamDetails>> fetchTeams() async {
  try {
    final url = Uri.parse(getTeamsUrl);
    final response = await http.get(url);
    
    if (response.statusCode != 201) {
      throw Exception('Failed to load teams');
    }
    final List<dynamic> extractedData = json.decode(response.body);
   
    final List<TeamDetails> _loadedItems =
        extractedData.map((item) => TeamDetails.fromJson(item)).toList();
    return _loadedItems;
  } catch (error) {
   
    throw error;
  }
}