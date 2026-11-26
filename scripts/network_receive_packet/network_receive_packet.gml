
/*
	CLIENT SIDE PACKET
*/

function network_create_controllable_player(x, y, netID, puppet=false) {
	var controller	= instance_create_depth(x, y, -99999, Controller);
	var player		= instance_create_layer(x, y, "Spaceship", Player);
	var spaceship	= instance_create_layer(x, y, "Spaceship", Spaceship);

	controller.networkControllerID	= netID;
	player.networkControllerID		= netID;
	spaceship.networkControllerID	= netID;
	
	player.isPuppet		= puppet;
	spaceship.isPuppet	= puppet;
	
	controller.control(spaceship);
	controller.setPlayer(player);
	
	if (!puppet) {
		var cam = instance_create_depth(x, y, -999999, Camera);
		cam.target = controller;
	}

	players[? netID] = controller;
	return controller;
}

function network_receive_packet(buffer, socket, size){
	var msg = buffer_read(buffer, buffer_u8);
	
	switch (msg) {
		case NET.WELCOME: {
			Client.networkControllerID = buffer_read(buffer, buffer_u8);
			
			var seed = buffer_read(buffer, buffer_u32);
			Seed = seed;
			World.seed = seed;
			
			// Create every player
			var num = buffer_read(buffer, buffer_u8);
			repeat (num) {
				var netID = buffer_read(buffer, buffer_u8);
				var xx = buffer_read(buffer, buffer_f32);
				var yy = buffer_read(buffer, buffer_f32);

				if (netID == Client.networkControllerID) {
					network_create_controllable_player(xx, yy, netID);
					
				} else {
					network_create_controllable_player(xx, yy, netID, true);
					
				}
			}

			log("[NETWORK]: received 'WELCOME' packet");
			break;
		}

		case NET.SPAWN: {
			var pid = buffer_read(buffer, buffer_u8);
			var px = buffer_read(buffer, buffer_f32);
			var py = buffer_read(buffer, buffer_f32);
			
			network_create_controllable_player(px, py, pid, true);

			log("[NETWORK]: received 'SPAWN' packet");
			break;
		}

		case NET.STATE: {
			var playerNum = buffer_read(buffer, buffer_u8);
			repeat (playerNum) {
				var pid = buffer_read(buffer, buffer_u8);
				var px = buffer_read(buffer, buffer_f32);
				var py = buffer_read(buffer, buffer_f32);
				var pdir = buffer_read(buffer, buffer_u16);

				// Updated everybody except self
				if (pid == Client.networkControllerID) continue;

				var ctrl = players[? pid];
				if (ctrl != undefined && instance_exists(ctrl)) {
					var target = ctrl.controlledInstance;
					if (target != undefined && instance_exists(target)) {
						target.newx = px;
						target.newy = py;
						target.dir = pdir;
					}
				}
			}

			log("[NETWORK]: received 'STATE' packet");
			break;
		}
		
		case NET.CHAT_MESSAGE: {
			var sender = buffer_read(buffer, buffer_u8);
			var text = buffer_read(buffer, buffer_string);
			CHAT.Send(text, true);

			log("[NETWORK]: received 'CHAT_MESSAGE' packet");
			break;
		}
	}
}
