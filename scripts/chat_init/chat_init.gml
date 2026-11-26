function chat_init(){
	G CHAT;
	CHAT = {
		open : false,
		messages : [],
		
		width: 1000,
		height: 600,
		textScale: 1,
		backgroundAlpha: 0.33,
		falloff: 5 * 60,
	};
	
	CHAT.Send = function(text, local=false) {
		text = string_trim(text);
		if (text == "") return;
		
		if (local) {
			var str = RichText.Create(text);
			str.time = CHAT.falloff;
			array_insert(CHAT.messages, 0, str);
			return;
		}
		
		if (network_client_exists()) {
			// Send message to host
			var buffer = buffer_create(256, buffer_grow, 1);
			buffer_write(buffer, buffer_u8, NET.CHAT_MESSAGE);
			buffer_write(buffer, buffer_string, text);
			network_send_packet(Client.socket, buffer, buffer_tell(buffer));
			buffer_delete(buffer);
			
		} else {
			var str = RichText.Create(text);
			str.time = CHAT.falloff;
			array_insert(CHAT.messages, 0, str);

		    var b = buffer_create(256, buffer_grow, 1);
		    buffer_write(b, buffer_u8, NET.CHAT_MESSAGE);
		    buffer_write(b, buffer_u8, 0);
		    buffer_write(b, buffer_string, text);
		    network_broadcast(b, -1);
		    buffer_delete(b);
		}
	}

	CHAT.SendTime = function(text) {
		if (text == "") return;
		var time = $"$999999[{current_time/1000}]$ffffff%n ";
		
		CHAT.Send(time+text, true);
	}

	CHAT.Debug = function(text) {
		if (text == "" || !Debug.showMessages) return;
		var prefix = $"$ffd700%b[DEBUG]$ffffff%n ";
		
		CHAT.Send(prefix+text, true);
	}

	CHAT.DebugNetwork = function(text) {
		if (text == "" || !Debug.showMessages) return;
		var prefix = $"$ffd700%b[DEBUG]$ffffff $ff2222[NETWORK]%n$ffffff: ";
		
		CHAT.Send(prefix+text, true);
	}
	
	CHAT.DrawString = function(yy, token, alpha=1) {
		var pos = 20;
		ALIGN_BOTTOM_LEFT;
		
		draw_set_alpha(CHAT.backgroundAlpha * alpha);
		draw_rectangle_color(0, yy, CHAT.width, yy - 21, c_black, c_black, c_black, c_black, false);
		draw_set_alpha(1);
		
		for (var i = 0; i < array_length(token.content); i++) {
			var char = token.content[i];
			RichText.Draw(5, yy, token, alpha);
		}
	}
	
	CHAT.Draw = function() {
		if (room == rmMenu) return;
		
		var yoff = 200;
		var sep = 20;
		var length = CHAT.height div sep;
		var textOffset = 5;
		var yy = HEIGHT - yoff;
		
		ALIGN_BOTTOM_LEFT;
		
		if (CHAT.open) {
			KeyboardBusy = true;
			
			for (var i = 0; i < array_length(CHAT.messages); i++) {
				if (i > length) continue;
				var token = CHAT.messages[i];
				CHAT.DrawString(yy - i * sep, token);
			}
			
			draw_set_alpha(CHAT.backgroundAlpha);
			draw_rectangle_color(0, yy+sep, CHAT.width, yy, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(1);
			
			draw_text(
				textOffset, yy + sep, "> " + keyboard_string
			);
			
			if (keyboard_check_pressed(vk_enter)) {
				CHAT.Send("$aaaaaa%b<player>$ffffff%n "+keyboard_string);
				CHAT.Close();
				keyboard_string = "";
			}
			
		} else {
			for (var i = 0; i < array_length(CHAT.messages); i++) {
				var token = CHAT.messages[i];
				token.time = max(0, token.time - 1);
				var alpha = token.time / 50;
				
				if (token.time > 0) {
					CHAT.DrawString(yy - i * sep, token, alpha);
				}
			}
		}
	}
	
	CHAT.Close = function() {
		CHAT.open = false;
		KeyboardBusy = false;
	}
}
