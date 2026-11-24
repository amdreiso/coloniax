
event_inherited();

blurBackground = true;
backgroundOpacity = 0.4;

settings_save();

close = function() {
	settings_save();
	instance_destroy(Menu_Pause);
}

separator = "=========================================";
separatorStyle = {
	color: c_dkgray,
}

defaultStyle = {
	backgroundColor: #181818,
}

title = function(panel, name) {
	panel.Push(new v_Text(separator, separatorStyle));
	panel.Push(new v_Text(name));
	panel.Push(new v_Text(separator, separatorStyle));
}

sep = function(panel) {
	panel.Push(new v_Text(separator, separatorStyle));
}

root = new v_Panel(WIDTH/2, HEIGHT/2, struct_merge({}, defaultStyle, {
	direction: eNodeDirection.COLUMN,
}));
root.SetDefaultChildrenStyle(defaultStyle);
root.isRoot = true;

main = new v_Panel(,,{
	direction: eNodeDirection.COLUMN,
});

title(main, T.Getc("game_paused"));

main.Push(new v_Button(T.Getc("resume"), function(node){
	Menu_Pause.close();
}));

main.Push(new v_Button(T.Getc("settings"), function(node){
	Menu_Pause.index = Menu_Pause.settings;
}));

main.Push(v_Separator());

main.Push(new v_Button(T.Getc("quit_desktop"), function(node){
	game_end();
}));

sep(main);

var stt = settings_create_menu(self, WIDTH / 2, HEIGHT / 2, new v_Text(separator, separatorStyle), defaultStyle);

settings = stt.settings;
audioSettings = stt.audioSettings;
graphicsSettings = stt.graphicsSettings;

delete stt;

root.Push(main);

index = root;
show = false;

Process.Push(function(){
	index.SetPosition(WIDTH / 2 - index.width/2, HEIGHT / 2 - index.height/2);
	show = true;
	return true;
});

