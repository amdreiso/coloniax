
stars = [];
starSpeed = 5;
starLightspeed = false;
starLightspeedCooldown = 0;
starCount = HEIGHT;
createStar = function(){
	var len = array_length(stars);
	if (len >= starCount) return;
	var c = color_darkness(
		choose(#9BB0FF, #AABFFF, #CAD7FF, #F8F7FF, #FFF4EA, #FFD2A1, #FFB56B), 
		irandom_range(90, 230)
	);
	var star = {
		old: new Vec2(),
		x: irandom(10000),
		y: irandom(10000),
		color: c,
		dot: choose(false, true),
		spd: random_range(0.5, 1.0),
	};
	star.old = new Vec2(star.x, star.y);
	array_push(stars, star);
	createStar();
}
createStar();

isPlanetSpinning = 1;
isPlanetSpinningTime = 1;

host = function() {
	room_goto(rmWorld);
	
	var txt = seed.text;
	var int = ord_to_dec(txt);
	Seed = (txt == "seed") ? irandom_range(10000, 10000000000) : real(int);
	
	Process.Push(function(){
		if (room == rmWorld) {
			var host = instance_create_depth(0, 0, 0, Host, {
				port: real(port.text),
			});
			
			Settings.network.ip = ip.text;
			Settings.network.port = real(port.text);
			
			return true;
		}
	});
}

var xmlSource = @'
<style>
	default {
		"backgroundColor": "#000000",
	}
	.main {
		"direction": 0,
	}
</style>
<panel class="main">
	<separator/>
	<button onclick="host">singleplayer</button>
	<separator/>
</panel>
';
var xml = xml_parse(xmlSource);
print(json_stringify(xml, true));

defaultStyle = {
	backgroundColor: c_black,
	draggable: false,
	border: false,
	buttonSound: snd_select_0,
};

root = new v_Panel(,,{
	direction: eNodeDirection.COLUMN,
	border: false,
	backgroundColor: c_black,
	draggable: false,
});
root.isRoot = true;
root.PushDefaultChildrenStyle(defaultStyle);

root.Edit("main", function(node){
	struct_merge(node.style, {
		direction: eNodeDirection.COLUMN,
	});
});

main = new v_Panel(,,{
	direction: eNodeDirection.COLUMN,
});

main.Push(v_Separator());

main.Push(new v_Button(T.Getc("singleplayer"), function(node){
	Menu_Start.host();
}));

main.Push(new v_Button(T.Getc("multiplayer"), function(node){
	Menu_Start.index = multiplayer;
}));

main.Push(new v_Button(T.Getc("settings"), function(node){
	Menu_Start.index = settings;
}));

main.Push(new v_Button(T.Getc("quit_desktop"), function(node){
	settings_save();
	game_end();
}));

main.Push(v_Separator());

#region multplayer stuff

multiplayer = new v_Panel(,,{
	direction: eNodeDirection.COLUMN,
	draggable: false,
	backgroundColor: TRANSPARENT,
	border: false,
});

multiplayer.Push(v_Separator());

multiplayer.Push(new v_Button(T.Getc("go_back"), function(node){
	Menu_Start.index = Menu_Start.root;
}));

multiplayer.Push(v_Separator());

ipAddress = new v_Panel(,,{
	direction: eNodeDirection.ROW,
	draggable: false,
	border: false,
	backgroundColor: c_black,
});

ipAddress.PushDefaultChildrenStyle({padding: new Dim(30, 0)});
ipAddress.Push(new v_Text(T.Get("ip")+": "));
ip = new v_InputText(Settings.network.ip);
ipAddress.Push(ip);
ipAddress.Push(new v_Text(T.Get("port")+": "));
port = new v_InputText(string(8080));
ipAddress.Push(port);

multiplayer.Push(ipAddress);

seed = new v_InputText("seed", {width: 100});
multiplayer.Push(seed);

multiplayer.Push(v_Separator());

multiplayer.Push(new v_Button(T.Getc("host"), function(node){
	Menu_Start.host();
}));

multiplayer.Push(new v_Button(T.Getc("join"), function(node){
	room_goto(rmWorld);
	Process.Push(function(){
		if (room == rmWorld) {
			var client = instance_create_depth(0, 0, 0, Client, {
				address: ip.text,
				port: real(port.text),
			});
			
			Settings.network.ip = ip.text;
			Settings.network.port = real(port.text);
			
			return true;
		}
	});
}));

multiplayer.Push(v_Separator());

#endregion

// Settings
var stt = settings_create_menu(self, WIDTH / 2, HEIGHT / 2, new v_Text(" "), defaultStyle);

settings = stt.settings;
audioSettings = stt.audioSettings;
graphicsSettings = stt.graphicsSettings;

delete stt;

root.Push(main);

index = root;
show = false;

Process.Push(function(){
	index.SetPosition(WIDTH / 2 - index.width/2, HEIGHT / 2);
	show = true;
	return true;
});

// Wait for audio group and play menu song
Process.Push(function(){
	if (audio_group_is_loaded(audiogroup_music)) {
		song = audio_play_sound(snd_traveling_2, 0, true);
		return true;
	}
});

