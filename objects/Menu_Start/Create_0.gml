
stars = [];
starSpeed = 0.5;
createStar = function(){
	var c = color_darkness(choose(#9BB0FF, #AABFFF, #CAD7FF, #F8F7FF, #FFF4EA, #FFD2A1, #FFB56B), irandom_range(20, 140));
	array_push(stars, {
		alpha: random_range(0.30, 0.80),
		x: irandom(10000),
		y: irandom(10000),
		color: c,
		dot: choose(false, true),
	});
}
repeat (1000) {
	createStar();
}

var m = 2;
var xx = m;
var yy = m;

defaultStyle = {
	backgroundColor: c_black,
	draggable: false,
	border: false,
	buttonSound: snd_select_0,
};

root = new v_Panel(xx, yy, {
	direction: eNodeDirection.COLUMN,
	border: false,
	backgroundColor: c_black,
	draggable: false,
});
root.isRoot = true;
root.PushDefaultChildrenStyle(defaultStyle);

main = new v_Panel(,, {
	direction: eNodeDirection.COLUMN,
});

ipAddress = new v_Panel(,,{
	direction: eNodeDirection.ROW,
	draggable: false,
	border: false,
	backgroundColor: c_black,
});

ipAddress.PushDefaultChildrenStyle({
	padding: new Dim(30, 0),
});

ipAddress.Push(new v_Text(T.Get("ip")+": "));
ip = new v_InputText(Settings.network.ip);
ipAddress.Push(ip);
ipAddress.Push(new v_Text(T.Get("port")+": "));
port = new v_InputText(string(Settings.network.port));
ipAddress.Push(port);

main.Push(ipAddress);
main.Push(v_Separator());

seed = new v_InputText("seed", {width: 100});
main.Push(seed);

main.Push(v_Separator());

main.Push(new v_Button(T.Getc("host"), function(node){
	room_goto(rmWorld);
	
	var txt = seed.text;
	var int = ord_to_dec(txt);
	Seed = (txt == "seed") ? irandom_range(1000000, 10000000000) : real(int);
	
	Process.Push(function(){
		if (room == rmWorld) {
			var host = instance_create_depth(0, 0, 0, Host, {
				port: real(port.text)
			});
			
			Settings.network.ip = ip.text;
			Settings.network.port = real(port.text);
			
			return true;
		}
	});
	GUI.Remove("main_menu");
}));

main.Push(new v_Button(T.Getc("join"), function(node){
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
	GUI.Remove("main_menu");
}));

main.Push(new v_Button(T.Getc("settings"), function(node){
	Menu_Start.index = settings;
}));

main.Push(new v_Button(T.Getc("quit_desktop"), function(node){
	game_end();
}));

var stt = settings_create_menu(self, WIDTH / 2, HEIGHT / 2, defaultStyle);

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

