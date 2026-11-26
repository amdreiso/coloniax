function rich_text_init(){
	G RichText;
	RichText = {};

	enum RT_CharType {
		TEXT,
		SPRITE,
	}

	RichText.Char = function(value, color=c_white, font=fnt_console) {
		var char = {};
		char.type = RT_CharType.TEXT;

		if (is_string(value)) {
			char.type = RT_CharType.TEXT;
		} else if (sprite_exists(value)) {
			char.type = RT_CharType.SPRITE;
		}
		
		char.value = value;
		char.font = font;
		char.color = color;
		char.rainbow = false;
		return char;
	}

	RichText.Parse = function(str) {
		var content = [];
		var i = 1;
		var text = "";
		var color = c_white;
		var rainbow = false;
		var font = fnt_console;
		
		while (i <= string_length(str)) {
			var c = string_char_at(str, i);
			var delim = "~";
		
			// spites
			if (c == delim) {
				if (text != "") {
					var char = RichText.Char(text, color, font);
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
				array_push(content, RichText.Char(asset_get_index(spr), color));
				continue;
			}
		
			// hex color
			if (c == "$") {
				if (text != "") {
					var char = RichText.Char(text, color, font);
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
			
			// formatting
			if (c == "%") {
				if (text != "") {
					var char = RichText.Char(text, color, font);
					char.rainbow = rainbow;
					array_push(content, char);
					text = "";
				}
				
				i++;
				var cmd = string_char_at(str, i);
				
				if (cmd == "r") {
					rainbow = !rainbow;
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
			var char = RichText.Char(text, color, font);
			char.rainbow = rainbow;
			array_push(content, char);
		}
		
		return content;
	}

	RichText.Token = function(content) {
		var tkn = {};
		tkn.content = content;
		tkn.width = 0;
		
		for (var i = 0; i < array_length(tkn.content); i++) {
			var char = tkn.content[i];
			
			if (char.type == RT_CharType.TEXT) {
				tkn.width += string_width(char.value);
			} else if (char.type == RT_CharType.SPRITE) {
				tkn.width += sprite_get_width(char.value) / 2;
			}
		}
		
		return tkn;
	}

	RichText.Draw = function(xx, yy, token, alpha=1) {
		var pos = 0;
		ALIGN_BOTTOM_LEFT;
		
		for (var i = 0; i < array_length(token.content); i++) {
			var char = token.content[i];
			
			if (char.type == RT_CharType.TEXT) {
				draw_set_font(char.font);
				var c = char.color;
				var cnext = char.color;

				if (char.rainbow) {
					var step = 2000;
					var spd = 10;
					var time = (current_time / spd) + (i * step);
					c = make_color_hsv(time mod 256, 255, 255);
					cnext = make_color_hsv(((time + step)) mod 256, 255, 255);
				}

				draw_text_color(xx + pos, yy, char.value, c, cnext, cnext, c, alpha);

				pos += string_width(char.value);
				draw_set_font(fnt_main);
			}
			
			else if (char.type == RT_CharType.SPRITE) {
				draw_sprite_ext(char.value, 0, xx + pos, yy, 1, 1, 0, char.color, alpha);
				pos += sprite_get_width(char.value) / 2;
			}
		}
	}

	RichText.Create = function(str) {
		var tkn = RichText.Token(RichText.Parse(str));
		return tkn;
	}
}
