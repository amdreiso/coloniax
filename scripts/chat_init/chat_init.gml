function chat_init(){
	
	#macro CHAT_FALLOFF 5 * 60
	
	/*
	
	String(
		Char(
			value: "this text is white and this is gonna be red: "
			color: #FFFFFF
		),
		
		Char(
			value: "I AM RED"
			color: #FF0000
		),
		
		Char(
			value: sEmoji_Alien
			color: #FFFFFF
		)
	)
	
	*/
	
	G CHAT;
	CHAT = {
		open : false,
		messages : [],
		
		width: 1000,
		height: 600,
		textScale: 1,
		backgroundAlpha: 0.67,
	};
	
	enum eChatCharType {
		TEXT,
		SPRITE,
	}
	
	CHAT.Char = function(value, color=c_white, font=fnt_console) constructor {
		self.type = eChatCharType.TEXT;
		if (is_string(value)) {
			self.type = eChatCharType.TEXT;
		} else if (sprite_exists(value)) {
			self.type = eChatCharType.SPRITE;
		}
		
		self.value = value;
		self.font = font;
		self.color = color;
		self.rainbow = false;
	}
	
	CHAT.Parse = function(str) {
		var content = [];
		var i = 1;
		var text = "";
		var color = c_white;
		var rainbow = false;
		var font = fnt_console;
		
		while (i <= string_length(str)) {
			var c = string_char_at(str, i);
			var delim = "~";
		
			if (c == delim) {
				if (text != "") {
					var char = new CHAT.Char(text, color, font);
					char.rainbow = rainbow;
					array_push(content, char);
					text = "";
				}
			
				var asset = "";
				i++;
			
				while (string_char_at(str, i) != delim && i <= string_length(str)) {
					asset += string_char_at(str, i);
					i++;
				}
			
				i++;
			
				var spr = "sEmoji_" + asset;
				array_push(content, new CHAT.Char(asset_get_index(spr), color));
				continue;
			}
		
			if (c == "$") {
				if (text != "") {
					var char = new CHAT.Char(text, color, font);
					char.rainbow = rainbow;
					array_push(content, char);
					text = "";
				}
				
				str = string_delete(str, i, 1);
			
				var hex = string_copy(str, i, 6);
			
				var r = real("0x" + string_copy(hex, 1, 2)); 
				var g = real("0x" + string_copy(hex, 3, 2)); 
				var b = real("0x" + string_copy(hex, 5, 2));
			
				color = make_color_rgb(r, g, b);
			
				i += 6;
				continue;
			}
			
			if (c == "%") {
				if (text != "") {
					var char = new CHAT.Char(text, color, font);
					char.rainbow = rainbow;
					array_push(content, char);
					text = "";
				}
				
				i++;
				var cmd = string_char_at(str, i);
				
				if (cmd == "r") {
					rainbow = true;
					i++;
				}
				
				if (cmd == "b") {
					font = fnt_console_bold;
					i++;
				}
				
				if (cmd == "i") {
					font = fnt_console_italic;
					i++;
				}
				
				if (cmd == "d") {
					font = fnt_console_bold_italic;
					i++;
				}
				
				if (cmd == "n") {
					font = fnt_console;
					i++;
				}
				
				continue;
			}
		
			text += c;
			i++;
		}
	
		if (text != "") {
			var char = new CHAT.Char(text, color, font);
			char.rainbow = rainbow;
			array_push(content, char);
		}
		
		return content;
	}
	
	CHAT.Token = function(content) constructor {
		self.content = content;
		self.width = 0;
		
		for (var i = 0; i < array_length(self.content); i++) {
			var str = self.content[i];
			
			if (str.type == eChatCharType.TEXT) {
				self.width += string_width(str.value);
			} else if (str.type == eChatCharType.SPRITE) {
				self.width += sprite_get_width(str.value) / 2;
			}
		}
		
		self.time = CHAT_FALLOFF;
	}
	
	CHAT.Send = function(text) {
		if (text == "") return;
		array_insert(CHAT.messages, 0, new CHAT.Token(CHAT.Parse(text)));
	}

	CHAT.SendTime = function(text) {
		if (text == "") return;
		var time = $"$999999[{current_time/1000}]$ffffff ";
		array_insert(CHAT.messages, 0, new CHAT.Token(CHAT.Parse(time+text)));
	}
	
	CHAT.DrawString = function(yy, token, alpha=1) {
		var pos = 20;
		ALIGN_BOTTOM_LEFT;
		
		alpha = clamp(alpha, 0, 1);
		
		draw_set_alpha(CHAT.backgroundAlpha * alpha);
		draw_rectangle_color(0, yy, CHAT.width, yy - 21, c_black, c_black, c_black, c_black, false);
		draw_set_alpha(1);
		
		for (var i = 0; i < array_length(token.content); i++) {
			var char = token.content[i];
			
			if (char.type == eChatCharType.TEXT) {
				draw_set_font(char.font);
				var c = char.color;
				if (char.rainbow) {
					c = make_color_hsv((current_time / 25) % 255, 255, 255);
				}
				draw_text_color(pos, yy, char.value, c, c, c, c, alpha);
				pos += string_width(char.value);
			}
			
			if (char.type == eChatCharType.SPRITE) {
				draw_sprite_ext(char.value, 0, pos, yy, 1, 1, 0, char.color, alpha);
				pos += sprite_get_width(char.value) / 2;
			}
		}
	}
	
	CHAT.Draw = function() {
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
			draw_rectangle_color(0, yy+sep, CHAT.width, yy-1, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(1);
			
			draw_text(
				textOffset, yy + sep, "> " + keyboard_string
			);
			
			if (keyboard_check_pressed(vk_enter)) {
				CHAT.Send("$aaaaaa%b<player>$ffffff%n "+keyboard_string);
				keyboard_string = "";
				CHAT.Close();
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
