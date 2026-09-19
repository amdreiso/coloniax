
main = new v_Panel(200, 200, {
	direction: eNodeDirection.COLUMN,
	draggable: false,
});

main.Push(new v_Text("===========", {color: c_gray}));
main.Push(new v_Text("Game Paused"));
main.Push(new v_Text("===========", {color: c_gray}));



//// buttons
//section1 = new v_Panel(0, 0, {
//	direction: eNodeDirection.ROW,
//	border: false,
//});
//section1.PushDefaultChildrenStyle({
//	padding: new Dim(10, 0),
//});

//section1.Push(new v_Button("button1", function(){
//	menuOpen = false;
//}));
//section1.Push(new v_Button("button2"));
//section1.Push(new v_Button("button3", function(){
//	window_set_fullscreen(!window_get_fullscreen());
//}));
//section1.Push(new v_Button("false", function(){
//	section1.Edit("false_button", function(e){
//		var str = (e.text == "true") ? "false" : "true";
//		e.text = str;
//	});
//}), "false_button");

//main.Push(section1);

//section2 = new v_Panel(0, 0, {
//	direction: eNodeDirection.ROW,
//	border: false,
//});
//section2.Push(new v_Text("hp:     "));
//section2.Push(new v_Meter(80, 8, 100, function(){return hp.value}));
//main.Push(section2);
