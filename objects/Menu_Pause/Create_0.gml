
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
	direction: eNodeDirection.COLUMN,
	draggable: false,
	backgroundColor: #181818,
}

page = function() {
	var panel = new v_Panel(WIDTH / 2, HEIGHT / 2, defaultStyle);
	panel.PushDefaultChildrenStyle(defaultStyle);
	return panel;
}

title = function(panel, name) {
	panel.Push(new v_Text(separator, separatorStyle));
	panel.Push(new v_Text(name));
	panel.Push(new v_Text(separator, separatorStyle));
}

sep = function(panel) {
	panel.Push(new v_Text(separator, separatorStyle));
}

#region root

root = page();
root.isRoot = true;

main = page();
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

var stt = settings_create_menu(self, WIDTH / 2, HEIGHT / 2, defaultStyle);

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
