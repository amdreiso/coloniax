function translation_init(){
	enum eLanguageID {
		ENGLISH,
		COUNT,
	}
	
	G TRANSLATION;
	G Language;
	Language = eLanguageID.ENGLISH;
	
	#macro T TRANSLATION
	
	TRANSLATION = {
		data: {},
		index: 0,
		file: "english.lang",
	};

	#region ENGLISH
	
	var buffer;
	
	var english = translation_get_english();
	buffer = buffer_create(string_byte_length(english) + 1, buffer_fixed, 1);
	buffer_write(buffer, buffer_text, english);
	buffer_save(buffer, "translations/english.lang");
	buffer_delete(buffer);

	#endregion

	#region PORTUGUESE
	
	var buffer;
	var portuguese = translation_get_portuguese();
	buffer = buffer_create(string_byte_length(portuguese) + 1, buffer_fixed, 1);
	buffer_write(buffer, buffer_text, portuguese);
	buffer_save(buffer, "translations/portuguese.lang");
	buffer_delete(buffer);

	#endregion

	// Read every file in translations directory
	TRANSLATION.files = directory_get_files("translations");

	TRANSLATION.Cycle = function() {
		var files = TRANSLATION.files;
		var len = array_length(files);
		if (len == 0) return;

		TRANSLATION.index = (TRANSLATION.index + 1) % len;
		TRANSLATION.FileRead(files[TRANSLATION.index]);
	}

	TRANSLATION.FileRead = function(path) {
		var result = {};
		var full = working_directory + "/translations/" + path;
		if (!file_exists(full)) {
			print("TRANSLATION ERR: File '"+full+"' not found.");
			TRANSLATION.FileRead("english.lang");
			return result;
		};

		var f = file_text_open_read(full);
		while (!file_text_eof(f)) {
			var line = string_trim(file_text_read_string(f));
			file_text_readln(f);

			// skip blanks and comments
			if (line == "" || string_char_at(line, 1) == "#") continue;

			var eq = string_pos("=", line);
			if (eq == 0) continue;

			var key = string_trim(string_copy(line, 1, eq - 1));
			var val = string_trim(string_delete(line, 1, eq));
			val = string_replace_all(val, "\\n", "\n");

			var file = TRANSLATION.files[TRANSLATION.index];
			TRANSLATION.file = file;
			Settings.language = file;
			result[$ key] = val;
		}
		file_text_close(f);
		TRANSLATION.data = result;
	};

	TRANSLATION.Get = function(key) {
		return TRANSLATION.data[$ key] ?? "???";
	};

	// Gets string but capitalizes first character
	TRANSLATION.Getc = function(key) {
		var str = TRANSLATION.data[$ key];
		if (str != undefined) {
			var first = string_upper(string_char_at(str, 0));
			str = string_delete(str, 0, 1);
			str = first+str;
		}
		return str ?? "???";
	};

}
