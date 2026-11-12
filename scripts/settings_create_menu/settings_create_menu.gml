function settings_create_menu(obj, x, y, style={}){
	
	_obj = obj;
	defaultStyle = {
	};
	
	struct_merge(defaultStyle, style);
	
	var page = function(x, y) {
		var panel = new v_Panel(x, y, {
			direction: eNodeDirection.COLUMN,
			draggable: false,
			backgroundColor: TRANSPARENT,
			border: false,
		});

		panel.PushDefaultChildrenStyle(defaultStyle);
		return panel;
	}
	
	createMeter = function(name, maxvalue=100, get=function(){return 100;}, left=function(node, held){}, right=function(node, held){}) {
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

	createSettingMeter = function(_struct, _name, text, _step = 0.05, _min=0, _max=1) {
		var ctx = { target: _struct, key: _name, step: _step, minimum: _min, maximum: _max };

		return createMeter(
			text,
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
	
	#region Settings
	
	settings = page(x, y);
	
	settings.Push(new v_Button(T.Getc("go_back"), function(node){
		_obj.index = _obj.root;
	}));
	
	settings.Push(v_Separator());
	
	languagePrefix = T.Getc("language")+": "
	settings.Push(new v_Button(languagePrefix + T.Get("lang"), function(node){
		settings.Edit("language_button", function(node){
			T.Cycle();
			node.text = languagePrefix + T.Getc("lang");
		});
	}), "language_button");

	settings.Push(v_Separator());

	settings.Push(new v_Button(T.Getc("graphics"), function(node){
		_obj.index = _obj.graphicsSettings;
	}));

	settings.Push(new v_Button(T.Getc("audio"), function(node){
		_obj.index = _obj.audioSettings;
	}));

	settings.Push(new v_Button(T.Getc("controls"), function(node){
		_obj.index = _obj.audioSettings;
	}));
	
	#endregion
	
	#region Audio settings

	audioSettings = page(x, y);

	audioSettings.Push(new v_Button(T.Getc("go_back"), function(node){
		_obj.index = _obj.settings;
	}));

	audioSettings.Push(v_Separator());

	audioSettings.Push(createSettingMeter(Settings.audio, "volume", 		T.Getc("volume"), 		0.05, 0, 1));
	audioSettings.Push(createSettingMeter(Settings.audio, "music", 			T.Getc("music"), 		0.05, 0, 1));
	audioSettings.Push(createSettingMeter(Settings.audio, "sfx", 			T.Getc("sfx"), 			0.05, 0, 1));
	audioSettings.Push(createSettingMeter(Settings.audio, "ui", 			T.Getc("ui"), 			0.05, 0, 1));
	audioSettings.Push(createSettingMeter(Settings.audio, "zoomFalloff", 	T.Getc("zoom_falloff"), 0.02, 0, 2));

	#endregion
	
	#region Graphics settings

	graphicSettings = page(x, y);

	graphicSettings.Push(new v_Button(T.Getc("go_back"), function(node){
		_obj.index = _obj.settings;
	}));

	graphicSettings.Push(v_Separator());

	graphicSettings.Push(new v_Button(T.Getc("resolution")+": "+Resolution.value, function(){
		Resolution.Cycle();
		graphicSettings.Edit("resolution_button", function(e){
			e.text = T.Getc("resolution")+": "+Resolution.value;
			e.UpdateLayout();
		});
	}), "resolution_button");

	graphicSettings.Push(new v_Button(T.Getc("lighting")+": "+bool_string(Settings.graphics.lighting), function(node){
		graphicSettings.Edit("lighting_button", function(e){
			Settings.graphics.lighting = !Settings.graphics.lighting;
			var str = (Settings.graphics.lighting) ? "true" : "false";
			e.text = T.Getc("lighting")+": " + bool_string(Settings.graphics.lighting);
			e.UpdateLayout();
		});
	}), "lighting_button");

	graphicSettings.Push(new v_Button(T.Getc("ui_scale")+": "+string(Settings.graphics.uiScale), function(node){

		graphicSettings.Edit("gui_scale_button", function(e){
			Settings.graphics.uiScale += (Settings.graphics.uiScale == 0.5) ? 0.5 : 1;

			if (Settings.graphics.uiScale >= 4) {
				Settings.graphics.uiScale = 0.5;
			}

			e.text = T.Getc("ui_scale")+": "+string(Settings.graphics.uiScale);
			e.UpdateLayout();
		});

	}), "gui_scale_button");

	#endregion
	
	return {
		settings: settings,
		audioSettings: audioSettings,
		graphicsSettings: graphicSettings,
	}
	
}