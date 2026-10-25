
// /home/andy/.local/share/Steam/steamapps/compatdata/1670460/pfx/drive_c/users/steamuser/AppData/Local/space_simulator

// Init
randomize();
fovy();
console_init();
input_mapping();
tolin_init();
//tolin_builtin();
vela();

translation_init();
command_data();
chat_init();
settings_init();
item_data();
tile_data();
planet_init();
effect_init();
sound_init();
await_init();
process_init();
achievement_init();
minimap_init();
structure_init();

// Draw
draw_set_font(fnt_main);
display_set_gui_maximise();

// Macros
#macro GRAVITATIONAL_CONSTANT 0.25
#macro CHUNK_SIZE 5120

#macro TILE_WIDTH sprite_get_width(sTile_Default)
#macro TILE_HEIGHT 16
#macro TILE_TAIL 7

// Globals
G Manifest;
Manifest = {
	name	: "Coloniax",
	version	: "0.0",
	build	: "indev",
	author	: "Andy (c) lowqualitypictures",
}

CHAT.Send($"{Manifest.name} {Manifest.version}v {Manifest.build}");

G Debug;
Debug = {
	console			: false,
	showDebugUI		: false,
	velaUI			: false,
	windowInfo		: false,
}

G Paused;
Paused = false;

G GameSpeed;
GameSpeed = 1;

G Perlin;
Perlin = new perlin();
Perlin.seed(irandom(10000000));
randomize();

G CursorBusy, KeyboardBusy;
CursorBusy = false;
KeyboardBusy = false;

G GUI, DRAW;
GUI = new Callback();
DRAW = new Callback();

// file system
mkdir("screenshots");
mkdir("planets");

// Start
instance_create_depth(x, y, -999999, Draw_Handler);
instance_create_layer(x, y, "World", World);
instance_create_layer(x, y, "Spaceship", Player);
instance_create_layer(x, y, "Spaceship", Spaceship);

window_set_caption(Manifest.name);
CONSOLE.Run("start");

//fopen("main.tolin");
//if (file_exists("main.tolin")) {
//	tolinState = new TolinState();
//	tolin_load_builtin_functions(tolinState, Tolin_BuiltInFunctions);
//	tolin_load_constants(tolinState);
//	tolin_load_file(tolinState, "main.tolin");
//	tolin_run(tolinState);
//}

ts = tolin_state();
tolin_add_code(ts, "Spaceship.dir = 90");
tolin_run(ts);

audio_group_load(audiogroup_default);
audio_group_load(audiogroup_music);

Process.Push(function() {
	if (audio_group_is_loaded(audiogroup_music)) {
		var snd = choose(snd_traveling_0, snd_traveling_1, snd_traveling_2);
		audio_play_sound(snd, 0, true, 1);
		return true;
	}
});

showSavingIcon = 0;

