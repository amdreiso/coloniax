
/*
	SERVER SIDE PACKET
*/

function network_handle_packet(buffer, socketID, size){
	var msg = buffer_read(buffer, buffer_u8);
	
	switch (msg) {
		
		/*
			updates client player position
		*/
		case NET.PLAYER_INPUT: {
			var px  = buffer_read(buffer, buffer_f32);
			var py  = buffer_read(buffer, buffer_f32);
			var dir = buffer_read(buffer, buffer_s16);
			
			var playerID = clients[? socketID];
			if (playerID == undefined) break;

			var ctrl = players[? playerID];
			if (ctrl != undefined && instance_exists(ctrl)) {
				var target = ctrl.controlledInstance;
			    if (target != noone && instance_exists(target)) {
			        target.newx = px;
			        target.newy = py;
			        target.dir = dir;
			    }
			}

			log("[NETWORK]: handled 'PLAYER_INPUT' packet");
			break;
		}
		
		case NET.CHAT_MESSAGE: {
			var text = buffer_read(buffer, buffer_string);
			
		    var playerID = clients[? socketID];
		    if (playerID == undefined) break;
			
			var b = buffer_create(256, buffer_grow, 1);
			buffer_write(b, buffer_u8, NET.CHAT_MESSAGE);
			buffer_write(b, buffer_u8, playerID);
			buffer_write(b, buffer_string, text);
			network_broadcast(b, -1);
			buffer_delete(b);
			
		    CHAT.Send(text, true);
			
			log("[NETWORK]: handled 'CHAT_MESSAGE' packet");
			break;
		}
	}
}
