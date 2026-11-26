
event_inherited();

if (!variable_instance_exists(self, "instance")) instance = noone;

if (instance == noone) {
	exit;
}

defaultStyle = {
	direction: eNodeDirection.COLUMN,
	anchor: eNodeAnchor.TOPLEFT,
	draggable: false,
	border: false,
};

// Root
root = new v_Panel(300, 300, {
	direction: eNodeDirection.COLUMN,
	draggable: true,
	anchor: eNodeAnchor.TOPLEFT,
});
root.isRoot = true;

buttons = new v_Panel(,,struct_merge({}, defaultStyle, {
	background: #242424,
	direction: eNodeDirection.ROW,
}));

buttons.Push(new v_Text($"Monitoring '{object_get_name(instance.object_index)}'"));

buttons.Push(new v_Button("Close", function(){
	instance_destroy(Menu_Monitor);
}, {
	backgroundColor: #242424,
	margin: new Dim(5, 5),
}));

// Where all the variables will be seen
main = new v_Panel(,,defaultStyle);
itemCount = 0;

monitor = function(key) {
	var panel = new v_Panel(,,struct_merge({}, defaultStyle, {
		direction: eNodeDirection.ROW,
	}));

	var title = new v_Text(key);
	var value = new v_Text(struct_get(instance, key) ?? "???");

	panel.Push(title);
	panel.Push(new v_Text(" : "));
	panel.Push(value);

	main.Push(panel, $"item_{itemCount}");
	itemCount ++;
}

var names = struct_get_names(instance);
for (var i = 0; i < array_length(names); i++) {
	monitor(names[i]);
}

root.Push(buttons);
root.Push(main);

