
ts = tolin_state();

// Root
root = new v_Panel(1000, 400, {
	direction: eNodeDirection.COLUMN,
	draggable: true,
	anchor: eNodeAnchor.MIDDLELEFT,
});
root.isRoot = true;

// Buttons
buttons = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	anchor: eNodeAnchor.MIDDLELEFT,
});

buttons.PushDefaultChildrenStyle({
	padding: new Dim(10, 0),
});

buttons.Push(new v_Button("Run", function(){
	tolin_run(ts);
}, {
	backgroundColor: #ff7777,
	color: c_black,
}));

buttons.Push(new v_Button("Close", function(){
	instance_destroy(Menu_Script);
}, {
	backgroundColor: #242424,
}));

inputPanel = new v_Panel(0, 0, {});

input = new v_InputBox("", {
	padding: new Dim(200, 125),
});

inputPanel.Push(input);

statusline = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});

stats = new v_Text("x:000 y:000 cl:000 l:000");
statusline.Push(stats, "stats");

root.Push(buttons);
root.Push(inputPanel);
root.Push(statusline);

GUI.Register(function(){
	root.Draw();
}, "script");

