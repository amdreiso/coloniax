
if (!variable_instance_exists(id, "address")) address = "127.0.0.1";
if (!variable_instance_exists(id, "port")) port = 5000;

socket = network_create_socket(network_socket_tcp);
connect = network_connect_async(socket, address, port);

CHAT.DebugNetwork($"Client is attempting to connect to {address}:{port}");

players = ds_map_create();
networkControllerID = 0;
