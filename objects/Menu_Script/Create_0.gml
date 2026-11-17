
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
	anchor: eNodeAnchor.MIDDLECENTER,
	
});
root.isRoot = true;

#region Buttons

buttons = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});

buttons.PushDefaultChildrenStyle(struct_merge({}, defaultStyle, {
	padding: 10,
}));

buttons.Push(new v_Button("Run", function(){
	var ts = tolin_state();
	tolin_set_code(ts, input.text);
	tolin_run(ts);
}, {
	backgroundColor: VELA_RED,
	color: c_black,
	margin: new Dim(10, 10),
}));

buttons.Push(new v_Button("Run Verbose", function(){
	var ts = tolin_state();
	tolin_set_code(ts, input.text);
	tolin_run(ts, true);
}, {
	backgroundColor: VELA_GREEN,
	color: c_black,
	margin: new Dim(10, 10),
}));

buttons.Push(new v_Button("Close", function(){
	instance_destroy(Menu_Script);
}, {
	backgroundColor: #242424,
	margin: new Dim(10, 10),
}));

#endregion

inputPanel = new v_Panel(0, 0, defaultStyle);

var factor = 50;
input = new v_InputBox("", {
	width: 16*factor,
	height: 9*factor,
	
	borderColor: c_dkgray,
	borderColorSelected: c_ltgray,
});
input.editing = true;

inputPanel.Push(input);

root.Push(buttons);
root.Push(inputPanel);

//GUI.Register(function(){
//	root.Draw();
//}, "script");

