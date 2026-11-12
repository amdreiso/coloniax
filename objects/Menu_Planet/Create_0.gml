
if (!variable_instance_exists(self, "planet")) planet = noone;

if (planet == noone) {
	exit;
}

defaultStyle = {
	direction: eNodeDirection.COLUMN,
	anchor: eNodeAnchor.TOPLEFT,
	draggable: false,
	border: false,
};

// Root
root = new v_Panel(x, y, {
	direction: eNodeDirection.COLUMN,
	draggable: true,
	anchor: eNodeAnchor.MIDDLECENTER,
});
root.isRoot = true;

main = new v_Panel(0, 0, {
	direction: eNodeDirection.COLUMN,
	anchor: eNodeAnchor.MIDDLECENTER,
});

main.Push(v_Separator());
main.Push(new v_Text(T.Getc("planet_menu")));
main.Push(v_Separator());

namePanel = new v_Panel(0, 0, struct_merge({}, defaultStyle, {
	direction: eNodeDirection.ROW,
}));
namePanel.Push(new v_Text(T.Getc("name")+": "));
namePanel.Push(new v_InputText(planet.name, {width: 200}));

main.Push(namePanel);
main.Push(v_Separator());

main.Push(new v_Text(T.Getc("type")+": "+string(planet.type)));
main.Push(v_Separator());

root.Push(main);

GUI.Register(function(){
	root.Draw();
}, "planet");

