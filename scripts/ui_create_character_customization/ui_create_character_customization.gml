function ui_create_character_customization() {

	var main = new v_Panel(200, 200, {
		direction: eNodeDirection.COLUMN,
		draggable: true,
	});
	main.isRoot = true;

	main.Push(new v_Text("=======================", {color: c_gray}));
	main.Push(new v_Text("Character Customization"));
	main.Push(new v_Text("=======================", {color: c_gray}));
	main.Push(v_Separator());

	var param = function(name, get, set, minvalue, maxvalue) {
		var panel = new v_Panel(0, 0, {
			direction: eNodeDirection.ROW,
			draggable: false,
			border: false,
		});
		
		var len = 20 - string_length(name);
		var str = name + ":" + string_repeat(" ", len);
		var btncomp = {
			padding: new Dim(5, 0), 
			margin: new Dim(5, 0),
		}

		var args = {minvalue: minvalue, maxvalue: maxvalue, get: get, set: set}

		panel.Push(new v_Button("<", method(args, function(){
			var val = get()-1;
			val = clamp(val, minvalue, maxvalue);
			set(val);
		}), btncomp));

		panel.Push(new v_Text(str));

		panel.Push(new v_Button(">", method(args, function(){
			var val = get()+1;
			val = clamp(val, minvalue, maxvalue);
			set(val);
		}), btncomp));

		return panel;
	}

	var colorparam = function(name, onSelect=function(){}, colors=[]) {
		var panel = new v_Panel(0, 0, {
			direction: eNodeDirection.ROW,
			draggable: false,
			border: false,
		});

		var args = {onSelect: onSelect, colors: colors}

		panel.Push(new v_Button(name, method(args, function(){
			while (instance_exists(Menu_ColorPicker)) instance_destroy(Menu_ColorPicker);

			var menu = instance_create_depth(window_mouse_get_x(), window_mouse_get_y(), 99999, Menu_ColorPicker);
			menu.colors = array_concat(menu.colors, colors);

			var args = {onSelect: onSelect}

			menu.onSelect = method(args, function(color) {
				onSelect(color);
			})
		})));

		return panel;
	}

	main.Push(param("Eye", function(){ return Player.appearance.eyeID }, function(val){ Player.appearance.SetEye(val); }, 0, 7));
	main.Push(param("Hair", function(){ return Player.appearance.hairID }, function(val){ Player.appearance.SetHair(val); }, 0, 9));

	main.Push(colorparam("Eye Color", function(color){ Player.appearance.eyeColor = color }, appearance_get_eye_colors()));
	main.Push(colorparam("Hair Color", function(color){ Player.appearance.hairColor = color }, appearance_get_hair_colors()));
	main.Push(colorparam("Skin Color", function(color){ Player.appearance.skinColor = color }, appearance_get_skin_colors()))

	main.Push(v_Separator());
	main.Push(v_Separator());

	return main;

}

function ui_create_color_picker(x, y, colors=[], rows=10) {

	var main = new v_Panel(x, y, {
		direction: eNodeDirection.COLUMN,
		draggable: true,
	});

	for (var i = 0; i < array_length(colors); i += rows) {
		var panel = new v_Panel(0, 0, {
			direction: eNodeDirection.ROW,
		});

		for (var j = i; j < min(i + rows, array_length(colors)); j++) {
			var args = {color: colors[j]};

			panel.Push(new v_Button("  ", method(args, function() {
				Menu_ColorPicker.onSelect(color);
				instance_destroy(Menu_ColorPicker);
			}), {
				backgroundColor: colors[j],
				padding: new Dim(2, 2),
			}));
		}

		main.Push(panel);
	}

	return main;

}

