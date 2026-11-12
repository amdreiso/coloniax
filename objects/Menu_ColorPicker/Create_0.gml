
menu = new v_Panel(x, y, {
	direction: eNodeDirection.COLUMN,
	draggable: true,
});


onSelect = function(color){}

GUI.Register(function(){
	menu.Draw();
}, "colorpicker");

