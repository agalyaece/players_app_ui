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
