
ts = tolin_state();
tolin_register(ts, "print", CHAT.Send);

// Root
root = new v_Panel(300, 300, {
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

input = new v_InputBox("", {
	padding: new Dim(200, 125),
});

buttons.Push(new v_Button("Run", function(){
	tolin_set_code(ts, input.text);
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

