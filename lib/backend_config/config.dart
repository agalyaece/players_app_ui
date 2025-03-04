// const baseUrl = "http://192.168.1.2:3000/";
const baseUrl = "https://player-app-webservice.onrender.com/";

const addPlayerUrl = baseUrl + "home/players/add_player";
const getPlayersUrl = baseUrl + "home/players/get_players";
String updatePlayerUrl(String id) {
  return baseUrl + "home/players/update_player/" + id;
}

String deletePlayerUrl(String id) {
  return baseUrl + "home/players/delete_player/" + id;
}

const addTeamUrl = baseUrl + "home/teams/add_team";
const getTeamsUrl = baseUrl + "home/teams/get_teams";
String deleteTeamUrl(String id) {
  return baseUrl + "home/teams/delete_team/" + id;
}

String updateTeamUrl(String id) {
  return baseUrl + "home/teams/edit_team/" + id;
}

const addTournamentUrl = baseUrl + "home/tournaments/add_tournament";
const getTournamentUrl = baseUrl + "home/tournaments/get_tournaments";

String deleteTournamentUrl(String id) {
  return baseUrl + "home/tournaments/delete_tournament/" + id;
}

String updateTournamentUrl(String id) {
  return baseUrl + "home/tournaments/edit_tournament/" + id;
}

const getMatchesUrl = baseUrl + "matches/get_matches";

const addMatchesUrl = baseUrl + "matches/add_match";
String deleteMatchUrl(String id) {
  return baseUrl + "matches/delete_match/" + id;
}

String updateMatchUrl(String id) {
  return baseUrl + "matches/edit_matches/" + id;
}

String getPlayersForMatchUrl(String teamA, String teamB) {
  return baseUrl + "matches/get_players/" + teamA + "/" + teamB;
}

const addPlayerToMatchUrl = baseUrl + "matches/add_players_to_team";

String addFantasyUrl(String teamA, String teamB, String tournamentName, String matchDate) {
  return baseUrl + "fantasy/get_players/" + tournamentName +"/" + teamA + "/" + teamB+"/" + matchDate;
}
