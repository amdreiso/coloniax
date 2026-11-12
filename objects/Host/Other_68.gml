
var type = async_load[? "type"];

switch (type) {
	case network_type_connect: {
		var socketID = async_load[? "socket"];
		clients[? socketID] = currentPlayerID;
		
		// Create puppet player on hosts machine
		var ctrl = network_create_controllable_player(-8000+irandom(200), irandom(200), currentPlayerID, true);

		// Welcomes new client to every connected client, creating puppet/controlled players in all of them
		var b = buffer_create(256, buffer_grow, 1);
		buffer_write(b, buffer_u8, NET.WELCOME);
		buffer_write(b, buffer_u8, currentPlayerID);
		
		/*
			world stuff
		*/
		buffer_write(b, buffer_u32, Seed);
		
		
		// Send every connected player to new client so it creates all existing clients as puppets and itself as a controllable player
		buffer_write(b, buffer_u8, ds_map_size(players));
		var playerID = ds_map_find_first(players);
		while (!is_undefined(playerID)) {
			var p = players[? playerID];
			buffer_write(b, buffer_u8, playerID);
			buffer_write(b, buffer_f32, p.x);
			buffer_write(b, buffer_f32, p.y);
			playerID = ds_map_find_next(players, playerID);
		}
		
		network_send_packet(socketID, b, buffer_tell(b));
		buffer_delete(b);
		
		// Tell every client to spawn a puppet player with the respective ID
		var s = buffer_create(16, buffer_grow, 1);
	    buffer_write(s, buffer_u8, NET.SPAWN);
	    buffer_write(s, buffer_u8, currentPlayerID);
	    buffer_write(s, buffer_f32, ctrl.x);
	    buffer_write(s, buffer_f32, ctrl.y);
		network_broadcast(s, socketID);
		buffer_delete(s);
		
		currentPlayerID ++;
		CHAT.DebugNetwork($"HOST: Client '{socketID}' connected.");
		break;
	}
	
	case network_type_disconnect: {
		var socketID = async_load[? "socket"];
		var playerID = clients[? socketID];
		
		if (playerID != undefined) {
			var inst = players[? playerID];
			if (inst != undefined && instance_exists(inst)) {
				instance_destroy(inst);
			}
			
			ds_map_delete(players, playerID);
		}
		
		ds_map_delete(clients, socketID);
		
		CHAT.DebugNetwork($"HOST: Client '{socketID}' disconnected.");
		break;
	}
	
	case network_type_data: {
		var buffer = async_load[? "buffer"];
		var socketID = async_load[? "id"];
		var size = async_load[? "size"];
		
		network_handle_packet(buffer, socketID, size);
		
		if (Debug.showNetworkPackets) {
			CHAT.DebugNetwork($"HOST: Received packet of size '{size}'");
		}
		
		break;
	}
}

