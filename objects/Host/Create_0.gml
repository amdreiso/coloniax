
enum NET {
	WELCOME,
	STATE,
	SPAWN,
	
	PLAYER_INPUT,
	CHAT_MESSAGE,
}

if (!variable_instance_exists(id, "port")) port = 5000;
server = network_create_server(network_socket_tcp, port, 4);

clients = ds_map_create();
players = ds_map_create();
currentPlayerID = 1;

var px = -8000;
var py = 0;

network_create_controllable_player(px, py, 0);
spawn(px, py-600, "Spaceship", Formation);

alarm[0] = 1;

if (server < 0) {
	CHAT.DebugNetwork($"HOST: Failed to create server.");
} else {
	CHAT.DebugNetwork($"HOST: Created server successfully at port {port}.");
}

