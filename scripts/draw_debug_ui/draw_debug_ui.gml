function draw_debug_ui(){
	if (!Debug.showDebugUI) return;
	content = [];
	maxstrlen = 0;
	_ = function(str, color=c_white) {
		str = " " + str + " ";
		maxstrlen = max(maxstrlen, string_length(str));
		array_push(content, {str:str, color:color});
	}
	var line = function(title="", color=c_gray) {
		var size = 50;
		title = string_upper(title);
		var len = string_length(title);
		if (len == 0) {
			_(string_repeat("=", size), color);
			return;
		}
		
		var left  = size / 2 - ceil(len / 2);
		var right = size / 2 - floor(len / 2);
		
		var final = string_repeat("=", left) + title + string_repeat("=", right);
		_(final, color);
	}
	
	line("info");
	_($"{Manifest.name} v{Manifest.version} {Manifest.build} by {Manifest.author}");
	_($"fps: {fps}");
	_($"processes: {array_length(Process.list)}");
	_($"kbs: {bool_string(KeyboardBusy)} mbs: {bool_string(CursorBusy)}");
	_($"velax: {Vela.navigation.x} velay: {Vela.navigation.y}");
	
	if (instance_exists(Spaceship)) {
		line("Spaceship");
		var p = Spaceship;
		_($"x: {p.x} | y: {p.y}");
		_($"dir: {p.dir} | speed: {p.spd} | turnSpeed: {p.turnSpeed} | angle: {abs(p.angle)}");
		var ppos = World.getChunkPosition(p.x, p.y);
		_($"cx: {ppos.x} cy: {ppos.y}");
	}

	if (instance_exists(Player)) {
		line("Player");
		var p = Player;
		_($"x: {p.x} y: {p.y} | tx: {p.planetTilePosition.x} ty: {p.planetTilePosition.y}");
	}
	
	if (Debug.windowInfo) {
		line("Window");
		_($"x: {window_get_x()} y: {window_get_y()}");
		_($"dmx: {display_mouse_get_x()} dmy: {display_mouse_get_y()}");
		_($"wmx: {window_mouse_get_x()} wmy: {window_mouse_get_y()}");
		_($"mx: {mouse_x} my: {mouse_y}");
	}
	
	draw_set_font(fnt_main);
	
	ALIGN_TOP_LEFT;
	
	var sep = 16;
	var fw = 8;
	var scale = 1;
	var len = array_length(content);
	
	draw_set_alpha(0.75);
	draw_rectangle_colour(
		0, 0, 
		maxstrlen * fw,
		len*sep, c_black, c_black, c_black, c_black, false
	);
	draw_set_alpha(1);
	
	for ( var i = 0; i < len; i++ ) {
		var c = content[i].color;
		draw_text_transformed_color(0, i * sep, content[i].str, scale, scale, 0, c, c, c, c, 1);
	}
	
	ALIGN_MIDDLE_CENTER;
	
}
