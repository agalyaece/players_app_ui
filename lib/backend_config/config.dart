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
