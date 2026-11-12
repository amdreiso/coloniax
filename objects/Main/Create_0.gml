
// /home/andy/.local/share/Steam/steamapps/compatdata/1670460/pfx/drive_c/users/steamuser/AppData/Local/space_simulator

// Init
randomize();
fovy();
console_init();
input_mapping();
vela();

translation_init();
settings_init();
resolution_init();
command_data();
tile_data();
item_data();
chat_init();
planet_init();
effect_init();
sound_init();
await_init();
process_init();
achievement_init();
minimap_init();
structure_init();
enemy_init();


// Draw
draw_set_font(fnt_main);
display_set_gui_maximise();

// Macros
#macro GRAVITATIONAL_CONSTANT 0.1
#macro CHUNK_SIZE 5120

#macro TILE_WIDTH sprite_get_width(sTile_Default)
#macro TILE_HEIGHT 16
#macro TILE_TAIL 7

// Globals
G Manifest;
Manifest = {
	name	: "Coloniax",
	version	: "1.2",
	build	: "INDEV",
	author	: "Andrei Scatolin (c) lowqualitypictures",
}

G Debug;
Debug = {
	console : false,
	showDebugUI : false,
	velaUI : false,
	windowInfo : false,
	showMessages : true,
	showNetworkPackets : false,
	showHitboxes : false,
}

function debug_get_input() {
	var holding = keyboard_check(vk_f3);
	static used = false;
	
	if (holding) {
		if (keyboard_check_pressed(ord("S"))) {
			Debug.showNetworkPackets = !Debug.showNetworkPackets;
			used = true;
		}
		
		if (keyboard_check_pressed(ord("H"))) {
			Debug.showHitboxes = !Debug.showHitboxes;
			used = true;
		}
		
		if (keyboard_check_pressed(ord("M"))) {
			Debug.showMessages = !Debug.showMessages;
			used = true;
		}
		
		if (keyboard_check_pressed(ord("V"))) {
			Debug.velaUI = !Debug.velaUI;
			used = true;
		}
	}

	if (keyboard_check_released(vk_f3)) {
		if (!used)
			Debug.showDebugUI = !Debug.showDebugUI;
		else
			used = false;
	}
}

G Paused;
Paused = false;

G GameSpeed;
GameSpeed = 1;

G Seed;
Seed = 0;

random_set_seed(0);

G CursorBusy, KeyboardBusy;
CursorBusy = false;
KeyboardBusy = false;

G GUI, DRAW;
GUI = new Callback();
DRAW = new Callback();

// file system
mkdir("screenshots");
mkdir("planets");
mkdir("translations");

// settings
settings_load();

// start
window_set_caption(Manifest.name);
CONSOLE.Run("start");

audio_group_load(audiogroup_default);
audio_group_load(audiogroup_music);

showSavingIcon = 0;


print(working_directory);
