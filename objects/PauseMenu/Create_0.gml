
settings_save();

createMeter = function(name, maxvalue, get=function(){return 100;}, left=function(node, held){}, right=function(node, held){}) {
	var panel = new v_Panel(0, 0, {
		direction: eNodeDirection.ROW,
		draggable: false,
		border: false,
	});
	panel.PushDefaultChildrenStyle(defaultStyle);
	
	var len = 20 - string_length(name);
	var str = name + ":" + string_repeat(" ", len);
	var btncomp = {padding: new Dim(5, 0), margin: new Dim(5, 0)}
	
	panel.Push(new v_Text(str));
	panel.Push(new v_Button("<", left, btncomp));
	panel.Push(new v_Meter(80, 8, maxvalue, get, {margin: new Dim(5, 0)}));
	panel.Push(new v_Button(">", right, btncomp));
	
	return panel;
}

function createSettingMeter(_struct, _name, _step = 0.05, _min=0, _max=1) {
	var ctx = { target: _struct, key: _name, step: _step, minimum: _min, maximum: _max };

	return createMeter(
		_name,
		_max,
		method(ctx, function() {
			return target[$ key];
		}),
		method(ctx, function(_node, _held) {
			var s = (_held) ? (step / 5) : step;
			target[$ key] = max(minimum, target[$ key] - s);
		}),
		method(ctx, function(_node, _held) {
			var s = (_held) ? (step / 5) : step;
			target[$ key] = min(maximum, target[$ key] + s);
		})
	);
}

function createSettingMeters(_panel, _struct, _names, _step=0.05, _min=0, _max=1) {
	if (!is_array(_names)) {
		_panel.Push(createSettingMeter(_struct, _names, _step, _min, _max));
		return;
	}
	
	for (var i = 0; i < array_length(_names); i++) {
		_panel.Push(createSettingMeter(_struct, _names[i], _step, _min, _max));
	}
}

close = function() {
	settings_save();
	instance_destroy(PauseMenu);
}

separator = "=========================================";
defaultStyle = {
};
separatorStyle = {
	color: c_dkgray,
}

page = function() {
	var panel = new v_Panel(WIDTH / 2, HEIGHT / 2, {
		direction: eNodeDirection.COLUMN,
		draggable: false,
	});

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

#region main

main = page();
title(main, "Game Paused");

main.Push(new v_Button("Resume", function(node){
	PauseMenu.close();
}));

main.Push(new v_Button("Settings", function(node){
	PauseMenu.index = PauseMenu.settings;
}));

main.Push(v_Separator());

main.Push(new v_Button("Quit to Desktop", function(node){
	game_end();
}));

sep(main);

#endregion

#region settings

settings = page();
title(settings, "Settings");

settings.Push(new v_Button("Go Back", function(node){
	PauseMenu.index = PauseMenu.main;
}));

settings.Push(v_Separator());

settings.Push(new v_Button("Graphics", function(node){
	PauseMenu.index = PauseMenu.graphicSettings;
}));

settings.Push(new v_Button("Audio", function(node){
	PauseMenu.index = PauseMenu.audioSettings;
}));

settings.Push(new v_Button("Controls", function(node){
	PauseMenu.index = PauseMenu.audioSettings;
}));

sep(settings);

#endregion 

#region audio settings

audioSettings = page();
title(audioSettings, "Audio Settings");

audioSettings.Push(new v_Button("Go Back", function(node){
	PauseMenu.index = PauseMenu.settings;
}));

audioSettings.Push(v_Separator());

createSettingMeters(audioSettings, Settings.audio, "volume");
createSettingMeters(audioSettings, Settings.audio, "music");
createSettingMeters(audioSettings, Settings.audio, "sfx");
createSettingMeters(audioSettings, Settings.audio, "ui");
createSettingMeters(audioSettings, Settings.audio, "zoomFalloff", 0.02, 0.00, 1.00);

sep(audioSettings);

#endregion

#region graphic settings

graphicSettings = page();
title(graphicSettings, "Graphic Settings");

graphicSettings.Push(new v_Button("Go Back", function(node){
	PauseMenu.index = PauseMenu.settings;
}));

graphicSettings.Push(v_Separator());

graphicSettings.Push(new v_Button("Lighting: "+bool_string(Settings.graphics.lighting), function(node){
	graphicSettings.Edit("lighting_button", function(e){
		Settings.graphics.lighting = !Settings.graphics.lighting;
		var str = (Settings.graphics.lighting) ? "true" : "false";
		e.text = "Lighting: " + bool_string(Settings.graphics.lighting);
		e.UpdateLayout();
	});
}), "lighting_button");

sep(graphicSettings);

#endregion




index = main;
