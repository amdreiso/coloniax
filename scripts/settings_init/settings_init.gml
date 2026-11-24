function settings_init() {
	G Settings;
	Settings = settings_get();
	
	#macro SETTINGS_FILE "settings.ini"
}

function settings_get(){
	// Default settings
	var stt = {
		camera : {
			shakeIntensity: 1,
		},
		
		graphics : {
			resolution: 0,
			lighting: false,
			uiScale: 2,
		},
		
		audio: {
			volume: 1,
			music: 0.75,
			sfx: 1,
			ui: 1,
			zoomFalloff: 2,
		},
		
		network: {
			ip: "127.0.0.1",
			port: 8080,
		},
		
		language: "english.lang",
	};
	
	return stt;
}

function ini_write(section, name, value) {
	if (is_string(value)) {
		ini_write_string(section, name, value);
		return true;
	} else {
		ini_write_real(section, name, value);
		return true;
	}
}

function ini_save_struct_recursive(struct, section="main") {
	var names = struct_get_names(struct);

	for (var i = 0; i < array_length(names); i++) {
		var name = names[i];
		var val = struct_get(struct, name);

		if (is_struct(val)) {
			ini_save_struct_recursive(val, name);
			continue;
		}

		ini_write(section, name, val);
	}
}

function ini_save_struct(struct, section) {
	var names = struct_get_names(struct);

	for (var i = 0; i < array_length(names); i++) {
		var name = names[i];
		var val = struct_get(struct, name);

		ini_write(section, name, val);
	}
}

function settings_save() {
	var file = ini_open(SETTINGS_FILE);

	ini_save_struct_recursive(Settings, "Settings");
	ini_close();

	Main.showSavingIcon = 4 * 60;
}

function ini_read(section, name, value) {
	if (!ini_section_exists(section)) {
		print($"INI: trying to read section '{section}' that doesn't exist.");
		return;
	}
	if (!ini_key_exists(section, name)) {
		print($"INI: trying to read key '{name}' that doesn't exist.");
		return value;
	}

	if (is_string(value)) {
		return ini_read_string(section, name, value);
	} else {
		return ini_read_real(section, name, value);
	}
}

function ini_read_struct(struct, section) {
	var names = struct_get_names(struct);

	for (var i = 0; i < array_length(names); i++) {
		var name = names[i];
		var defaultvalue = struct_get(struct, name);

		var val = ini_read(section, name, defaultvalue);
		struct_set(struct, name, val);
		CHAT.Debug($"struct set [{section}] {name} {val}");
	}
}

function settings_load() {
	Settings.graphics.resolution = Resolution.GetHighest();
	
	if (!file_exists(SETTINGS_FILE)) return;
	var file = ini_open(SETTINGS_FILE);
	
	var names = struct_get_names(Settings);
	for (var i = 0; i < array_length(names); i++) {
		var name = names[i];
		if (is_struct(Settings[$ name])) {
			ini_read_struct(Settings[$ name], name);
			continue;
		}
		Settings[$ name] = ini_read("Settings", name, Settings[$ name]);
	}

	Resolution.Set(Settings.graphics.resolution);

	TRANSLATION.FileRead(Settings.language);
	TRANSLATION.file = Settings.language;
	TRANSLATION.index = array_find_index(TRANSLATION.files, function(e){
		return (e == TRANSLATION.file);
	});

	ini_close();
}
