
colors = [];
for (var i = 0; i < 5; i++) {
	for (var j = 0; j < 10; j++) {
		var step = 255 div 10;
		var sat = 255 - i*(255 div 5);
		array_push(colors, make_color_hsv(j * step, sat, sat));
	}
}

menu = ui_create_color_picker(x, y, colors);

onSelect = function(color){}

GUI.Register(function(){
	menu.Draw();
}, "colorpicker");

