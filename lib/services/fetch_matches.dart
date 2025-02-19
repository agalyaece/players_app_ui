import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:players_app/models/match_details.dart';
import 'package:players_app/backend_config/config.dart';


Future <List<MatchDetails>> fetchMatches() async{
try {
    final url = Uri.parse(getMatchesUrl);
    final response = await http.get(url);
    
    if (response.statusCode != 201) {
      throw Exception('Failed to load teams');
    }
    final List<dynamic> extractedData = json.decode(response.body);
   
    final List<MatchDetails> _loadedItems =
        extractedData.map((item) => MatchDetails.fromJson(item)).toList();
    return _loadedItems;
  } catch (error) {
   
    throw error;
  }
}